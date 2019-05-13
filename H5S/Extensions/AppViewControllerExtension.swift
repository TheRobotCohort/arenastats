import EggRating

extension AppViewController: EggRatingDelegate
{
    func didRate(rating: Double) {
        print("didRate: \(rating)")
    }

    func didRateOnAppStore() {
        print("didRateOnAppStore")
    }

    func didIgnoreToRate() {
        print("didIgnoreToRate")
    }

    func didIgnoreToRateOnAppStore() {
        print("didIgnoreToRateOnAppStore")
    }
}
