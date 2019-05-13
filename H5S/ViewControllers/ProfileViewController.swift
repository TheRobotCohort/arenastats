import SwiftSpinner
import Charts

class ProfileViewController: AppViewController
{
    // Profile View
    @IBOutlet weak var totalGamesLabel: UILabel!
    @IBOutlet weak var winRateLabel: UILabel!
    @IBOutlet weak var gamerTagLabel: UILabel!
    @IBOutlet weak var serviceRankLabel: UILabel!
    @IBOutlet weak var emblemImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var highestCsrRankImage: UIImageView!
    @IBOutlet weak var highestCsrBannerImage: UIImageView!

    // Overall Totals View
    @IBOutlet weak var totalKillsValue: UILabel!
    @IBOutlet weak var totalAssistsValue: UILabel!
    @IBOutlet weak var totalDeathsValue: UILabel!
    @IBOutlet weak var totalKillsProgressBar: UIProgressView!
    @IBOutlet weak var totalAssistsProgressBar: UIProgressView!
    @IBOutlet weak var totalDeathsProgressBar: UIProgressView!
    @IBOutlet weak var totalTies: UILabel!
    @IBOutlet weak var totalWins: UILabel!
    @IBOutlet weak var totalLoses: UILabel!
    @IBOutlet weak var xpProgressBar: UIProgressView!
    @IBOutlet weak var xpProgressBarLabel: UILabel!
    @IBOutlet weak var currentCsr: UILabel!
    @IBOutlet weak var nextCsr: UILabel!
    @IBOutlet weak var shotAccuracy: UILabel!

    // Per-Game Averages View
    @IBOutlet weak var kdaView: UIView!
    @IBOutlet weak var averageKill: UILabel!
    @IBOutlet weak var averageAssists: UILabel!
    @IBOutlet weak var averageDeaths: UILabel!
    @IBOutlet weak var kdaScore: UILabel!
    @IBOutlet weak var kdScore: UILabel!

    // Damage Spread
    @IBOutlet weak var totalGrenadeDamage: UILabel!
    @IBOutlet weak var totalGroundPoundDamage: UILabel!
    @IBOutlet weak var totalMeleeDamage: UILabel!
    @IBOutlet weak var totalPowerWeapons: UILabel!
    @IBOutlet weak var totalShoulderBashDamage: UILabel!
    @IBOutlet weak var totalWeaponDamage: UILabel!
    @IBOutlet weak var totalDamageLabel: UILabel!

    @IBOutlet weak var grenadeProgressBar: UIProgressView!
    @IBOutlet weak var groundPoundProgressBar: UIProgressView!
    @IBOutlet weak var meleeProgressBar: UIProgressView!
    @IBOutlet weak var powerWeaponProgressBar: UIProgressView!
    @IBOutlet weak var shoulderBashProgressBar: UIProgressView!
    @IBOutlet weak var weaponProgressBar: UIProgressView!

    // Competition
    @IBOutlet weak var playTimeArenaValueLabel: UILabel!
    @IBOutlet weak var playTimeWarzoneValueLabel: UILabel!

    let haloApi = HaloApi()
    var favButton: UIBarButtonItem?
    var favoriteSpartans: [String] = []

    // KDA
    let kdaPieChart: PieChartView = {
        let p = PieChartView()
        p.centerText = ""
        p.chartDescription?.text = ""
        p.legend.enabled = false
        p.translatesAutoresizingMaskIntoConstraints = false
        p.noDataText = "No date to display"

        return p
    }()

