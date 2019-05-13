import UIKit
import GoogleMobileAds
import EggRating

class AppViewController: UIViewController, GADBannerViewDelegate
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedSpartan: Spartan!

    // --------------------------------------------------------------------------------------------------
    // MARK: Lifecycle
    // --------------------------------------------------------------------------------------------------

    override func viewWillAppear(_ animated: Bool)
    {

    }

    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: App.SettingsKeys.hideAdsKey) == false {
            print("Should show ads")
            addBannerToView()
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        EggRating.delegate = self
        EggRating.promptRateUsIfNeeded(in: self)
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: AdMob
    // --------------------------------------------------------------------------------------------------

    func addBannerToView()
    {
        appDelegate.adBannerView.rootViewController = self
        appDelegate.adBannerView.adSize = kGADAdSizeBanner
        appDelegate.adBannerView.frame = CGRect(x: 0.0,
                                                y: view.frame.height - appDelegate.adBannerView.frame.height,
                                                width: view.frame.width,
                                                height: appDelegate.adBannerView.frame.height)
        view.addSubview(appDelegate.adBannerView)
    }
}
