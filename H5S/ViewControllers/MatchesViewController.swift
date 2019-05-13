import SwiftyJSON

class MatchesViewController: AppViewController,  UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var matchesTableView: UITableView!

    var matches: [Match] = []        // Array of a Spartan's matches
    let haloApi = HaloApi()
    var maps: [JSON] = []
    
    // --------------------------------------------------------------------------------------------------
    // MARK: Lifecycle
    // --------------------------------------------------------------------------------------------------

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)
        loadMapsData()
        loadmatchesDataSource()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        matchesTableView.delegate = self
        matchesTableView.dataSource = self
        matchesTableView.rowHeight = 225
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Table
    // --------------------------------------------------------------------------------------------------

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return matches.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchesCell", for: indexPath) as! MatchesCell
        let match = matches[indexPath.row]

        cell.outcome.text = match.resultType()
        cell.mapName.text = match.mapName
        cell.totalKills.text = String(match.totalKills)
        cell.totalAssists.text = String(match.totalAssists)
        cell.totalDeaths.text = String(match.totalDeaths)
        cell.kda.text = String(Spartan.calcKda(kills: match.totalKills, assists: match.totalAssists, deaths: match.totalDeaths))
        cell.rank.text = String(match.rank.ordinal())
        cell.mapImage.layer.cornerRadius = 15
        cell.mapImage.clipsToBounds = true
        cell.gameTypeName.text = match.gameVariant().gameTypeName

        let dateSplit = match.matchCompletedDate.split(separator: "T")
        cell.gameTimeAgo.text = String(dateSplit[0])

        downloadImage(url: match.mapImageUrl, cell: cell)
        downloadImageIcon(url: match.gameVariant().gameTypeIcon, cell: cell)

        return cell
    }


    func numberOfSections(in tableView: UITableView) -> Int
    {
        let matchesCount = matches.count
        var sectionsCount = 0

        if matchesCount > 0 {
            tableView.separatorStyle = .singleLine
            tableView.backgroundView = nil
            tableView.separatorStyle  = .none
            sectionsCount = 1
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No Matches Found"
            noDataLabel.textColor     = UIColor.white
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return sectionsCount
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.performSegue(withIdentifier: "postMatchSegue", sender: self)
    }


    // --------------------------------------------------------------------------------------------------
    // MARK: Data Sources
    // --------------------------------------------------------------------------------------------------

    // Load stock data
    func loadmatchesDataSource()
    {
        let fileName = Spartan.safeGamerTag(gamerTag: selectedSpartan.gamerTag) + "-matches.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json["Results"] {
                    let match = Match(matchData: subJson)
                    let map = maps.filter { $0["id"].stringValue == String(match.mapId) }

                    match.mapName = map[0]["name"].stringValue
                    match.mapImageUrl = map[0]["imageUrl"].stringValue

                    matches.append(match)
                }
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }
    }

    func loadMapsData()
    {
        let fileName = "maps.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json {
                    maps.append(subJson)
                }
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }
    }

    // Async image download
    func downloadImage(url: String, cell: MatchesCell)
    {
        if let endpointUrl = URL(string: url) {
            self.haloApi.downloadDataFromUrl(url: endpointUrl, completionHandler: {
                (data, response, error) in

                DispatchQueue.main.async() { () -> Void in
                    guard let data = data, error == nil else { return }

                    cell.mapImage.image = UIImage(data: data)
                }
            })
        }
    }

    func downloadImageIcon(url: String, cell: MatchesCell)
    {
        if let endpointUrl = URL(string: url) {
            self.haloApi.downloadDataFromUrl(url: endpointUrl, completionHandler: {
                (data, response, error) in

                DispatchQueue.main.async() { () -> Void in
                    guard let data = data, error == nil else { return }
                    cell.gameIcon.image = UIImage(data: data)?.imageWithColor(newColor: UIColor.white)
                }
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "postMatchSegue") {
            let indexPath = matchesTableView.indexPathForSelectedRow
            let postMatchVc = segue.destination as! PostMatchViewController

            postMatchVc.selectedMatchId = matches[(indexPath?.row)!].matchId
            postMatchVc.selectedMatchMapUrl = matches[(indexPath?.row)!].mapImageUrl
            postMatchVc.selectedMatchGameType = matches[(indexPath?.row)!].gameVariant().gameTypeName
            postMatchVc.selectedMatchGameIcon = matches[(indexPath?.row)!].gameVariant().gameTypeIcon
            postMatchVc.selectedMatchMapName = matches[(indexPath?.row)!].mapName
            postMatchVc.selectedSpartan = selectedSpartan

        }
    }
}

