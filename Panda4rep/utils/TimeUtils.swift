//
//  File.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/5/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

struct TimeUtils {
    
    static func serverDateTimeStrToDate(dateTime: String) -> NSDate{
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy-MM-dd'T'HH:mm:ss", options: 0, locale: nil)
        var date = dateFormatter.dateFromString(dateTime)
        if date == nil {
            var str = dateTime.stringByReplacingOccurrencesOfString("T", withString: " ")
            str = str.stringByReplacingOccurrencesOfString("Z", withString: "")
            str = str.stringByPaddingToLength(19, withString: "", startingAtIndex: 0)
            date = dateFormatter.dateFromString(str)
        }
        return date!
    }
    
    static func dateToReadableStr(date: NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone();
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let readableTime = dateFormatter.stringFromDate(date)
        return readableTime
    }
    
    static func dateToReadableTimeStr(date: NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone();
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let readableTime = dateFormatter.stringFromDate(date)
        return readableTime
    }
    
    static func dateToDateStr(date: NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone();
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let readableTime = dateFormatter.stringFromDate(date)
        return readableTime
    }

    
    static func dateToTimeStr(date: NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone();
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let readableTime = dateFormatter.stringFromDate(date)
        return readableTime
    }
    
    static func dateToServerString(date:NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy-MM-dd'T'HH:mm:ss", options: 0, locale: nil)
        let stringDate = dateFormatter.stringFromDate(date)
        return stringDate
    }
    
    static func getOffsetFromUTC() -> Int{
        let minutes = NSTimeZone.localTimeZone().secondsFromGMT / 60
        return minutes/60
    }
    
    static func getDateComponentsFromDate(date: NSDate) ->NSDateComponents{
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        return cal.components([.Year, .Month, .Day], fromDate: date)
    }
    
    static func getDayInYear(date: NSDate) ->Int{
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        return cal.ordinalityOfUnit(.Day, inUnit: .Year, forDate: date)
    }
    
    static func getMonthFromDate(date: NSDate) ->Int{
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        return cal.ordinalityOfUnit(.Month, inUnit: .Year, forDate: date)
    }
    
    static func getDateFromComponents(year: Int, month: Int?, day: Int) -> NSDate{
        let comp = NSDateComponents()
        comp.day = day
        if let m = month{
            comp.month = m
        }
        comp.year = year
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        return cal.dateFromComponents(comp)!
    }
    
    static func getMonthNumberOfDays(month: Int, year: Int)-> Int{
        let date = self.getDateFromComponents(year, month: month, day: 15)
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        let days = cal.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        return days.length
    }
    
    static func getYearNumberOfDays(year: Int)-> Int{
        var days = 0
        for var month = 1; month < 13; month++ {
            days += self.getMonthNumberOfDays(month, year: year)
        }
        return days
    }
}

