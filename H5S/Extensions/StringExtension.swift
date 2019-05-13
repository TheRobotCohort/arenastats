 extension String
 {
    static func parseIso8601DurationToSeconds(iso8601: String) -> Int
    {
        let duration = String(iso8601.dropFirst())

        var d = "0"
        var h = "0"
        var m = "0"
        var s = "0"
        var totalSeconds = 0

        let split = duration.components(separatedBy: "T")

        let dayPart = split[0].components(separatedBy: "D")
        let timePart = split[1].components(separatedBy: CharacterSet (charactersIn: "HMS"))

        d = dayPart[0].isEmpty ? "0" : dayPart[0]

        if (timePart.count == 4) {
            h = timePart[0].isEmpty ? "0" : timePart[0]
            m = timePart[1].isEmpty ? "0" : timePart[1]
            s = timePart[2].isEmpty ? "0" : timePart[2]
        } else {
            // either missing M or H
            if ((split[1].range(of: "H")) != nil) {
                h = timePart[0].isEmpty ? "0" : timePart[0]
            }

            if ((split[1].range(of: "M")) != nil) {
                m = timePart[0].isEmpty ? "0" : timePart[0]
            }

            s = timePart[1].isEmpty ? "0" : timePart[1]
        }

        let seconds = (s as NSString).floatValue

        // days to seconds 86400
        totalSeconds = Int(d)! * 86400
        totalSeconds = totalSeconds + (Int(h)! * 3600)
        totalSeconds = totalSeconds + (Int(m)! * 60)
        totalSeconds = totalSeconds + Int(seconds)

        return totalSeconds
    }
    
    func timeAgoSinceDate(date:NSDate) -> String
    {
        let earliestDate = NSDate().earlierDate(date as Date)
        let latestDate = (earliestDate == NSDate() as Date) ? date : NSDate()
        let components = NSCalendar.current.dateComponents([.minute, .day, .hour, .weekOfYear, .month, .year, .second], from: earliestDate, to: latestDate as Date)

        if let year = components.year {
            if year >= 2 {
                return "\(year) years ago"
            }

            if year >= 1 {
                return "1 year ago"
            }
        }

        if  let month = components.month {
            if month >= 2 {
                return "\(month) months ago"
            }

            if month >= 1 {
                return "1 month ago"
            }
        }

        if  let weekOfYear = components.weekOfYear {
            if weekOfYear >= 2 {
                return "\(weekOfYear) weeks ago"
            }

            if weekOfYear >= 1 {
                return "1 week ago"
            }
        }

        if  let day = components.day {
            if day >= 2 {
                return "\(day) days ago"
            }

            if day >= 1 {
                return "1 day ago"
            }
        }

        if  let hour = components.hour {
            if hour >= 2 {
                return "\(hour) hours ago"
            }

            if hour >= 1 {
                return "1 day ago"
            }
        }

        if  let minute = components.minute {
            if minute >= 2 {
                return "\(minute) minutes ago"
            }

            if minute >= 1 {
                return "1 minute ago"
            }
        }

        if  let second = components.second {
            if second >= 4 {
                return "\(second) seconds ago"
            }
        }

        return "just now"
    }
 }
