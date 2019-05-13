extension Double
{
    // Rounds the double to decimal places value
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        
        return Darwin.round(self * divisor) / divisor
    }
}
