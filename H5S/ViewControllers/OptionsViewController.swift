import UIKit
import SwiftyStoreKit

class OptionsViewController: UIViewController
{
    @IBOutlet weak var menuButton:UIBarButtonItem!

    let productRemoveAd = "arenastats.adremove"

    // --------------------------------------------------------------------------------------------------
    // MARK: Lifecycle
    // --------------------------------------------------------------------------------------------------

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Slider Menu
        if (self.revealViewController() != nil) {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))

            self.revealViewController().rearViewRevealWidth = 95
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    @IBAction func purchaseAdRemoval()
    {
        print("Purchase attempt")

        let alertController = UIAlertController(
            title: "Ad Removal Purchase",
            message: "",
            preferredStyle: UIAlertControllerStyle.alert
        )

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            // ?
        }))

        SwiftyStoreKit.purchaseProduct(productRemoveAd, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaults.standard.set(true, forKey: App.SettingsKeys.hideAdsKey)
                
                alertController.message = "Thank you!!"
                self.present(alertController, animated: true, completion: nil)

            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                }
            }
        }
    }

    @IBAction func restoreAdRemovalPurchase()
    {
        print("Purchase restore attempt")

        let alertController = UIAlertController(
            title: "Ad Removal Purchase",
            message: "",
            preferredStyle: UIAlertControllerStyle.alert
        )

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            // ?
        }))


        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                alertController.message = "Restore Failed: \(results.restoreFailedPurchases)"
                self.present(alertController, animated: true, completion: nil)
                print("Restore Failed: \(results.restoreFailedPurchases)")
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                alertController.message = "Ad removal restored"
                self.present(alertController, animated: true, completion: nil)
                UserDefaults.standard.set(true, forKey: App.SettingsKeys.hideAdsKey)
            } else {
                alertController.message = "Nothing to restore"
                print("Nothing to Restore")
                self.present(alertController, animated: true, completion: nil)
            }
        }


    }
}
