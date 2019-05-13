extension Int
{
    func withCommas() -> String
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal

        return numberFormatter.string(from: NSNumber(value:self))!
    }

    func ordinal() -> String
    {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal

        return formatter.string(from: NSNumber(value: self))!
    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int)
    {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
