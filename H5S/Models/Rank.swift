import SwiftyJSON

// A list of CSR designations for the title. CSR stands for Competitive Skill Rank. CSR
// is organized into a series of designations, each with a set of tiers within the
// designation. The designations are: Bronze, Silver, Gold, Platinum, Diamond, Onyx, and
// Champion. Within each designation are tiers, for example, Bronze 1, Bronze 2, Bronze
// 3, etc. The Onyx and Champion designations are special. They only have one tier. For
// non-Champion players, we keep the raw CSR value and absolute ranking hidden and show
// the CSR tier. For Onyx and Champion players, we display the raw CSR value. For
// Champion players, we show a leaderboard ranking. To determine what CSR a player has
// earned, view the Service Record stats for that player. There is no significance to the
// ordering.

class Rank
{
    var percentToNextTier: Int = 0
    var designationId: Int = 0
    var tierId: Int = 0
    var rank: Int = 0
    var csr: Int = 0
    var playlistId: String = ""
    var measurementMatchesLeft: Int = 0

    var iconUrl: String = ""
    var gameType: String = ""
    var totalGames: Int = 0
    var totalWins: Int = 0
    var totalLoses: Int = 0
    var totalTies: Int = 0
    var topPercent: Int = 0
    var totalKills: Int = 0
    var totalAssists: Int = 0
    var totalDeaths: Int = 0

    struct PropertyKeys {
        static let percentToNextTierKey = "PercentToNextTier"
        static let designationIdKey = "DesignationId"
        static let tierKey = "Tier"
        static let rankKey = "Rank"
        static let csrKey = "Csr"
    }

    let tiers = ["Unranked", "Bronze", "Silver", "Gold", "Platinum", "Diamond", "Onyx", "Champion"]

    init(csrData: JSON, playlistId: String, measurementMatchesLeft: Int)
    {
        // The percentage of progress towards the next CSR tier.
        self.percentToNextTier = csrData[PropertyKeys.percentToNextTierKey].intValue

        // The Designation of the CSR. CSR Designations are available via the
        // Metadata API.
        // Bronze, Silver, Gold, Etc
        self.designationId = csrData[PropertyKeys.designationIdKey].intValue

        // The CSR tier. CSR Tiers are designation-specific and are available via
        // the Metadata API.
        self.tierId = csrData[PropertyKeys.tierKey].intValue

        // If the CSR is Onyx or Champion, the player's leaderboard ranking. Null
        // otherwise.
        self.rank = csrData[PropertyKeys.rankKey].intValue

        // The CSR value. Zero for normal (Diamond and below) designations.
        self.csr = csrData[PropertyKeys.csrKey].intValue

        // The player's measurement matches left. If this field is greater than
        // zero, then the player will not have a CSR yet.
        self.measurementMatchesLeft = measurementMatchesLeft
    }
}

extension Rank
{
    func progressBar() -> Float
    {

        var percent = 0.0

        if self.measurementMatchesLeft > 0 {
            percent = Double(1.0 - (Float(measurementMatchesLeft) / 10.0))
        } else {
            percent = Double(1.0 - (Float(percentToNextTier) / 100.0))
        }

        return Float(percent)
    }

    func tierName() -> String
    {
        let tier = tiers[designationId]

        if  tier == "Unranked" {
            return tier
        }

        if tier == "Onyx" || tier == "Champion" {
            return tier + " " + String(self.rank)
        }

        return tiers[designationId] + " " + String(tierId)
    }

    func rankProgress() -> String
    {
        if self.measurementMatchesLeft > 0 {
            return String(self.measurementMatchesLeft) + " matches until ranked"
        } else {
            return String(self.percentToNextTier) + "% until next tier"
        }
    }
}
