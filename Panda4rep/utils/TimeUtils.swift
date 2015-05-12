//
//  File.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/5/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

struct TimeUtils {
    
    static func serverDateTimeStrToDate(dateTime: String) -> NSDate{
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy-MM-dd'T'HH:mm:ss", options: 0, locale: NSLocale.new())
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
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone();
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        var readableTime = dateFormatter.stringFromDate(date)
        return readableTime
    }
    
    static func dateToReadableTimeStr(date: NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone();
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        var readableTime = dateFormatter.stringFromDate(date)
        return readableTime
    }
    
    static func dateToDateStr(date: NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone();
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        var readableTime = dateFormatter.stringFromDate(date)
        return readableTime
    }

    
    static func dateToTimeStr(date: NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone();
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        var readableTime = dateFormatter.stringFromDate(date)
        return readableTime
    }
    
    static func dateToServerString(date:NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy-MM-dd'T'HH:mm:ss", options: 0, locale: NSLocale.new())
        let stringDate = dateFormatter.stringFromDate(date)
        return stringDate
    }
    
    static func getOffsetFromUTC() -> Int{
        var minutes = NSTimeZone.localTimeZone().secondsFromGMT / 60
        return minutes/60
    }
    
    static func getDateComponentsFromDate(date: NSDate) ->NSDateComponents{
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        return cal.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
    }
    
    static func getDayInYear(date: NSDate) ->Int{
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        return cal.ordinalityOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitYear, forDate: date)
    }
    
    static func getMonthFromDate(date: NSDate) ->Int{
        let cal = NSCalendar(calendarIdentifier:NSCalendarIdentifierGregorian)!
        return cal.ordinalityOfUnit(.CalendarUnitMonth, inUnit: .CalendarUnitYear, forDate: date)
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
        let days = cal.rangeOfUnit(.CalendarUnitDay, inUnit: .CalendarUnitMonth, forDate: date)
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

