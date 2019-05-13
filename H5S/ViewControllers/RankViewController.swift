import SwiftyJSON
import SwiftSpinner

class RankViewController: AppViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var csrTableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    var ranks: [Rank] = []          // Array of earned Spartan Ranks from current season
    var ranksPrevious: [Rank] = []  // Array of earned Spartan Ranks from previous season
    var playlistData: [JSON] = []
    var csrData: [JSON] = []        // CSR designation meta data
    let haloApi = HaloApi()
    var selectedSegmentIndex: Int = 0

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

        loadPlaylistDataSource()
        loadCsrDataSource()
        loadSpartanRanks()

        registerNotifcationObservers()

        csrTableView.delegate = self
        csrTableView.dataSource = self
        csrTableView.rowHeight = 205
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Table
    // --------------------------------------------------------------------------------------------------

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (selectedSegmentIndex == 1) {
            return ranksPrevious.count
        }

        return ranks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankCell", for: indexPath) as! RankCell
        var rankData: Rank

        if (selectedSegmentIndex == 0) {
            // Current Season
            rankData = ranks[indexPath.row]
        } else {
            // Previous Season
            rankData = ranksPrevious[indexPath.row]
        }

        downloadImage(url: rankData.iconUrl, cell: cell)

        cell.gameType.text = rankData.gameType
        cell.tier.text = rankData.tierName()
        cell.wins.text = String(rankData.totalWins)
        cell.loses.text = String(rankData.totalLoses)
        cell.nextRankProgress.text = rankData.rankProgress()
        cell.nextRankProgressBar.progress = rankData.progressBar()
        cell.kda.text = String(Spartan.calcKda(kills: rankData.totalKills, assists: rankData.totalAssists, deaths: rankData.totalDeaths, games: rankData.totalGames))

        if rankData.topPercent <= 25 && rankData.topPercent != 0 {
            cell.topTier.text = "Top " + String(describing: rankData.topPercent) + "%!"
            cell.topTier.isHidden = false
        } else {
            cell.topTier.isHidden = true
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        var sectionsCount = 0

        if (selectedSegmentIndex == 1) {
            sectionsCount = ranksPrevious.count
        } else {
            sectionsCount = ranks.count
        }

        if sectionsCount > 0 {
            tableView.separatorStyle = .singleLine
            sectionsCount = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No CSR Data for Season"
            noDataLabel.textColor     = UIColor.white
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return sectionsCount
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Data Sources
    // --------------------------------------------------------------------------------------------------

    // Load stock data
    func loadCsrDataSource()
    {
        let fileName = "csr.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
             print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json {
                    csrData.append(subJson)
                }
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }
    }

    // Load earned ranks
    func loadSpartanRanks()
    {
        let data = selectedSpartan?.rawStats.data(using: String.Encoding.utf8)

        if (data != nil) {

            do {
                let json = try JSON(data: data!)

                // Current Season
                for (_,subJson):(String, JSON) in json["ArenaPlaylistStats"] {
                    let playlistId = subJson["PlaylistId"].stringValue
                    let measurementMatchesLeft = subJson["MeasurementMatchesLeft"].intValue
                    let rankData = Rank(csrData: subJson["Csr"], playlistId: playlistId, measurementMatchesLeft: measurementMatchesLeft)

                    let gameType = playlistData.filter { $0["id"].stringValue == playlistId }
                    let csr = self.csrData.filter { $0["id"].stringValue == String(rankData.designationId) }

                    rankData.gameType = gameType[0]["name"].stringValue
                    rankData.totalGames = subJson["TotalGamesCompleted"].intValue
                    rankData.totalLoses = subJson["TotalGamesLost"].intValue
                    rankData.totalWins = subJson["TotalGamesWon"].intValue
                    rankData.totalTies = subJson["TotalGamesTied"].intValue
                    rankData.topPercent = subJson["CsrPercentile"].intValue
                    rankData.totalKills = subJson["TotalKills"].intValue
                    rankData.totalDeaths = subJson["TotalDeaths"].intValue
                    rankData.totalAssists = subJson["TotalAssists"].intValue

                    if rankData.totalGames < 10 {
                        rankData.iconUrl = csr[0]["tiers"][rankData.totalGames]["iconImageUrl"].stringValue
                    } else {
                        rankData.iconUrl = csr[0]["tiers"][rankData.tierId - 1]["iconImageUrl"].stringValue
                    }
                    ranks.append(rankData)
                }
            } catch {
                print("uh... where'd the data go?")
            }
        }
    }

    // Load previous earned ranks from json
    func loadPreviousSpartanRanks(seasonId: String)
    {
        if ranksPrevious.count > 0 {
            return
        }

        let safeTag = Spartan.safeGamerTag(gamerTag: selectedSpartan.gamerTag)
        let fileName = safeTag + "-stats-" + seasonId + ".json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                // Previous Season
                for (_,subJson):(String, JSON) in json["Results"][0]["Result"]["ArenaStats"]["ArenaPlaylistStats"] {
                    let playlistId = subJson["PlaylistId"].stringValue
                    let measurementMatchesLeft = subJson["MeasurementMatchesLeft"].intValue
                    let rankData = Rank(csrData: subJson["Csr"], playlistId: playlistId, measurementMatchesLeft: measurementMatchesLeft)

                    let gameType = playlistData.filter { $0["id"].stringValue == playlistId }
                    let csr = self.csrData.filter { $0["id"].stringValue == String(rankData.designationId) }

                    rankData.gameType = gameType[0]["name"].stringValue
                    rankData.totalGames = subJson["TotalGamesCompleted"].intValue
                    rankData.totalLoses = subJson["TotalGamesLost"].intValue
                    rankData.totalWins = subJson["TotalGamesWon"].intValue
                    rankData.totalTies = subJson["TotalGamesTied"].intValue
                    rankData.topPercent = subJson["CsrPercentile"].intValue
                    rankData.totalKills = subJson["TotalKills"].intValue
                    rankData.totalDeaths = subJson["TotalDeaths"].intValue
                    rankData.totalAssists = subJson["TotalAssists"].intValue

                    if rankData.totalGames < 10 {
                        rankData.iconUrl = csr[0]["tiers"][rankData.totalGames]["iconImageUrl"].stringValue
                    } else {
                        rankData.iconUrl = csr[0]["tiers"][rankData.tierId - 1]["iconImageUrl"].stringValue
                    }

                    ranksPrevious.append(rankData)
                }
            } catch {
                print("uh... where'd the data go?")
            }
        }
    }

    // Load season playlist
    func loadPlaylistDataSource()
    {
        let fileName = "playlists.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json {
                    playlistData.append(subJson)
                }
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }
    }

    // Async image download
    func downloadImage(url: String, cell: RankCell)
    {
        if let endpointUrl = URL(string: url) {
            self.haloApi.downloadDataFromUrl(url: endpointUrl, completionHandler: {
                (data, response, error) in

                DispatchQueue.main.async() { () -> Void in
                    guard let data = data, error == nil else { return }
                    cell.rankIcon.image = UIImage(data: data)
                }
            })
        }
    }

    func findPreviousSeasonId() -> String?
    {
        let fileName = "seasons.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                return json[json.count - 2]["id"].stringValue

            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }

        return nil
    }

    @IBAction func segmentValueChanged(sender: UISegmentedControl)
    {
        selectedSegmentIndex = segment.selectedSegmentIndex
        let safeTag = Spartan.safeGamerTag(gamerTag: selectedSpartan.gamerTag)

        if let seasonId = findPreviousSeasonId() {
            let fileName = safeTag + "-stats-" + seasonId + ".json"
            let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.haloApi.requestStatsBySeason(safeGamerTag: Spartan.safeGamerTag(gamerTag: self.selectedSpartan.gamerTag), seasonId: seasonId)
                    SwiftSpinner.show("Requesting service record...")
                }
            } else {
                loadPreviousSpartanRanks(seasonId: seasonId)
                csrTableView.reloadData()
            }
        } else {
            print("Warning: Unable to determine previous season ID")
        }

    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Notification Observers
    // --------------------------------------------------------------------------------------------------

    func registerNotifcationObservers()
    {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.retrievePreviousStats),
            name: NSNotification.Name(rawValue: "previousSeasonStatsReady"),
            object: nil)
    }

    @objc func retrievePreviousStats()
    {
        let seasonId = findPreviousSeasonId()
        loadPreviousSpartanRanks(seasonId: seasonId!)
        SwiftSpinner.hide()
        csrTableView.reloadData()
    }

    @objc func previousSeasonStatsError()
    {
        SwiftSpinner.hide()

        let alertController = UIAlertController(
            title: "Error Occured",
            message: "Unable to retrieve previous season stats",
            preferredStyle: UIAlertControllerStyle.alert
        )

        let dismiss = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)

        alertController.addAction(dismiss)
        present(alertController, animated: true, completion: nil)
    }
}
