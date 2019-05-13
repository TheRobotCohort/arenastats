import Foundation
import UIKit

class RosterCell : UITableViewCell
{
    @IBOutlet weak var gamerTag: UILabel!
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var xp: UILabel!
    @IBOutlet weak var diffXp: UILabel!
    @IBOutlet weak var emblem: UIImageView!
    @IBOutlet weak var lastUpdatedAgo: UILabel!
    @IBOutlet weak var favorite: UILabel!
    @IBOutlet weak var xpProgressBar: UIProgressView!
}
