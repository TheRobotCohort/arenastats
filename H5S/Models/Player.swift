import SwiftyJSON

class Player
{
    var totalKills: Int = 0
    var totalAssists: Int = 0
    var totalDeaths: Int = 0
    var totalHeadShots: Int = 0
    var totalWeaponDamage: Double = 0.0
    var totalShotsFired: Int = 0
    var totalShotsLanded: Int = 0
    var teamId: Int = 0
    var gamerTag: String = ""
    var isSelectedSpartan: Bool = false
    var isTopGun: Bool = false
    var rank: Int = 0

    init(playerStats: JSON, gamerTag: String)
    {
        self.gamerTag = gamerTag
        self.teamId = playerStats["TeamId"].intValue

        self.totalKills = playerStats["TotalKills"].intValue
        self.totalAssists = playerStats["TotalAssists"].intValue
        self.totalDeaths = playerStats["TotalDeaths"].intValue
        self.totalShotsLanded = playerStats["TotalShotsLanded"].intValue
        self.totalShotsFired = playerStats["TotalShotsFired"].intValue
        self.totalWeaponDamage = playerStats["TotalWeaponDamage"].doubleValue
        self.totalHeadShots = playerStats["TotalHeadShots"].intValue
    }
}

extension Player
{
    func teamColor() -> UIColor
    {
        // Red
        if self.teamId == 0 {
             return UIColor.init(netHex: 0xb00000)

        // Blue
        } else if self.teamId == 1 {
            return UIColor.init(netHex: 0x178dd8)

        // Yellow
        } else if self.teamId == 2 {
            return UIColor.init(netHex: 0xe1d002)

        // Green
        } else if self.teamId == 3 {
            return UIColor.init(netHex: 0x027d1a)

        // Purple
        } else if self.teamId == 4 {
            return UIColor.init(netHex: 0x533377)

        // Magenta
        } else if self.teamId == 5 {
            return UIColor.init(netHex: 0xe30ab1)
            
        // Orange
        } else if self.teamId == 6 {
            return UIColor.init(netHex: 0x9f4e19)
        }

        return UIColor.init(netHex: 0x223d57)
    }

    func kda() -> Double
    {
        // ((Kills + (1/3 * assists)) - deaths) / # of games
        var score = ((Double(self.totalKills) + (1/3 * Double(self.totalAssists))) - Double(self.totalDeaths)) / 1

        return score.roundToPlaces(places: 3)
    }

    func accuracy() -> Double
    {
        let accuracy = 100 * Float(self.totalShotsLanded) / Float(self.totalShotsFired)
        var rounded = Double(accuracy)
        return rounded.roundToPlaces(places: 2)
    }
}
