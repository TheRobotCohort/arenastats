import Foundation
import UIKit

class RankCell : UITableViewCell
{
    @IBOutlet weak var rankIcon: UIImageView!
    @IBOutlet weak var tier: UILabel!
    @IBOutlet weak var gameType: UILabel!
    @IBOutlet weak var wins: UILabel!
    @IBOutlet weak var loses: UILabel!
    @IBOutlet weak var totalGames: UILabel!
    @IBOutlet weak var nextRankProgress: UILabel!
    @IBOutlet weak var nextRankProgressBar: UIProgressView!
    @IBOutlet weak var kda: UILabel!
    @IBOutlet weak var topTier: UILabel!
}
