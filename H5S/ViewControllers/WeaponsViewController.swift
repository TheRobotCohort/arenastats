import SwiftyJSON

class WeaponsViewController: AppViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var weaponsTableView: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!

    var weapons = [Weapon]()        // Array of Weapons
    var weaponsData: [JSON] = []
    var selectedSegmentIndex = 0
    let haloApi = HaloApi()

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

        loadSpartanWeapons()

        weaponsTableView.delegate = self
        weaponsTableView.dataSource = self
        weaponsTableView.rowHeight = 180
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Table
    // --------------------------------------------------------------------------------------------------

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return weapons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeaponCell", for: indexPath) as! WeaponCell
        let weapon = weapons[indexPath.row]

        if selectedSegmentIndex == 1 {
             cell.sortedValue.text = String(weapon.totalDamageDealt.withCommas())
        } else if selectedSegmentIndex == 2 {
            cell.sortedValue.text = String(weapon.accuracy) + "%"
        } else {
             cell.sortedValue.text = String(weapon.totalKills.withCommas())
        }

        cell.weaponName.text = weapon.name
        cell.accuracy.text = String(weapon.accuracy) + "%"
        cell.kills.text = String(weapon.totalKills.withCommas())
        cell.damage.text = String(weapon.totalDamageDealt.withCommas())
        cell.damageSecond.text = String(weapon.dps)

        downloadImage(url: weapon.iconUrl, cell: cell)

        return cell
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Data Sources
    // --------------------------------------------------------------------------------------------------

    // Load stock data
    func loadSpartanWeapons()
    {
        weapons = [Weapon]()
        let fileName = "weapons.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        let arenaStats = selectedSpartan.rawStats.data(using: String.Encoding.utf8)
        let arenaStatsJson = try! JSON(data: arenaStats!)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,weaponJson):(String, JSON) in json {
                    if weaponJson["isUsableByPlayer"].boolValue == true {
                        let id = weaponJson["id"].intValue
                        let name = weaponJson["name"].stringValue
                        let description = weaponJson["description"].stringValue
                        let type = weaponJson["type"].stringValue
                        let url = weaponJson["largeIconImageUrl"].stringValue

                        let weapon = Weapon(weaponId: id, description: description, name: name, type: type, url: url)

                        for (_,weaponStatsJson):(String, JSON) in arenaStatsJson["WeaponStats"] {
                            if weaponStatsJson["WeaponId"]["StockId"].intValue == id {
                                weapon.totalKills = weaponStatsJson["TotalKills"].intValue
                                weapon.totalHeadShots = weaponStatsJson["TotalHeadShots"].intValue
                                weapon.totalShotsFired = weaponStatsJson["TotalShotsFired"].intValue
                                weapon.totalShotsLanded = weaponStatsJson["TotalShotsLanded"].intValue
                                weapon.totalDamageDealt = weaponStatsJson["TotalDamageDealt"].intValue
                                weapon.totalPosessionTime = weaponStatsJson["TotalPossessionTime"].stringValue
                                weapon.claculateAccuracy()
                                weapon.calculateDps()
                                break
                            }
                        }

                        weapons.append(weapon)
                    }
                }
                weapons.sort(by: { $0.totalKills > $1.totalKills })
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }
    }

    // Async image download
    func downloadImage(url: String, cell: WeaponCell)
    {
        if let endpointUrl = URL(string: url) {
            self.haloApi.downloadDataFromUrl(url: endpointUrl, completionHandler: {
                (data, response, error) in

                DispatchQueue.main.async() { () -> Void in
                    guard let data = data, error == nil else { return }
                    cell.weaponIcon.image = UIImage(data: data)
                }
            })
        }
    }

    @IBAction func segmentValueChanged(sender: UISegmentedControl)
    {
        selectedSegmentIndex = segment.selectedSegmentIndex

        if selectedSegmentIndex == 2 {
            weapons.sort(by: { $0.accuracy > $1.accuracy })
        } else if selectedSegmentIndex == 1 {
            weapons.sort(by: { $0.totalDamageDealt > $1.totalDamageDealt })
        } else {
            weapons.sort(by: { $0.totalKills > $1.totalKills })
        }

        weaponsTableView.reloadData()
    }
}
