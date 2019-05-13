import UIKit
import SwiftyJSON

class Spartan: NSObject, NSCoding
{
    // --------------------------------------------------------------------------------------------------
    // MARK: Properties
    // --------------------------------------------------------------------------------------------------

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent(App.SPARTAN_ARCHIVE)

    var gamerTag: String = ""
    var rank: String = ""
    var xp: Int = 0
    var previousXp: Int = 0
    var dateRetreived: NSDate
    var rawStats: String = ""
    var shouldRefershSecondaryData: Bool = false

    var totalGames: Int = 0
    var totalWins: Int = 0
    var totalTies: Int = 0
    var totalLoses: Int = 0
    var totalKills: Int = 0
    var totalAssists: Int = 0
    var totalDeaths: Int = 0

    var totalShotsFired: Int = 0
    var totalShotsLanded: Int = 0

    var totalArenaTime: String = ""
    var totalWarzoneTime: String = ""

    var totalDamage: Int = 0
    var totalGrenadeDamage: Int = 0
    var totalGroundPoundDamage: Int = 0
    var totalMeleeDamage: Int = 0
    var totalPowerWeaponDamage: Int = 0
    var totalShoulderBashDamage: Int = 0
    var totalWeaponDamage: Int = 0

    var totalGrenadeKills: Int = 0
    var totalGroundPoundKills: Int = 0
    var totalMeleeKills: Int = 0
    var totalPowerWeaponKills: Int = 0
    var totalShoulderBashKills: Int = 0
    var totalWeaponKills: Int = 0

    var highestCsrTierId: Int = 0
    var highestCsrDesignationId: Int = 0

    struct PropertyKey {
        static let gamerTagKey = "gamerTag"
        static let rankKey = "rank"
        static let xpKey = "xp"
        static let dateRetreivedKey = "dateRetreived"
        static let rawStatsKey = "rawStats"
    }
    
    // --------------------------------------------------------------------------------------------------
    // MARK: Init
    // --------------------------------------------------------------------------------------------------

    init?(gamerTag: String, rank: String, xp: Int, dateRetreived: NSDate, rawStats: String)
    {
        self.gamerTag = gamerTag
        self.rank = rank
        self.xp = xp
        self.dateRetreived = dateRetreived
        self.rawStats = rawStats

        super.init()

        if (gamerTag.isEmpty) {
            return nil
        }

        let encodedString : Data = (rawStats as NSString).data(using: String.Encoding.utf8.rawValue)!
        let jsonStats = try! JSON(data: encodedString as Data)

        self.totalGames = jsonStats["TotalGamesCompleted"].intValue
        self.totalWins = jsonStats["TotalGamesWon"].intValue
        self.totalTies = jsonStats["TotalGamesTied"].intValue
        self.totalLoses = jsonStats["TotalGamesLost"].intValue
        self.totalKills = jsonStats["TotalKills"].intValue
        self.totalAssists = jsonStats["TotalAssists"].intValue
        self.totalDeaths = jsonStats["TotalDeaths"].intValue

        self.totalShotsFired = jsonStats["TotalShotsFired"].intValue
        self.totalShotsLanded = jsonStats["TotalShotsLanded"].intValue

        self.totalArenaTime = jsonStats["TotalTimePlayed"].stringValue

        self.totalGrenadeKills = jsonStats["TotalGrenadeKills"].intValue
        self.totalGroundPoundKills = jsonStats["TotalGroundPoundKills"].intValue
        self.totalMeleeKills = jsonStats["TotalMeleeKills"].intValue
        self.totalPowerWeaponKills = jsonStats["TotalPowerWeaponKills"].intValue
        self.totalShoulderBashKills = jsonStats["TotalShoulderBashKills"].intValue

        self.highestCsrTierId = jsonStats["HighestCsrAttained"]["Tier"].intValue
        self.highestCsrDesignationId = jsonStats["HighestCsrAttained"]["DesignationId"].intValue

        self.totalGrenadeDamage = jsonStats["TotalGrenadeDamage"].intValue
        self.totalGroundPoundDamage = jsonStats["TotalGroundPoundDamage"].intValue
        self.totalMeleeDamage = jsonStats["TotalMeleeDamage"].intValue
        self.totalPowerWeaponDamage = jsonStats["TotalPowerWeaponDamage"].intValue
        self.totalShoulderBashDamage = jsonStats["TotalShoulderBashDamage"].intValue
        self.totalWeaponDamage = jsonStats["TotalWeaponDamage"].intValue

        self.totalDamage = totalGrenadeDamage + totalGroundPoundDamage + totalMeleeDamage + totalPowerWeaponDamage + totalShoulderBashDamage + totalWeaponDamage
    }

    required convenience init?(coder aDecoder: NSCoder)
    {
        let gamerTag = aDecoder.decodeObject(forKey: PropertyKey.gamerTagKey) as! String
        let rank = aDecoder.decodeObject(forKey: PropertyKey.rankKey) as! String
        let xp = aDecoder.decodeObject(forKey: PropertyKey.xpKey) as! Int
        let dateRetreived = aDecoder.decodeObject(forKey: PropertyKey.dateRetreivedKey) as! NSDate
        let rawStats = aDecoder.decodeObject(forKey: PropertyKey.rawStatsKey) as! String

        self.init(gamerTag: gamerTag, rank: rank, xp: xp, dateRetreived: dateRetreived,
            rawStats: rawStats)
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Encode Spartan
    // --------------------------------------------------------------------------------------------------
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(gamerTag, forKey: PropertyKey.gamerTagKey)
        aCoder.encode(rank, forKey: PropertyKey.rankKey)
        aCoder.encode(xp as NSNumber, forKey: PropertyKey.xpKey)
        aCoder.encode(dateRetreived, forKey: PropertyKey.dateRetreivedKey)
        aCoder.encode(rawStats, forKey: PropertyKey.rawStatsKey)
    }
}
