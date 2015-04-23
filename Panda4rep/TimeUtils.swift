//
//  TimeUtils.swift
//  Panda4rep
//
//  Created by Erez on 12/18/14.
//  Copyright (c) 2014 Erez. All rights reserved.
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
    
    static func dateToServerString(date:NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC");
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy-MM-dd'T'HH:mm:ss", options: 0, locale: NSLocale.new())
        let stringDate = dateFormatter.stringFromDate(date)
        return stringDate
    }
}
