import UIKit

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    let vendors = [
            "Google-Mobile-Ads-SDK",
            "Alamofire",
            "SwiftyJSON",
            "Alamofire-SwiftyJSON",
            "SwiftSpinner",
            "ReachabilitySwift",
            "Charts",
            "EggRating",
            "SwiftyStoreKit",
            "SwiftReorder",
        ]

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

        tableView.delegate = self
        tableView.dataSource = self
    }

    // --------------------------------------------------------------------------------------------------
    // MARK: Table
    // --------------------------------------------------------------------------------------------------

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return vendors.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VendorCell", for: indexPath) as! VendorCell
        let vendor = vendors[indexPath.row]
        cell.vendorName.text = vendor
        return cell
    }

}

