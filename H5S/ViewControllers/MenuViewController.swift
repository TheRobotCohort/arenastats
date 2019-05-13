import MessageUI

class MenuViewController: UITableViewController, MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var versionString: UILabel!

    // --------------------------------------------------------------------------------------------------
    // MARK: ViewController Lifecycle
    // --------------------------------------------------------------------------------------------------

    override func viewDidLoad()
    {
        super.viewDidLoad()

        versionString.text = "v" + App.APP_VERSION_STRING
    }

    @IBAction func supportAction()
    {
        let localizedModel = UIDevice().localizedModel
        let systemName = UIDevice().systemName
        let systemVersion = UIDevice().systemVersion

        if (MFMailComposeViewController.canSendMail()) {
            let body = "<p>You're awesome!</p><p>Device Info:</p>" +
                "<ul><li>App Version: \(App.APP_VERSION_STRING)</li>" +
                "<li>Model: \(localizedModel)</li>" +
                "<li>OS: \(systemName)</li>" +
                "<li>Version: \(systemVersion)</li>" +
                "<li>Removed Ads: \(UserDefaults.standard.bool(forKey: App.SettingsKeys.hideAdsKey))</li></ul>"

            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["chris@2dsquirrel.com"])
            mail.setMessageBody(body, isHTML: true)
            mail.setSubject("Arena Stats Support/Feedback")

            present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
            print("Not able to send email")
        }
    }

    @IBAction func reviewAction()
    {
        let url = URL(string: "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(App.APP_ID)")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
}
