import Foundation
import UIKit

class MatchesCell : UITableViewCell
{
    @IBOutlet weak var gameTypeName: UILabel!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var gameIcon: UIImageView!
    @IBOutlet weak var outcome: UILabel!
    @IBOutlet weak var gameDuration: UILabel!
    @IBOutlet weak var gameTimeAgo: UILabel!
    @IBOutlet weak var mapName: UILabel!

    @IBOutlet weak var totalKills: UILabel!
    @IBOutlet weak var totalAssists: UILabel!
    @IBOutlet weak var totalDeaths: UILabel!
    @IBOutlet weak var kda: UILabel!
    @IBOutlet weak var rank: UILabel!
    
}
