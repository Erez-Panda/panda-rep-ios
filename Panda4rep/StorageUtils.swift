//
//  StorageUtils.swift
//  Panda4rep
//
//  Created by Erez on 12/25/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

struct StorageUtils {
    
    static func saveUserData(userData: NSDictionary) -> Void{
        NSUserDefaults.standardUserDefaults().setObject(userData["user"], forKey: "userData")
        var userInfo = userData as! Dictionary<String, AnyObject>
        userInfo["user"] = ""
        userInfo["medrepprofile"] = ""
        userInfo["doctorprofile"] = ""
        for (key, value) in userInfo {
            if value as? String == nil {
                userInfo[key] = ""
            }
        }
        NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: "userProfile")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func cleanUserData() -> Void{
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userData")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "credentials")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
