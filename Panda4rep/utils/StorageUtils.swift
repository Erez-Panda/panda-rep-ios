//
//  StorageUtils.swift
//  Panda4doctor
//
//  Created by Erez on 1/1/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

struct StorageUtils {
    
    enum DataType : String{
        case User = "userData"
        case Profile = "userProfile"
        case Credentials = "credentials"
        case ArticleBookmark = "articleBookmarks"
        case PromotionalBookmark = "promoBookmarks"
        case ArticleRecent = "articleRecents"
        case PromotionalRecent = "promoRecents"
        case DoctorContact = "doctorContact"
    }
    
    static func cleanDictionaryNil(dictionary: NSDictionary) -> Dictionary<String, AnyObject>{
        var clean = dictionary as! Dictionary<String, AnyObject>
        for (key, value) in clean {
            if value as? String == nil {
                if value as? NSNumber == nil{
                    clean[key] = ""
                }
            }
        }
        return clean
    }

    
    static func saveUserData(userData: NSDictionary) -> Void{
        NSUserDefaults.standardUserDefaults().setObject(userData["user"], forKey: DataType.User.rawValue)
        var userInfo = userData as! Dictionary<String, AnyObject>
        userInfo = cleanDictionaryNil(userInfo)
        NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: DataType.Profile.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func updateUser(partiaUserlData: NSDictionary, type:DataType){
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if var userData : AnyObject = defaultUser.objectForKey(type.rawValue) {
            var userInfo = userData as! Dictionary<String, AnyObject>
            for (key, value) in partiaUserlData as! Dictionary<String, AnyObject> {
                userInfo[key] = value
            }
            NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: type.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static func cleanUserData() -> Void{
        ViewUtils.profileImage = nil
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func getUserData(type:DataType) -> NSMutableDictionary{
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let userProfile : AnyObject = defaultUser.objectForKey(type.rawValue) {
            return userProfile as! NSMutableDictionary
        }
        return [:]
    }
    
    static func addBookmark(type: DataType, dictionary: NSDictionary){
        var bookmarks: NSArray
        let cleanArticle = cleanDictionaryNil(dictionary)
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingBookmarks = defaultUser.objectForKey(type.rawValue) as? NSArray{
            bookmarks = existingBookmarks.arrayByAddingObject(cleanArticle)
        } else {
            bookmarks = [cleanArticle]
        }
        NSUserDefaults.standardUserDefaults().setObject(bookmarks, forKey: type.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func removeBookmark(type: DataType, id: NSNumber){
        var bookmarks: NSArray = []
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingBookmarks = defaultUser.objectForKey(type.rawValue) as? NSArray{
            for bookmark in existingBookmarks{
                if (bookmark["id"] as! NSNumber != id){
                    bookmarks = bookmarks.arrayByAddingObject(bookmark)
                }
            }
            NSUserDefaults.standardUserDefaults().setObject(bookmarks, forKey: type.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static func getBookmark(type: DataType, id: NSNumber) -> NSDictionary{
        var bookmarks: NSArray = []
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingBookmarks = defaultUser.objectForKey(type.rawValue) as? NSArray{
            for bookmark in existingBookmarks{
                if (bookmark["id"] as! NSNumber == id){
                    return bookmark as! NSDictionary
                }
            }

        }
        return [:]
    }
    
    static func getBookmarks(type: DataType) -> NSArray {
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingBookmarks = defaultUser.objectForKey(type.rawValue) as? NSArray{
            return existingBookmarks
        }
        return []
    }
    
    static func addRecent(type: DataType, dictionary: NSDictionary){
        var recents: NSArray
        let cleanDictionary = cleanDictionaryNil(dictionary)
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingRecents = defaultUser.objectForKey(type.rawValue) as? NSArray{
            if let id = dictionary["id"] as? NSNumber {
                if (!isArticleRecent(type, id: id)){
                    recents = existingRecents.arrayByAddingObject(cleanDictionary)
                } else {
                    return // no change is needed
                }
            } else {
                return // no change is needed
            }
        } else {
            recents = [cleanDictionary]
        }
        NSUserDefaults.standardUserDefaults().setObject(recents, forKey: type.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func getRecents(type: DataType) -> NSArray {
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingRecents = defaultUser.objectForKey(type.rawValue) as? NSArray{
            return existingRecents
        }
        return []
    }
    
    static func isArticleRecent(type: DataType, id: NSNumber) -> Bool{
        var recents: NSArray = []
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingRecents = defaultUser.objectForKey(type.rawValue) as? NSArray{
            for recent in existingRecents{
                if (recent["id"] as! NSNumber == id){
                    return true
                }
            }
            
        }
        return false
    }
    
    static func saveUserSettings(settings: NSDictionary){
        let defaultUser = NSUserDefaults.standardUserDefaults()
        NSUserDefaults.standardUserDefaults().setObject(cleanDictionaryNil(settings), forKey: "userSettings")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func getUserSettings() -> Dictionary<String, AnyObject>{
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let userSettings = defaultUser.objectForKey("userSettings") as? NSDictionary{
            return userSettings as! Dictionary<String, AnyObject>
        }
        return [:]
    }
    
    static func saveAllDrugs(drugs: NSArray){
        let defaultUser = NSUserDefaults.standardUserDefaults()
        let validDrugs : NSMutableArray = []
        for drug in drugs{
            if let d = drug as? NSDictionary{
                validDrugs.addObject(self.cleanDictionaryNil(drug as! NSDictionary))
            }
        }
        NSUserDefaults.standardUserDefaults().setObject(validDrugs, forKey: "drugs")
        NSUserDefaults.standardUserDefaults().setObject( Int(NSDate.new().timeIntervalSince1970), forKey: "drugs_last_update")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func getAllDrugs()-> NSArray{
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let lastUpdate = defaultUser.objectForKey("drugs_last_update") as? Int{
            if ((Int(NSDate.new().timeIntervalSince1970) - lastUpdate) > (60*60*48)){ // Check for new drugs once every two days
                return []
            }
        }
        if let drugs = defaultUser.objectForKey("drugs") as? NSArray{
            return drugs as NSArray
        }
        return []
    }
    
    static func getItems(type: DataType) -> NSArray {
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingItems = defaultUser.objectForKey(type.rawValue) as? NSArray{
            return existingItems
        }
        return []
    }
    
    static func setItems(type: DataType, items: NSArray){
        let defaultUser = NSUserDefaults.standardUserDefaults()
        var cleanItems : NSMutableArray = []
        for item in items{
            cleanItems.addObject(cleanDictionaryNil(item as! NSDictionary))
        }
        NSUserDefaults.standardUserDefaults().setObject(cleanItems, forKey: type.rawValue)
        NSUserDefaults.standardUserDefaults().setObject( Int(NSDate.new().timeIntervalSince1970), forKey: "\(type.rawValue)_last_update")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    static func addItem(type: DataType, dictionary: NSDictionary){
        var items: NSArray
        let cleanItem = cleanDictionaryNil(dictionary)
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let existingItems = defaultUser.objectForKey(type.rawValue) as? NSArray{
            if let id = cleanItem["id"] as? NSNumber{
                for i in existingItems{
                    if let i_id = i["id"] as? NSNumber{
                        if i_id == id{
                            // item already in list
                            return
                        }
                    }
                }
            }
            items = existingItems.arrayByAddingObject(cleanItem)
        } else {
            items = [cleanItem]
        }
        NSUserDefaults.standardUserDefaults().setObject(items, forKey: type.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

