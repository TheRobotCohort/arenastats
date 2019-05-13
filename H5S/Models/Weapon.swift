import SwiftyJSON

class Weapon
{
    var weaponId: Int = 0
    var iconUrl: String = ""
    var name: String = ""
    var type: String = ""
    var description: String = ""

    var accuracy: Double = 0.0
    var dps: Double = 0.0

    var totalShotsFired: Int = 0
    var totalShotsLanded: Int = 0
    var totalHeadShots: Int = 0
    var totalKills: Int = 0
    var totalDamageDealt: Int = 0
    var totalPosessionTime: String = ""

    init(weaponId: Int, description: String, name: String, type: String, url: String)
    {
        self.weaponId = weaponId
        self.description = description
        self.type = type
        self.name = name
        self.iconUrl = url
    }
}

extension Weapon
{
    func claculateAccuracy()
    {
        if self.totalShotsFired > 0 {

            let calc = 100 * Float(self.totalShotsLanded) / Float(self.totalShotsFired)

            var unformatted = Double(calc)
            let formated = unformatted.roundToPlaces(places: 2)

            if formated.isNaN  || calc.isInfinite == true {
                self.accuracy = 0.0
            }

            self.accuracy = formated
        } else {
            self.accuracy = 0.0
        }
    }

    func calculateDps()
    {
        let seconds = String.parseIso8601DurationToSeconds(iso8601: self.totalPosessionTime)

        if self.totalDamageDealt > 0 && seconds > 0 {
            var dps = Double(self.totalDamageDealt) / Double(seconds)
            self.dps = dps.roundToPlaces(places: 2)
        } else {
            self.dps =  0.0
        }
    }
}
