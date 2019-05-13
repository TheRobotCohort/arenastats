import SwiftyJSON

class Match
{
    var matchId: String = ""
    var isTeamGame: Bool = false
    var mapId: String = ""
    var matchCompletedDate: String = ""
    var matchDuration: String = ""
    var gameModeId: Int = 0
    var result: Int = 0
    var totalKills: Int = 0
    var totalDeaths: Int = 0
    var totalAssists: Int = 0
    var teamId: Int = 0
    var rank: Int = 0
    var gameVariantId: String = ""
    var mapName: String = ""
    var mapImageUrl: String = ""

    struct PropertyKeys {
        static let matchIdKey = "MatchId"
        static let isTeamGameKey = "IsTeamGameId"
        static let mapIdKey = "MapId"
        static let matchCompletedDateKey = "MatchCompletedDate"
        static let matchDurationKey = "MatchDuration"
        static let gameModeIdKey = "GameMode"
        static let resultKey = "Result"
        static let totalKillsKey = "TotalKills"
        static let totalAssistsKey = "TotalAssists"
        static let totalDeathsKey = "TotalDeaths"
        static let teamIdKey = "TeamId"
        static let rankKey = "Rank"
        static let gameVariantKey = "GameBaseVariantId"
    }

    init(matchData: JSON)
    {
        self.matchId = matchData["Id"][PropertyKeys.matchIdKey].stringValue
        self.isTeamGame = matchData[PropertyKeys.isTeamGameKey].boolValue
        self.mapId = matchData[PropertyKeys.mapIdKey].stringValue
        self.gameVariantId = matchData[PropertyKeys.gameVariantKey].stringValue
        self.matchCompletedDate = matchData[PropertyKeys.matchCompletedDateKey]["ISO8601Date"].stringValue
        self.matchDuration = matchData[PropertyKeys.matchDurationKey].stringValue
        self.gameModeId = matchData["Id"][PropertyKeys.gameModeIdKey].intValue
        self.result = matchData["Players"][0][PropertyKeys.resultKey].intValue
        self.rank = matchData["Players"][0][PropertyKeys.rankKey].intValue
        self.teamId = matchData["Players"][0][PropertyKeys.teamIdKey].intValue
        self.totalDeaths = matchData["Players"][0][PropertyKeys.totalDeathsKey].intValue
        self.totalAssists = matchData["Players"][0][PropertyKeys.totalAssistsKey].intValue
        self.totalKills = matchData["Players"][0][PropertyKeys.totalKillsKey].intValue
    }
}

extension Match
{
    func resultType() -> String
    {
        if self.result == 0 {
            return "Did Not Finish"
        }

        if self.result == 1 {
            return "Lost"
        }

        if self.result == 2 {
            return "Tied"
        }

        if self.result == 3 {
            return "Won"
        }

        return "Unknown"
    }

    func gameVariant() -> (gameTypeName: String, gameTypeIcon: String)
    {
        var gameType = "Unknown"
        var gameTypeIcon = "https://content.halocdn.com/media/Default/games/halo-5-guardians/game-type-icons/slayer-b92fd67142834e4d825322f2404d7753.png"

        let fileName = "game-base-variants.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json {
                    if subJson["id"].stringValue == String(self.gameVariantId) {
                        gameType = subJson["name"].stringValue
                        gameTypeIcon = subJson["iconUrl"].stringValue
                    }
                }
            }
            catch {
                // bad json?
            }
        }

        return (gameType, gameTypeIcon)
    }

    static func timeAgoSinceDate(date:NSDate) -> String
    {
        let earliestDate = NSDate().earlierDate(date as Date)
        let latestDate = (earliestDate == NSDate() as Date) ? date : NSDate()
        let components = NSCalendar.current.dateComponents([.minute, .day, .hour, .weekOfYear, .month, .year, .second], from: earliestDate, to: latestDate as Date)

        if let year = components.year {
            if year >= 2 {
                return "\(year) years ago"
            }

            if year >= 1 {
                return "1 year ago"
            }
        }

        if  let month = components.month {
            if month >= 2 {
                return "\(month) months ago"
            }

            if month >= 1 {
                return "1 month ago"
            }
        }

        if  let weekOfYear = components.weekOfYear {
            if weekOfYear >= 2 {
                return "\(weekOfYear) weeks ago"
            }

            if weekOfYear >= 1 {
                return "1 week ago"
            }
        }

        if  let day = components.day {
            if day >= 2 {
                return "\(day) days ago"
            }

            if day >= 1 {
                return "1 day ago"
            }
        }

        if  let hour = components.hour {
            if hour >= 2 {
                return "\(hour) hours ago"
            }

            if hour >= 1 {
                return "1 day ago"
            }
        }

        if  let minute = components.minute {
            if minute >= 2 {
                return "\(minute) minutes ago"
            }

            if minute >= 1 {
                return "1 minute ago"
            }
        }

        if  let second = components.second {
            if second >= 4 {
                return "\(second) seconds ago"
            }
        }

        return "just now"
    }
}
