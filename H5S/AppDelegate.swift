import UIKit
import GoogleMobileAds
import EggRating
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GADBannerViewDelegate
{
    var window: UIWindow?
    var adBannerView = GADBannerView()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Initialize Google Mobile Ads SDK
        adBannerView.adUnitID = App.Ads.ADMOB_UNIT_ID
        adBannerView.delegate = self
        adBannerView.load(GADRequest())
        adBannerView.isHidden = true

        // App Rating
        EggRating.itunesId = String(App.APP_ID)
        EggRating.minRatingToAppStore = Double(App.APP_MIN_RATING)
        EggRating.daysUntilPrompt = 2
        EggRating.remindPeriod = 2
        EggRating.debugMode = false

        // Ad Removal Purchase
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    break
                }
            }
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("Ad received")
        adBannerView.isHidden = false
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("Failed to receive ad")
        print(error)
        adBannerView.isHidden = true
    }
}
