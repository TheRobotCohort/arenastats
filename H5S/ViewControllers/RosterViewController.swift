import SwiftSpinner
import Reachability
import SwiftReorder

class RosterViewController: AppViewController, UITableViewDataSource, UITableViewDelegate
{
    let haloApi = HaloApi()                         // Reference to HaloAPI singleton
    let refreshControl = UIRefreshControl()         // Refresh controller

    var spartans = [Spartan]()                      // Array of Spartans
    var newSpartan: Spartan?                        // Reference to newly added Spartan
    var newSpartanNameField: UITextField?           // Reference to newly added Spartan name field
    var filteredSpartans = [Spartan]()              // Array of "show" Spartans
    var favoriteSpartans = [String]()               // Array of favorite Spartans
    var currentSpartanNames: [String] = []          // Array of Spartan names (duplicate checking)
    var refreshNotificationPending: Bool = false    // Flag to tell if a "refresh" is prning
    var selectedSegmentIndex: Int = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var segmentView: UISegmentedControl!

    // --------------------------------------------------------------------------------------------------
    // MARK: Lifecycle
    // --------------------------------------------------------------------------------------------------

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)

        loadSpartanData()
        tableView.reloadData()

        if (favoriteSpartans.count == 0) {
            segmentView.setEnabled(false, forSegmentAt: 1)
        } else {
            segmentView.setEnabled(true, forSegmentAt: 1)
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reorder.delegate = self
        tableView.rowHeight = 150

        // Slider Menu
        if (self.revealViewController() != nil) {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))

            self.revealViewController().rearViewRevealWidth = 95
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        registerNotifcationObservers()

        if UserDefaults.standard.bool(forKey: App.SettingsKeys.initialSetupKey) == false {
            UserDefaults.standard.set(true, forKey: App.SettingsKeys.initialSetupKey)
            UserDefaults.standard.set(false, forKey: App.SettingsKeys.hideAdsKey)
            UserDefaults.standard.set(0, forKey: App.SettingsKeys.numberOfLaunchesKey)
            UserDefaults.standard.set(Date(), forKey: App.SettingsKeys.lastMetaRefreshKey)
            UserDefaults.standard.set(App.SETTING_AD_REMOVE_LAUNCHES, forKey: App.SettingsKeys.numberOfLaunchesForAdRemovalKey)

            self.haloApi.refreshMetaData()
        } else {
            let metaRefreshDate = UserDefaults.standard.object(forKey: App.SettingsKeys.lastMetaRefreshKey) as! Date
            let interval = Date().timeIntervalSince(metaRefreshDate as Date)

            if interval > Double(86400 * 3) {
                print("Refreshing Expired Meta Data")
                self.haloApi.refreshMetaData()
                UserDefaults.standard.set(NSDate(), forKey: App.SettingsKeys.lastMetaRefreshKey)
            }
        }

        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Update")

        tableView.addSubview(refreshControl)
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(false)

        if (spartans.count < 1) {
            addSpartanAlert(sender: self)
        }
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Roster Table
    // --------------------------------------------------------------------------------------------------


    // Count Total Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (selectedSegmentIndex == 1) {
            return filteredSpartans.count
        }

        return spartans.count
    }

    // Populate Row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RosterCell", for: indexPath) as! RosterCell
        var spartan: Spartan

        if (selectedSegmentIndex == 0) {
            spartan = spartans[indexPath.row]
        } else {
            spartan = filteredSpartans[indexPath.row]
        }

        if (favoriteSpartans.filter({ $0 == spartan.gamerTag}).count > 0) {
            var faIcons = [String:UniChar]()
            faIcons["faStar"] = 0xf005
            cell.favorite.font = UIFont(name: "FontAwesome", size: 14)
            cell.favorite.text =  String(format: "%C", faIcons["faStar"]!)
            cell.favorite.isHidden = false
        } else {
            cell.favorite.isHidden = true
        }

        cell.gamerTag.text = spartan.gamerTag
        cell.lastUpdatedAgo.text = "Updated " + spartan.timeAgoSinceDate(date: spartan.dateRetreived)
        cell.emblem.image = spartan.profileEmblem()
        cell.rank.text = "SR " + spartan.rank
        cell.diffXp.text = spartan.xpDifference()
        cell.xp.text = spartan.xp.withCommas() + " xp"
        cell.xpProgressBar.progress = spartan.progressBar()

        return cell
    }

    // Row Actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let spartanGamerTag = self.spartans[indexPath.row].gamerTag
            self.spartans.remove(at: indexPath.row)
            tableView.reloadData()
            self.saveSpartans()

            // Update list of names
            self.currentSpartanNames = self.currentSpartanNames.filter() {$0 != spartanGamerTag}
            self.favoriteSpartans = self.favoriteSpartans.filter({$0 != spartanGamerTag})

            // Remove avatars
            let safeGamerTag = Spartan.safeGamerTag(gamerTag: spartanGamerTag)
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

            do {
                try FileManager.default.removeItem(atPath: fileURL.appendingPathComponent(safeGamerTag + "-portrait.png").path)
                try FileManager.default.removeItem(atPath: fileURL.appendingPathComponent(safeGamerTag + "-emblem.png").path)
                try FileManager.default.removeItem(atPath: fileURL.appendingPathComponent(safeGamerTag + "-full.png").path)
            } catch {
            }
        }

        return [delete]
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        var rosterCount = 0
        var sectionsCount = 0

        if (selectedSegmentIndex == 1) {
            rosterCount = filteredSpartans.count
        } else {
             rosterCount = spartans.count
        }

        if rosterCount > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle  = .none
            sectionsCount = 1
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No Spartans Assigned to Roster"
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return sectionsCount
    }
    
    // --------------------------------------------------------------------------------------------------
    // MARK: Add/Load/Save Sparatans
    // --------------------------------------------------------------------------------------------------
    
    func loadSpartans() -> [Spartan]?
    {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Spartan.ArchiveURL.path) as? [Spartan]
    }
    
    func saveSpartans()
    {
        NSKeyedArchiver.archiveRootObject(self.spartans, toFile: Spartan.ArchiveURL.path)
    }

    func loadSpartanData()
    {
        spartans = [Spartan]()
        filteredSpartans = [Spartan]()

        favoriteSpartans = UserDefaults.standard.object(forKey: App.SettingsKeys.favoriteSpartansKey) as? [String] ?? [String]()

        // Load Saved Spartans
        if let savedSpartans = loadSpartans() {
            spartans += savedSpartans
        }

        // Filter favorites, load warzone stats
        for (_, spartan) in spartans.enumerated() {
            currentSpartanNames.append(spartan.gamerTag)

            if (favoriteSpartans.filter({ $0 == spartan.gamerTag}).count > 0) {
                filteredSpartans.append(spartan)
            }
        }
    }

    // Refresh Results
    @objc func refresh()
    {
        if (refreshNotificationPending == false) {
            var names: [String] = []

            for (_, spartan) in spartans.enumerated() {
                let safeTag = Spartan.safeGamerTag(gamerTag: spartan.gamerTag)
                names.append(safeTag)

                // Stagger requests to limit API calls
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.haloApi.requestEmblem(safeGamerTag: safeTag)
                    self.haloApi.requestAvatar(safeGamerTag: safeTag, crop: "full")
                    self.haloApi.requestProfile(safeGamerTag: safeTag)
                }
            }

            haloApi.refreshSpartans(names: names)
            haloApi.requestWarzoneStats(safeGamerTags: names)

            refreshNotificationPending = true
            refreshControl.endRefreshing()
            tableView.reloadData()
        } else {
            print("API Request Pending")
            refreshControl.endRefreshing()
        }
    }

    @IBAction func segmentValueChanged(sender: UISegmentedControl)
    {
        selectedSegmentIndex = segmentView.selectedSegmentIndex
        tableView.reloadData()
    }

    @IBAction func addSpartanAlert(sender: AnyObject)
    {
        let alertController = UIAlertController(
            title: "Enter Gamer Tag",
            message: "Enter a Spartan's Gamer Tag to retrieve their official service record from UNSC databases.",
            preferredStyle: UIAlertControllerStyle.alert
        )

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in }
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in

            // Validation - Empty Field
            if ((self.newSpartanNameField!.text!.isEmpty) == true) {
                let alertController = UIAlertController(
                    title: "UNSC Message",
                    message: "Spartan gamer tag cannot be empty",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))

                self.present(alertController, animated: true, completion: nil)
                return
            }

            // Validation - Already Added
            if (self.currentSpartanNames.contains(self.newSpartanNameField!.text!)) {
                let alertController = UIAlertController(
                    title: "UNSC Message",
                    message: "Spartan already added to roster",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))

                self.present(alertController, animated: true, completion: nil)
                return
            }

            // Validation passed, send request

            SwiftSpinner.show("Connecting to UNSC database...")

            // Dispatch after short wait for visual effect
             DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let safeTag = Spartan.safeGamerTag(gamerTag: self.newSpartanNameField!.text!)
                self.haloApi.requestNewSpartan(safeGamerTag: safeTag)
                self.haloApi.requestEmblem(safeGamerTag: safeTag)
                self.haloApi.requestAvatar(safeGamerTag: safeTag)
                self.haloApi.requestProfile(safeGamerTag: safeTag)
                self.haloApi.requestWarzoneStats(safeGamerTags: [safeTag])
            }
        })

        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextField { (textField) -> Void in
            self.newSpartanNameField = textField
        }

        present(alertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {

        for (_, spartan) in spartans.enumerated() {
            print(spartan.gamerTag)
        }

        if (segue.identifier == "showProfileSegue") {
            let indexPath = tableView.indexPathForSelectedRow
            let tabVc = segue.destination as! UITabBarController

            let profileVc = tabVc.viewControllers![0] as! ProfileViewController
            let ranksVc = tabVc.viewControllers![1] as! RankViewController
            let medalsVc = tabVc.viewControllers![2] as! MedalsViewController
            let weaponsVc = tabVc.viewControllers![3] as! WeaponsViewController
            let matchesVc = tabVc.viewControllers![4] as! MatchesViewController

            if selectedSegmentIndex == 0 {
                profileVc.selectedSpartan = spartans[indexPath!.row]
                ranksVc.selectedSpartan = spartans[indexPath!.row]
                medalsVc.selectedSpartan = spartans[indexPath!.row]
                weaponsVc.selectedSpartan = spartans[indexPath!.row]
                matchesVc.selectedSpartan = spartans[indexPath!.row]
            } else {
                profileVc.selectedSpartan = filteredSpartans[indexPath!.row]
                ranksVc.selectedSpartan = filteredSpartans[indexPath!.row]
                medalsVc.selectedSpartan = filteredSpartans[indexPath!.row]
                weaponsVc.selectedSpartan = filteredSpartans[indexPath!.row]
                matchesVc.selectedSpartan = filteredSpartans[indexPath!.row]
            }

            profileVc.favoriteSpartans = favoriteSpartans
        }
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Notification Observers
    // --------------------------------------------------------------------------------------------------

    func registerNotifcationObservers()
    {
        // Add spartan notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.retrieveNewSpartan),
            name: NSNotification.Name(rawValue: "spartanReadyForRetrieval"),
            object: nil)

        // Add spartan error notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.retrieveNewSpartanError),
            name: NSNotification.Name(rawValue: "spartanRetrievalError"),
            object: nil)

        // Bulk refresh
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.retrieveSpartansArray),
            name: NSNotification.Name(rawValue: "spartansArrayReadyForRetrieval"),
            object: nil)

        // Added From Match
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.addSpartanToRoster),
            name: NSNotification.Name(rawValue: "addSpartanToRoster"),
            object: nil)
    }

    @objc func addSpartanToRoster(_ notification: NSNotification)
    {
        loadSpartanData()

        if let player = notification.userInfo?["player"] as? Player {
            if (!self.currentSpartanNames.contains(player.gamerTag)) {
                let safeTag = Spartan.safeGamerTag(gamerTag: player.gamerTag)
                self.haloApi.requestNewSpartan(safeGamerTag: safeTag)
                self.haloApi.requestEmblem(safeGamerTag: safeTag)
                self.haloApi.requestAvatar(safeGamerTag: safeTag)
                self.haloApi.requestProfile(safeGamerTag: safeTag)
                self.haloApi.requestWarzoneStats(safeGamerTags: [safeTag])
            }
        }
    }

    // Retrieve new spartan
    @objc func retrieveNewSpartan()
    {
        self.newSpartan = self.haloApi.newSpartan
        self.newSpartan?.shouldRefershSecondaryData = true
        SwiftSpinner.show("Analyzing service record...")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.spartans.insert(self.newSpartan!, at: 0)
            self.saveSpartans()
            self.tableView.reloadData()
            SwiftSpinner.hide()
        }

        tableView.reloadData()
    }

    // Error Retrieving Spartan
    @objc func retrieveNewSpartanError()
    {
        SwiftSpinner.hide()

        let alertController = UIAlertController(
            title: "Error Occured",
            message: "Unable to locate Spartan.",
            preferredStyle: UIAlertControllerStyle.alert
        )

        let dismiss = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)

        alertController.addAction(dismiss)
        present(alertController, animated: true, completion: nil)
    }

    @objc func retrieveSpartansArray()
    {
        if (!haloApi.newSpartansArray.isEmpty) {

            let spartansCopy = spartans

            spartans = [Spartan]()
            filteredSpartans = [Spartan]()
            spartans = haloApi.newSpartansArray
            haloApi.newSpartansArray = [Spartan]()

            // update previous xp value
            for (index, spartan) in spartans.enumerated() {
                spartan.previousXp = spartansCopy[index].xp
                spartan.shouldRefershSecondaryData = true
                
                if (favoriteSpartans.filter({ $0 == spartan.gamerTag}).count > 0) {
                    filteredSpartans.append(spartan)
                }
            }

            saveSpartans()
        }

        refreshNotificationPending = false
        tableView.reloadData()
    }
}

extension RosterViewController: TableViewReorderDelegate
{
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        print("reordering...")
    }

    func tableViewDidFinishReordering(_ tableView: UITableView, from initialSourceIndexPath: IndexPath, to finalDestinationIndexPath: IndexPath)
    {
        let tmpSpartan = spartans[initialSourceIndexPath.row]
        spartans.remove(at: initialSourceIndexPath.row)
        spartans.insert(tmpSpartan, at: finalDestinationIndexPath.row)
        self.saveSpartans()
    }
}
