import SwiftyJSON
import SwiftSpinner

class PostMatchViewController: AppViewController,  UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var winningTeamIcon: UIImageView!
    @IBOutlet weak var gameTypeName: UILabel!
    @IBOutlet weak var mapName: UILabel!
    @IBOutlet weak var gameDuration: UILabel!
    @IBOutlet weak var gameIcon: UIImageView!
    @IBOutlet weak var spartanAccuracy: UILabel!
    @IBOutlet weak var spartanKda: UILabel!
    @IBOutlet weak var resetSorting: UIImageView!
    @IBOutlet weak var outcomeScores: UILabel!

    var selectedMatchId: String = ""
    var selectedMatchMapUrl: String = ""
    var selectedMatchGameType: String = ""
    var selectedMatchGameIcon: String = ""
    var selectedMatchMapName: String = ""

    var players = [Player]()

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

        loadMatchDetail()

        downloadImage(url: selectedMatchMapUrl)
        downloadGameImage(url: selectedMatchGameIcon)
        
        registerNotifcationObservers()

        tableView.reloadData()

        tableView.delegate = self
        tableView.dataSource = self
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Table
    // --------------------------------------------------------------------------------------------------

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostMatchCell", for: indexPath) as! PostMatchCell
        let player = players[indexPath.row]

        cell.backgroundColor = player.teamColor()

        if player.isTopGun {
            cell.topGun.isHidden = false
            cell.topGun.image = UIImage(named: "medal-top_gun")
        } else {
            cell.topGun.isHidden = true
        }

        cell.gamerTag.text = player.gamerTag
        cell.totalKills.text = String(player.totalKills)
        cell.totalAssists.text = String(player.totalAssists)
        cell.totalDeaths.text = String(player.totalDeaths)

        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let add = UITableViewRowAction(style: .normal, title: "Add to Roster") { action, index in
            let userInfoObject:[String: Player] = ["player": self.players[indexPath.row]]

            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addSpartanToRoster"), object: self, userInfo: userInfoObject)
        }

        return [add]
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Data Sources
    // --------------------------------------------------------------------------------------------------

    @objc func loadMatchDetail()
    {
        let fileName = "match-" + selectedMatchId + ".json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                HaloApi().requestMatchDetail(matchId: self.selectedMatchId);
                SwiftSpinner.show("Analyzing match detail...")
            }
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                var haveTopGun = false
                var haveCurrentSpartan = false

                for (_,subJson):(String, JSON) in json["PlayerStats"] {
                    let player = Player(playerStats: subJson, gamerTag: subJson["Player"]["Gamertag"].stringValue)
                    player.rank = subJson["Rank"].intValue

                    if haveCurrentSpartan == false {
                        if subJson["Player"]["Gamertag"].stringValue == selectedSpartan.gamerTag {
                            player.isSelectedSpartan = true
                            spartanAccuracy.text = String(player.accuracy()) + "% Accuracy"
                            spartanKda.text = "KDA: " + String(player.kda())
                            haveCurrentSpartan = true
                        }
                    }

                    if haveTopGun == false {
                        for (_, medalsJson):(String, JSON) in subJson["MedalAwards"] {
                            if medalsJson["MedalId"].intValue == 466059351 {
                                player.isTopGun = true
                                haveTopGun = true
                                break
                            }
                        }
                    }

                    players.append(player)
                }

                players.sort(by: { $0.teamId < $1.teamId })

                for (_,subJson):(String, JSON) in json["TeamStats"] {
                    if subJson["Rank"].intValue == 1 {
                        let winningTeamId = subJson["TeamId"].stringValue
                        winningTeamIcon.image = UIImage(named: "team-icon-" + winningTeamId)!
                        break
                    }
                }

                let durationString = json["TotalDuration"].stringValue
                let seconds = String.parseIso8601DurationToSeconds(iso8601: durationString)
                let time = seconds.secondsToHoursMinutesSeconds(seconds: seconds)

                gameTypeName.text = self.selectedMatchGameType
                gameDuration.text = String(time.1) + "m " + String(time.2) + "s"
                mapName.text = self.selectedMatchMapName

                if json["IsTeamGame"].boolValue == true {
                    let teamZero = json["TeamStats"][0]
                    let teamOne = json["TeamStats"][1]

                    if teamZero["Score"] > teamOne["Score"] {
                        outcomeScores.text = String(teamZero["Score"].intValue) + " to " + String(teamOne["Score"].intValue)
                    } else {
                        outcomeScores.text = String(teamOne["Score"].intValue) + " to " + String(teamZero["Score"].intValue)
                    }

                } else {
                    outcomeScores.isHidden = true
                }


                tableView.reloadData()
                SwiftSpinner.hide()
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }
    }

    // Async image download
    func downloadImage(url: String)
    {
        if let endpointUrl = URL(string: url) {
            HaloApi().downloadDataFromUrl(url: endpointUrl, completionHandler: {
                (data, response, error) in
                DispatchQueue.main.async() { () -> Void in
                    guard let data = data, error == nil else { return }
                    self.mapImage.image = UIImage(data: data)
                }
            })
        }
    }

    func downloadGameImage(url: String)
    {
        if let endpointUrl = URL(string: url) {
            HaloApi().downloadDataFromUrl(url: endpointUrl, completionHandler: {
                (data, response, error) in
                DispatchQueue.main.async() { () -> Void in
                    guard let data = data, error == nil else { return }
                    self.gameIcon.image = UIImage(data: data)?.imageWithColor(newColor: UIColor.white)
                }
            })
        }
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Notifications and Observers
    // --------------------------------------------------------------------------------------------------

    func registerNotifcationObservers()
    {
        // Match Detail Ready
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.loadMatchDetail),
            name: NSNotification.Name(rawValue: "matchDetailReady"),
            object: nil)
    }

    @objc func matchDetailError()
    {
        // show alert
        SwiftSpinner.hide()
        let alertController = UIAlertController(
            title: "UNSC Message",
            message: "Unable to retrieve match data.",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Sorting
    // --------------------------------------------------------------------------------------------------

    var spartanSortingAscending: Bool = true
    var assistsSortingAscending: Bool = true
    var deathsSortingAscending: Bool = true
    var killsSortingAscending: Bool = true

    @IBAction func spartanHeaderSort(sender: UIButton)
    {
        if spartanSortingAscending == true {
            players.sort(by: { $0.gamerTag.lowercased() > $1.gamerTag.lowercased() })
            spartanSortingAscending = false
        } else {
            players.sort(by: { $0.gamerTag.lowercased() < $1.gamerTag.lowercased() })
            spartanSortingAscending = true
        }
        tableView.reloadData()
    }

    @IBAction func assistsHeaderSort(sender: UIButton)
    {
        if spartanSortingAscending == true {
            players.sort(by: { $0.totalAssists > $1.totalAssists })
            spartanSortingAscending = false
        } else {
            players.sort(by: { $0.totalAssists < $1.totalAssists })
            spartanSortingAscending = true
        }
        tableView.reloadData()
    }

    @IBAction func deathsHeaderSort(sender: UIButton)
    {
        if spartanSortingAscending == true {
            players.sort(by: { $0.totalDeaths > $1.totalDeaths })
            spartanSortingAscending = false
        } else {
            players.sort(by: { $0.totalDeaths < $1.totalDeaths })
            spartanSortingAscending = true
        }
        tableView.reloadData()
    }

    @IBAction func killsHeaderSort(sender: UIButton)
    {
        if spartanSortingAscending == true {
            players.sort(by: { $0.totalKills > $1.totalKills })
            spartanSortingAscending = false
        } else {
            players.sort(by: { $0.totalKills < $1.totalKills })
            spartanSortingAscending = true
        }
        tableView.reloadData()
    }

    @IBAction func resetSorting(sender: UIButton)
    {
        players.sort(by: { $0.teamId < $1.teamId })


        tableView.reloadData()
    }

}
