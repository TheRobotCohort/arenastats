import SwiftyJSON

class MedalsViewController: AppViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var medalsTableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!

    var medals: [Medal] = []            // Array of Spartan Medals
    var medalsAwarded: [Medal] = []     // Array of Awarded Spartan Medals
    var medalsTotals: [Medal] = []      // Array of Awarded Spartan Medals sorted by total
    var earnedMedals: [JSON] = []

    let haloApi = HaloApi()
    let test = HaloApi()

    // Metadata name of medal classification
    let sections = ["Ball", "Breakout", "CaptureTheFlag", "Infection", "KillingSpree", "MultiKill", "Oddball", "Strongholds", "Style", "Vehicles",
                    "Warzone", "WeaponProficiency"]

    // Medal classification name for UIs
    let sectionNames = ["Ball", "Breakout", "Capture The Flag", "Infection", "Killing Spree", "Multi-Kill", "Oddball", "Strongholds", "Style",
                        "Vehicles", "Warzone", "Weapon Proficiency"]

    var sectionCounts: [Int] = []
    var sectionAwardedCounts: [Int] = []
    var selectedSegmentIndex = 1

    // --------------------------------------------------------------------------------------------------
    // MARK: Lifecycle
    // --------------------------------------------------------------------------------------------------

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        loadEarnedMedals()
        loadMedalsDataSource()

        medals.sort(by: { $0.classification < $1.classification })
        medalsAwarded = medals.filter({ $0.count > 0 })
        medalsAwarded.sort(by: { $0.classification < $1.classification })
        medalsTotals = medals.filter({ $0.count > 0 })
        medalsTotals.sort(by: { $0.count > $1.count })

        for (_, section) in sections.enumerated() {
            sectionCounts.append( medals.filter({$0.classification == section}).count )
            sectionAwardedCounts.append( medalsAwarded.filter({$0.classification == section}).count )
        }

        if (medalsAwarded.count == 0) {
            segment.setEnabled(false, forSegmentAt: 1)
            segment.setEnabled(false, forSegmentAt: 2)
        }

        medalsTableView.reloadData()
        medalsTableView.delegate = self
        medalsTableView.dataSource = self
        medalsTableView.rowHeight = 165 
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Table
    // --------------------------------------------------------------------------------------------------

    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (selectedSegmentIndex == 2) {
            return 1
        }

        return sections.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "MedalHeader") as! MedalsHeaderCell
        headerCell.medalClassification.text = sectionNames[section]
        if selectedSegmentIndex == 2 {
            headerCell.isHidden = true
        } else {
            headerCell.isHidden = false
        }
        return headerCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (selectedSegmentIndex == 0) {
            return sectionCounts[section]
        } else if (selectedSegmentIndex == 1) {
            return sectionAwardedCounts[section]
        } else {
            return medalsTotals.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedalCell", for: indexPath) as! MedalsCell
        var medal: Medal

        if (selectedSegmentIndex == 0) {
            medal = medals[getRowIndex(indexPath: indexPath as NSIndexPath)]
            cell.totalAwarded.isHidden = true
        } else if (selectedSegmentIndex == 1) {
            medal = medalsAwarded[getRowIndexAwarded(indexPath: indexPath as NSIndexPath)]
            cell.totalAwarded.isHidden = false
            cell.totalAwarded.text = "x " + String(medal.count.withCommas())
        } else {
            medal = medalsTotals[indexPath.row]
            cell.totalAwarded.isHidden = false
            cell.totalAwarded.text = "x " + String(medal.count.withCommas())
        }

        cell.medalName.text = medal.name
        cell.medalDescription.text = medal.description
        cell.medalIcon.image = medal.sprite

        return cell
    }

    func getRowIndex(indexPath: NSIndexPath) -> Int
    {
        var total = 0
        var index = 0

        for (index, count) in sectionCounts.enumerated() {
            if (index < indexPath.section) {
                total = total + count
            }
        }

        if (indexPath.section != 0) {
            index = indexPath.row + total
        } else {
            index = indexPath.row
        }

        return index
    }

    func getRowIndexAwarded(indexPath: NSIndexPath) -> Int
    {
        var total = 0
        var index = 0

        for (index, count) in sectionAwardedCounts.enumerated() {
            if (index < indexPath.section) {
                total = total + count
            }
        }

        if (indexPath.section != 0) {
            index = indexPath.row + total
        } else {
            index = indexPath.row
        }

        return index
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Data Sources
    // --------------------------------------------------------------------------------------------------

    // Load stock data
    func loadMedalsDataSource()
    {
        let fileName = "medals.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json {
                    let id = subJson["id"].intValue
                    let name = subJson["name"].stringValue

                    let description = subJson["description"].stringValue
                    let classification = subJson["classification"].stringValue
                    let difficulty = subJson["difficulty"].intValue
                    let count = self.getMedalCount(medalId: subJson["id"].intValue)
                    let medal = Medal(medalId: id, count: count, description: description, name: name, classification: classification, difficulty: difficulty)
                    print("\(name) : \(id) : \(count)")
                    let sprite = Medal.createSprite(spriteLocation: subJson["spriteLocation"])
                    medal.sprite = sprite

                    medals.append(medal)
                }
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }
    }

    func loadEarnedMedals()
    {


        // Load Arena Medals
        let data = selectedSpartan.rawStats.data(using: String.Encoding.utf8)
        let json = try! JSON(data: data!)

        for (_,subJson):(String, JSON) in json["MedalAwards"] {
            earnedMedals.append(subJson)
        }


        let filename = Spartan.safeGamerTag(gamerTag: selectedSpartan.gamerTag) + "-warzone.json"
        let warzoneStatsFileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)

        if !FileManager.default.fileExists(atPath: warzoneStatsFileUrl.path) {
            print("Not found: \(warzoneStatsFileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: warzoneStatsFileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json["Results"][0]["Result"]["WarzoneStat"]["MedalAwards"] {
                    earnedMedals.append(subJson)
                }
            } catch {
                print("JSON Error at: \(warzoneStatsFileUrl.path)")
            }
        }

    }

    func getMedalCount(medalId: Int) -> Int
    {
        for (_,json) in earnedMedals.enumerated() {
            if (json["MedalId"].intValue == medalId) {
                return json["Count"].intValue
            }
        }

        return 0
    }

    @IBAction func segmentValueChanged(sender: UISegmentedControl)
    {
        selectedSegmentIndex = segment.selectedSegmentIndex
        medalsTableView.reloadData()
    }
}