    // --------------------------------------------------------------------------------------------------
    // MARK: Lifecycle
    // --------------------------------------------------------------------------------------------------

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)
        selectedSpartan.loadWarzoneStats()
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tabBarController?.title  = selectedSpartan?.gamerTag
        favButton = UIBarButtonItem(image: UIImage(named: "icon-star"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.makeFavorite))

        if (!favoriteSpartans.contains(selectedSpartan.gamerTag)) {
            favButton!.tintColor = UIColor.gray
        } else {
            favButton!.tintColor = UIColor(red: 223.0/255.0, green: 148.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        }

        self.tabBarController?.navigationItem.rightBarButtonItem = favButton

        if selectedSpartan.shouldRefershSecondaryData == true {
            print("Refreshing spartan secondary data")
            haloApi.requestMatchHistory(safeGamerTag: Spartan.safeGamerTag(gamerTag: selectedSpartan.gamerTag))
            selectedSpartan.shouldRefershSecondaryData = false
        }

        SwiftSpinner.show("Analyzing service record...")



        profileViewData()
        overallViewData()
        gameAveragesViewData()
        setupKdaPieChart()
        fillKdaChart()
        damageViewData()
        competitionViewData()


         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            SwiftSpinner.hide()
        }
    }

    @objc func makeFavorite()
    {
        let name = selectedSpartan?.gamerTag

        if (favoriteSpartans.contains(name!)) {
            favoriteSpartans = favoriteSpartans.filter({$0 != name})
            favButton!.tintColor = UIColor.gray
        } else {
            favoriteSpartans.append(name!)
            favButton!.tintColor = UIColor(red: 223.0/255.0, green: 148.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        }

        UserDefaults.standard.set(favoriteSpartans, forKey: App.SettingsKeys.favoriteSpartansKey)
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Pie Charts
    // --------------------------------------------------------------------------------------------------

    func setupKdaPieChart()
    {
        kdaView.addSubview(kdaPieChart)

        var multiplier = 0.8

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            multiplier = 0.3
        }

        kdaPieChart.centerXAnchor.constraint(equalTo: kdaView.centerXAnchor, constant: 0).isActive = true
        kdaPieChart.centerYAnchor.constraint(equalTo: kdaView.centerYAnchor, constant: 0).isActive = true
        kdaPieChart.widthAnchor.constraint(equalTo: kdaView.widthAnchor, multiplier: CGFloat(multiplier)).isActive = true
        kdaPieChart.heightAnchor.constraint(equalTo: kdaView.widthAnchor, multiplier: CGFloat(multiplier)).isActive = true
    }

    func fillKdaChart()
    {

        let surveyData = [
                "Kills": selectedSpartan.averageKillsPerGame(percent: true),
                "Assists": selectedSpartan.averageAssistsPerGame(percent: true),
                "Deaths": selectedSpartan.averageDeathsPerGame(percent: true),
            ]

        var dataEntries = [PieChartDataEntry]()

        for (_, val) in surveyData {
            let entry = PieChartDataEntry(value: val, label: " % ")
            dataEntries.append(entry)
        }

        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        chartDataSet.sliceSpace = 2
        chartDataSet.selectionShift = 10
        chartDataSet.colors = ChartColorTemplates.material()
        chartDataSet.colors[1] = UIColor.init(netHex: 0x90be5e) // Kills
        chartDataSet.colors[0] = UIColor.init(netHex: 0x019ec2) // Assists
        chartDataSet.colors[2] = UIColor.init(netHex: 0xe93722) // Deaths

        kdaPieChart.data = PieChartData(dataSet: chartDataSet)
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Data Population
    // --------------------------------------------------------------------------------------------------

    func profileViewData()
    {
        gamerTagLabel.text = selectedSpartan.gamerTag
        serviceRankLabel.text = "SR " + selectedSpartan.rank
        emblemImage.image = selectedSpartan.profileEmblem()
        profileImage.image = selectedSpartan.profileImage()
        totalGamesLabel.text = String(selectedSpartan.totalGames.withCommas()) + " Total Games"
        winRateLabel.text = String(selectedSpartan.winPercentage()) + "%"
        companyName.text = selectedSpartan.companyName()

        let highestCsrData = selectedSpartan.highestCsr()
        downloadImage(url: highestCsrData.iconUrl, image: highestCsrRankImage)
        downloadImage(url: highestCsrData.bannerUrl, image: highestCsrBannerImage)
    }

    func overallViewData()
    {
        xpProgressBar.progress = selectedSpartan.progressBar()
        xpProgressBarLabel.text = String(selectedSpartan.xp.withCommas())
        totalKillsValue.text = String(selectedSpartan.totalKills.withCommas())
        totalAssistsValue.text = String(selectedSpartan.totalAssists.withCommas())
        totalDeathsValue.text = String(selectedSpartan.totalDeaths.withCommas())
        totalTies.text = String(selectedSpartan.totalTies.withCommas())
        totalWins.text = String(selectedSpartan.totalWins.withCommas())
        totalLoses.text = String(selectedSpartan.totalLoses.withCommas())
        totalKillsProgressBar.progress = selectedSpartan.progressBarKdaValue(metric: selectedSpartan.totalKills)
        totalAssistsProgressBar.progress = selectedSpartan.progressBarKdaValue(metric: selectedSpartan.totalAssists)
        totalDeathsProgressBar.progress = selectedSpartan.progressBarKdaValue(metric: selectedSpartan.totalDeaths)
        currentCsr.text = selectedSpartan.rank
        nextCsr.text = String(Int(selectedSpartan.rank)! + 1)
        shotAccuracy.text = String(selectedSpartan.shotAccuracy()) + "%"
    }

    func gameAveragesViewData()
    {
        kdaScore.text = String(selectedSpartan.kdaScore())
        kdScore.text = String(selectedSpartan.kdScore())
        averageKill.text = String(selectedSpartan.averageKillsPerGame())
        averageAssists.text = String(selectedSpartan.averageAssistsPerGame())
        averageDeaths.text = String(selectedSpartan.averageDeathsPerGame())
    }

    func damageViewData()
    {
        totalGrenadeDamage.text = selectedSpartan.grenadeCarnage()
        totalGroundPoundDamage.text = selectedSpartan.groundPoundCarnage()
        totalMeleeDamage.text = selectedSpartan.meleeCarnage()
        totalPowerWeapons.text = selectedSpartan.powerWeaponCarnage()
        totalShoulderBashDamage.text = selectedSpartan.shoulderBashCarnage()
        totalWeaponDamage.text = selectedSpartan.weaponCarnage()
        totalDamageLabel.text = String(selectedSpartan.totalDamage.withCommas()) + " Total Damage Dealt"

        grenadeProgressBar.progress = selectedSpartan.grenadeProgressBar()
        groundPoundProgressBar.progress = selectedSpartan.groundPoundProgressBar()
        meleeProgressBar.progress = selectedSpartan.meleeProgressBar()
        powerWeaponProgressBar.progress = selectedSpartan.powerWeaponProgressBar()
        shoulderBashProgressBar.progress = selectedSpartan.shoulderBashProgressBar()
        weaponProgressBar.progress = selectedSpartan.weaponProgressBar()
    }

    func competitionViewData()
    {
        playTimeArenaValueLabel.text = selectedSpartan.timePlayed(time: selectedSpartan.totalArenaTime)
        playTimeWarzoneValueLabel.text = selectedSpartan.timePlayed(time: selectedSpartan.totalWarzoneTime)
    }

    // Async image download
    func downloadImage(url: String, image: UIImageView)
    {
        if let endpointUrl = URL(string: url) {
            HaloApi().downloadDataFromUrl(url: endpointUrl, completionHandler: {
                (data, response, error) in

                DispatchQueue.main.async() { () -> Void in
                    guard let data = data, error == nil else { return }
                    image.image = UIImage(data: data)
                }
            })
        }
    }
}
