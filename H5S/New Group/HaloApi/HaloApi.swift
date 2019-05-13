import Foundation
import SwiftyJSON

class HaloApi: NSObject
{
    var newSpartan: Spartan!
    var lastErrorCode: Int = 0
    var newSpartansArray: [Spartan] = []
    var matchDetail: JSON = []
    
    func requestNewSpartan(safeGamerTag: String)
    {
        let endPoint = "stats/h5/servicerecords/arena?players=" + safeGamerTag

        let completionHandler:(JSON?, NSError?) -> () = {
            json, error in

            if (json != nil) {
                let gamerTag = json!["Results"][0]["Result"]["PlayerId"]["Gamertag"].stringValue

                // We sometimes get an empty object if the spartan wasn't found.
                if (gamerTag.isEmpty) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spartanRetrievalError"), object: nil)
                }

                let rank = json!["Results"][0]["Result"]["SpartanRank"].stringValue
                let xp = json!["Results"][0]["Result"]["Xp"].intValue
                let arenaStats = json!["Results"][0]["Result"]["ArenaStats"].rawString()
                let dateRetrieved = NSDate()

                if (!gamerTag.isEmpty) {
                    self.newSpartan = Spartan(gamerTag: gamerTag, rank: rank, xp: xp, dateRetreived: dateRetrieved, rawStats: arenaStats!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spartanReadyForRetrieval"), object: nil)
                }
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spartanRetrievalError"), object: nil)
            }
            
        }

        HaloApiManager().makeRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func requestStatsBySeason(safeGamerTag: String, seasonId: String)
    {
        let endPoint = "stats/h5/servicerecords/arena?players=" + safeGamerTag + "&seasonId=" + seasonId

        let completionHandler:(JSON?, NSError?) -> () = {
            json, error in

            if (json != nil) {
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

                do {
                    try FileManager.default.createFile(atPath: "\(path)/\(safeGamerTag + "-stats-" + seasonId + ".json")", contents: json?.rawData(), attributes: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "previousSeasonStatsReady"), object: nil)
                } catch {
                    print("JSON Error: \(error)")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "previousSeasonStatsError"), object: nil)
                }

            } else {
                print("Response Error: \(String(describing: error))")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "previousSeasonStatsError"), object: nil)
            }
        }

        HaloApiManager().makeRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func requestMatchDetail(matchId: String)
    {
        let endPoint = "stats/h5/arena/matches/" + matchId

        let completionHandler:(JSON?, NSError?) -> () = {
            json, error in

            if (json != nil) {
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

                do {
                    try FileManager.default.createFile(atPath: "\(path)/match-" + matchId + ".json", contents: json?.rawData(), attributes: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "matchDetailReady"), object: nil)
                } catch {
                    print("JSON Error: \(error)")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "matchDetailError"), object: nil)
                }

            } else {
                print("Response Error: \(String(describing: error))")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "matchDetailError"), object: nil)
            }
        }

        HaloApiManager().makeRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func requestProfile(safeGamerTag: String)
    {
        let endPoint = "profile/h5/profiles/" + safeGamerTag + "/appearance"

        let completionHandler:(JSON?, NSError?) -> () = {
            json, error in

            if (json != nil) {
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                do {
                    try FileManager.default.createFile(atPath: "\(path)/\(safeGamerTag + "-profile.json")", contents: json?.rawData(), attributes: nil)
                } catch {
                    print("JSON Error: \(error)")
                }

            } else {
                print("Response Error: \(String(describing: error))")
            }
        }

        HaloApiManager().makeRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func requestWarzoneStats(safeGamerTags: [String])
    {
        let completionHandler:(JSON?, NSError?) -> () = {
            json, error in

            print("API Response Received")

            if (json != nil) {
                let results = json!["Results"]

                for (_, result) in results {
                    let gamerTag = result["Result"]["PlayerId"]["Gamertag"].stringValue

                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                    let safeGamerTag = Spartan.safeGamerTag(gamerTag: gamerTag)

                    do {
                       try FileManager.default.createFile(atPath: "\(path)/\(safeGamerTag + "-warzone.json")", contents: json?.rawData(), attributes: nil)
                    } catch {
                        print("JSON Error")
                    }
                }
            } else {
                print("Response Error: \(String(describing: error))")
            }
        }

        let endPoint = "stats/h5/servicerecords/warzone?players=" + safeGamerTags.joined(separator: ",")

        HaloApiManager().makeRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func requestMatchHistory(safeGamerTag: String)
    {
        let endPoint = "stats/h5/players/" + safeGamerTag + "/matches?modes=arena,warzone"

        let completionHandler:(JSON?, NSError?) -> () = {
            json, error in

            if (json != nil) {
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                do {
                    try FileManager.default.createFile(atPath: "\(path)/\(safeGamerTag + "-matches.json")", contents: json?.rawData(), attributes: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "secondaryDataRequestComplete"), object: nil)

                } catch {
                    print("JSON Error: \(error)")
                }

            } else {
                print("Response Error: \(String(describing: error))")
            }
        }

        HaloApiManager().makeRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func requestEmblem(safeGamerTag: String, size: String = "256")
    {
        let endPoint = "profile/h5/profiles/" + safeGamerTag + "/emblem?size=" + size

        let completionHandler:(NSData?, NSError?) -> () = {
            data, error in

            if (data != nil) {
                let avatarName = safeGamerTag + "-emblem.png"
                let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(avatarName)

                do {
                    try data?.write(to: fileURL, options: .atomic)
                } catch {
                    print(error)
                }
            } else {
                print("Response Error: \(String(describing: error))")
            }
        }

        HaloApiManager().makeRawRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func requestAvatar(safeGamerTag: String, size: String = "256", crop: String = "full")
    {
        let endPoint = "profile/h5/profiles/" + safeGamerTag + "/spartan?size=" + size + "&crop=" + crop

        let completionHandler:(NSData?, NSError?) -> () = {
            data, error in

            if (data != nil) {
                let avatarName = safeGamerTag + "-profile-full.png"
                let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(avatarName)

                do {
                    try data?.write(to: fileURL, options: .atomic)
                } catch {
                    print(error)
                }
            } else {
                print("Response Error: \(String(describing: error))")
            }
        }

        HaloApiManager().makeRawRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func refreshMetaData()
    {
        // End-points for resources
        let urls = [
            "metadata/h5/metadata/playlists",
            "metadata/h5/metadata/csr-designations",
            "metadata/h5/metadata/weapons",
            "metadata/h5/metadata/spartan-ranks",
            "metadata/h5/metadata/medals",
            "metadata/h5/metadata/maps",
            "metadata/h5/metadata/game-base-variants",
            "metadata/h5/metadata/seasons",
        ]

        // Filenames to save resources as (same order as urls)
        let filenames = [
            "playlists.json",
            "csr.json",
            "weapons.json",
            "ranks.json",
            "medals.json",
            "maps.json",
            "game-base-variants.json",
            "seasons.json"
        ]

        for (index, endPoint) in urls.enumerated() {
            let completionHandler:(JSON?, NSError?) -> () = {
                json, error in

                if (json != nil) {
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                    do {
                        try FileManager.default.createFile(atPath: "\(path)/\(filenames[index])", contents: json?.rawData(), attributes: nil)
                    } catch {
                        print("JSON Error: \(error)")
                    }

                } else {
                    print("Response Error: \(String(describing: error))")
                }
            }
            HaloApiManager().makeRequest(endPointUrl: endPoint, completionHandler: completionHandler)
        }
    }

    func refreshSpartans(names: [String])
    {
        let completionHandler:(JSON?, NSError?) -> () = {
            json, error in

            if (json != nil) {
                let results = json!["Results"]

                for (_, result) in results {
                    let gamerTag = result["Result"]["PlayerId"]["Gamertag"].stringValue
                    let rank = result["Result"]["SpartanRank"].stringValue
                    let xp = result["Result"]["Xp"].intValue
                    let arenaStats = result["Result"]["ArenaStats"].rawString()
                    let dateRetrieved = NSDate()
                    
                    self.newSpartansArray.append(Spartan(gamerTag: gamerTag, rank: rank, xp: xp, dateRetreived: dateRetrieved, rawStats: arenaStats!)!)
                }

                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "spartansArrayReadyForRetrieval"), object: nil)
            }
        }

        let endPoint = "stats/h5/servicerecords/arena?players=" + names.joined(separator: ",")
        HaloApiManager().makeRequest(endPointUrl: endPoint, completionHandler: completionHandler)
    }

    func downloadDataFromUrl(url: URL, completionHandler: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error? ) -> Void))
    {
        let filename = url.lastPathComponent
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(filename)

        // if the file already exists, just return it
        if FileManager.default.fileExists(atPath: fileUrl.path) == true {
            do {
                let data = try Data(contentsOf:fileUrl)
                completionHandler(data, nil, nil)
            } catch {
                print("Error: have \(filename) but couldn't open it")
            }

        } else {
            URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                print("URL Request: \(url.absoluteString)")
                FileManager.default.createFile(atPath: fileUrl.path, contents: data, attributes: nil)
                completionHandler(data, response, error)
            }.resume()
        }
    }
}
