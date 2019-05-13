import Foundation
import Alamofire
import SwiftyJSON

class HaloApiManager: NSObject
{
    static let sharedInstance = HaloApiManager()
    
    let headers = ["Ocp-Apim-Subscription-Key": App.HaloApi.SUBSCRIPTION_KEY];
    
    func makeRequest(endPointUrl: String, completionHandler: @escaping (JSON?, NSError?) -> ()) -> ()
    {
        let URL = App.HaloApi.BASE_URL + endPointUrl
        print("API: \(URL)")

        Alamofire.request(URL, headers: headers).responseJSON { response in

            switch response.result {
                case .success:
                    guard let data = response.data else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data returned"])
                        completionHandler(nil, error)
                        return
                    }

                    do {
                        let json = try JSON(data: data)
                        completionHandler(json, nil)
                    } catch {
                        print("JSON Error: \(error)")
                    }
                case .failure(let error):
                    print("Request Error: \(error)")
                    completionHandler(nil, error as NSError)
            }
        }
    }

    func makeRawRequest(endPointUrl: String, completionHandler: @escaping (NSData?, NSError?) -> ()) -> ()
    {
        let URL = App.HaloApi.BASE_URL + endPointUrl
        print("API: \(URL)")

        Alamofire.request(URL, headers: headers).responseData { response in

            switch response.result {
            case .success:
                guard let data = response.data else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data returned"])
                    completionHandler(nil, error)
                    return
                }

               completionHandler(data as NSData, nil)

            case .failure(let error):
                print("Request Error: \(error)")
                completionHandler(nil, error as NSError)
            }
        }
    }

    func makeDataRequest(endPointUrl: String, completionHandler: @escaping (NSData?, NSError?) -> ()) -> ()
    {
        print("Data Fetch: \(endPointUrl)")

        Alamofire.request(endPointUrl, headers: headers).responseData { response in

            switch response.result {
            case .success:
                guard let data = response.data else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data returned"])
                    completionHandler(nil, error)
                    return
                }

                completionHandler(data as NSData, nil)

            case .failure(let error):
                print("Request Error: \(error)")
                completionHandler(nil, error as NSError)
            }
        }
    }
}

