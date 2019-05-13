import SwiftyJSON

extension Spartan
{
    func loadWarzoneStats()
    {
        let filename = Spartan.safeGamerTag(gamerTag: self.gamerTag) + "-warzone.json"
        let warzoneStatsFileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)

        if !FileManager.default.fileExists(atPath: warzoneStatsFileUrl.path) {
            print("Not found: \(warzoneStatsFileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: warzoneStatsFileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                self.totalWins = self.totalWins + json["Results"][0]["Result"]["WarzoneStat"]["TotalGamesWon"].intValue
                self.totalTies = self.totalTies + json["Results"][0]["Result"]["WarzoneStat"]["TotalGamesTied"].intValue
                self.totalLoses = self.totalLoses + json["Results"][0]["Result"]["WarzoneStat"]["TotalGamesLost"].intValue

                self.totalKills = self.totalKills + json["Results"][0]["Result"]["WarzoneStat"]["TotalKills"].intValue
                self.totalAssists = self.totalAssists + json["Results"][0]["Result"]["WarzoneStat"]["TotalAssists"].intValue
                self.totalDeaths = self.totalDeaths + json["Results"][0]["Result"]["WarzoneStat"]["TotalDeaths"].intValue
                self.totalWarzoneTime = json["Results"][0]["Result"]["WarzoneStat"]["TotalTimePlayed"].stringValue
                self.totalGrenadeKills = self.totalGrenadeKills + json["Results"][0]["Result"]["WarzoneStat"]["TotalGrenadeKills"].intValue
                self.totalGroundPoundKills =  self.totalGroundPoundKills + json["Results"][0]["Result"]["WarzoneStat"]["TotalGroundPoundKills"].intValue
                self.totalMeleeKills = self.totalMeleeKills + json["Results"][0]["Result"]["WarzoneStat"]["TotalMeleeKills"].intValue
                self.totalPowerWeaponKills = self.totalPowerWeaponKills + json["Results"][0]["Result"]["WarzoneStat"]["TotalPowerWeaponKills"].intValue
                self.totalShoulderBashKills = self.totalShoulderBashKills + json["Results"][0]["Result"]["WarzoneStat"]["TotalShoulderBashKills"].intValue

                self.totalGrenadeDamage = self.totalGrenadeDamage + json["Results"][0]["Result"]["WarzoneStat"]["TotalGrenadeDamage"].intValue
                self.totalGroundPoundDamage = self.totalGroundPoundDamage + json["Results"][0]["Result"]["WarzoneStat"]["TotalGroundPoundDamage"].intValue
                self.totalMeleeDamage = self.totalMeleeDamage + json["Results"][0]["Result"]["WarzoneStat"]["TotalMeleeDamage"].intValue
                self.totalPowerWeaponDamage = self.totalPowerWeaponDamage + json["Results"][0]["Result"]["WarzoneStat"]["TotalPowerWeaponDamage"].intValue
                self.totalShoulderBashDamage = self.totalShoulderBashDamage + json["Results"][0]["Result"]["WarzoneStat"]["TotalShoulderBashDamage"].intValue
                self.totalWeaponDamage = self.totalWeaponDamage + json["Results"][0]["Result"]["WarzoneStat"]["TotalWeaponDamage"].intValue

            } catch {
                print("JSON Error at: \(warzoneStatsFileUrl.path)")
            }
        }
    }

    static func safeGamerTag(gamerTag: String) -> String
    {
        return (gamerTag.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.lowercased())!
    }

    func xpDifference() -> String
    {
        var xpDiffValue = ""
        let value = self.xp - self.previousXp

        if value > 0 && self.previousXp != 0 {
            xpDiffValue = "+" + value.withCommas()
        }

        return xpDiffValue
    }

    func profileEmblem() -> UIImage
    {
        let avatarName = Spartan.safeGamerTag(gamerTag: self.gamerTag) + "-emblem.png"
        let emblemUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(avatarName)

        let filePath = emblemUrl.path
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: emblemUrl.path)!
        }

        return UIImage(named: "spartan-emblem")!
    }

    func profileImage() -> UIImage
    {
        let avatarName = Spartan.safeGamerTag(gamerTag: self.gamerTag) + "-profile-full.png"
        let imageUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(avatarName)

        let filePath = imageUrl.path
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: imageUrl.path)!
        }

        return UIImage(named: "spartan-profile-full")!
    }

    func highestCsr() -> (iconUrl: String, bannerUrl: String)
    {
        var bannerUrl = ""
        var iconUrl = ""

        let fileName = "csr.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json {
                    if subJson["id"].stringValue == String(self.highestCsrDesignationId) {
                        bannerUrl = subJson["bannerImageUrl"].stringValue
                        if self.totalGames > 10 {
                            iconUrl = subJson["tiers"][self.highestCsrTierId - 1]["iconImageUrl"].stringValue
                        } else {
                            iconUrl = subJson["tiers"][self.totalGames]["iconImageUrl"].stringValue
                        }
                        break
                    }
                }
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }

        return (iconUrl, bannerUrl)
    }

    func companyName() -> String
    {
        var company = "Unaffiliated"

        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let profileUrl = NSURL(fileURLWithPath: path)
        let profile = Spartan.safeGamerTag(gamerTag: self.gamerTag) + "-profile.json"

        if let pathComponent = profileUrl.appendingPathComponent(profile) {
            do {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    let jsonData = NSData(contentsOfFile: pathComponent.path)
                    let json = try JSON(data: (jsonData as Data?)!)

                    company = json["Company"]["Name"].stringValue
                }
            }
            catch {
                // bad json?
            }
        }

        return company
    }

    func progressBar() -> Float
    {
        let fileName = "ranks.json"
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName)
        var ranksData = [JSON]()

        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            print("Not found: \(fileUrl.path)")
        } else {
            do {
                let jsonData = NSData(contentsOfFile: fileUrl.path)
                let json = try JSON(data: (jsonData as Data?)!)

                for (_,subJson):(String, JSON) in json {
                    ranksData.append(subJson)
                }

                let nextRank = ranksData.filter( { $0["id"].stringValue == String(Int(self.rank)! + 1) } )
                let currentRank = ranksData.filter( { $0["id"].string == String(self.rank) } )
                let nextRankStartingValue = nextRank[0]["startXp"].double!
                let currentRankStartingValue = currentRank[0]["startXp"].double!
                let percent = 100 * (Double(self.xp) - currentRankStartingValue) / (nextRankStartingValue - currentRankStartingValue)

                return Float(percent / 100.00)
            } catch {
                print("JSON Error at: \(fileUrl.path)")
            }
        }

        return 0.0
    }

    func timeAgoSinceDate(date:NSDate) -> String
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

    static func calcKda(kills: Int, assists: Int, deaths: Int, games: Int? = nil) -> Double
    {
        let games = games ?? 1

        var score = ((Double(kills) + (1/3 * Double(assists))) - Double(deaths)) / Double(games)

        return score.roundToPlaces(places: 2)
    }

    func kdaScore() -> Double
    {
        // ((Kills + (1/3 * assists)) - deaths) / # of games
        var score = ((Double(self.totalKills) + (1/3 * Double(self.totalAssists))) - Double(self.totalDeaths)) / Double(self.totalGames)

        return score.roundToPlaces(places: 3)
    }

    func kdScore() -> Double
    {
        // kills + (1/3 * assists)) - deaths
        var score = ( Double(self.totalKills) - Double(self.totalDeaths) ) / Double(self.totalGames)

        return score.roundToPlaces(places: 3)
    }

    func shotAccuracy() -> Double
    {
        var accuracy: Float = 0.0

        if (self.totalShotsFired + self.totalShotsLanded != 0) {
            accuracy = 100 * Float(self.totalShotsLanded) / Float(self.totalShotsFired)
        }

        var doubled = Double(accuracy)

        return doubled.roundToPlaces(places: 2)
    }

    func progressBarKdaValue(metric: Int) -> Float
    {
        let total = self.totalDeaths + self.totalKills + self.totalAssists
        let percent = 100 * Double(metric) / Double(total)

        return Float(percent / 100.00)
    }

    func winPercentage() -> Int
    {
        return 100 * self.totalWins / self.totalGames
    }

    func averageKillsPerGame(percent: Bool = false) -> Double
    {
        var score: Double = 0.0

        if percent == false {
            score = Double(100 * self.totalKills / self.totalGames) / 100
        } else {
            let total = Double(self.totalKills) / Double(self.totalKills + self.totalDeaths + self.totalAssists)
            score = 100 * total
        }

        return score
    }

    func averageAssistsPerGame(percent: Bool = false) -> Double
    {
        var score: Double = 0.0

        if percent == false {
            score = Double(100 * self.totalAssists / self.totalGames) / 100
        } else {
            let total = Double(self.totalAssists) / Double(self.totalKills + self.totalDeaths + self.totalAssists)
            score = 100 * total
        }

        return score
    }

    func averageDeathsPerGame(percent: Bool = false) -> Double
    {
        var score: Double = 0.0

        if percent == false {
            score = Double(100 * self.totalDeaths / self.totalGames) / 100
        } else {
            let total = Double(self.totalDeaths) / Double(self.totalKills + self.totalDeaths + self.totalAssists)
            score = 100 * total
        }

        return score
    }

    // --- Carnage

    func grenadeCarnage() -> String
    {
        return String(self.totalGrenadeDamage.withCommas()) + " (" + self.totalGrenadeKills.withCommas() + " Kills)"
    }

    func groundPoundCarnage() -> String
    {
        return String(self.totalGroundPoundDamage.withCommas()) + " (" + self.totalGroundPoundKills.withCommas() + " Kills)"
    }

    func meleeCarnage() -> String
    {
        return String(self.totalMeleeDamage.withCommas()) + " (" + self.totalMeleeKills.withCommas() + " Kills)"
    }

    func powerWeaponCarnage() -> String
    {
        return String(self.totalPowerWeaponDamage.withCommas()) + " (" + self.totalPowerWeaponKills.withCommas() + " Kills)"
    }

    func shoulderBashCarnage() -> String
    {
        return String(self.totalShoulderBashDamage.withCommas()) + " (" + self.totalShoulderBashKills.withCommas() + " Kills)"
    }

    func weaponCarnage() -> String
    {
        return String(self.totalWeaponDamage.withCommas()) + " (" + self.totalPowerWeaponKills.withCommas() + " Kills)"
    }

    // --- Progress Bar Values

    func grenadeProgressBar() -> Float
    {
        let percent = 100 * Double(self.totalGrenadeDamage) / Double(self.totalDamage)

        return Float(percent / 100.00)
    }

    func groundPoundProgressBar() -> Float
    {
        let percent = 100 * Double(self.totalGroundPoundDamage) / Double(self.totalDamage)

        return Float(percent / 100.00)
    }

    func meleeProgressBar() -> Float
    {
        let percent = 100 * Double(self.totalMeleeDamage) / Double(self.totalDamage)

        return Float(percent / 100.00)
    }

    func powerWeaponProgressBar() -> Float
    {
        let percent = 100 * Double(self.totalPowerWeaponDamage) / Double(self.totalDamage)

        return Float(percent / 100.00)
    }

    func shoulderBashProgressBar() -> Float
    {
        let percent = 100 * Double(self.totalShoulderBashDamage) / Double(self.totalDamage)

        return Float(percent / 100.00)
    }

    func weaponProgressBar() -> Float
    {
        let percent = 100 * Double(self.totalWeaponDamage) / Double(self.totalDamage)

        return Float(percent / 100.00)
    }

    func timePlayed(time: String) -> String
    {
        let duration = String(time.dropFirst())

        var d = "0"
        var h = "0"
        var m = "0"


        let split = duration.components(separatedBy: "T")

        if split.count < 2 {
            return "Unknown"
        }

        let dayPart = split[0].components(separatedBy: "D")
        let timePart = split[1].components(separatedBy: CharacterSet (charactersIn: "HMS"))

        d = dayPart[0].isEmpty ? "0" : dayPart[0]

        if (timePart.count == 4) {
            h = timePart[0].isEmpty ? "0" : timePart[0]
            m = timePart[1].isEmpty ? "0" : timePart[1]
        } else {
            // either missing M or H
            if ((split[1].range(of: "H")) != nil) {
                h = timePart[0].isEmpty ? "0" : timePart[0]
            }

            if ((split[1].range(of: "M")) != nil) {
                m = timePart[0].isEmpty ? "0" : timePart[0]
            }

        }

        return "\(d)d  \(h)h  \(m)m"
    }

}
