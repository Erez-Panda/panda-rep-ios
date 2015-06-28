//
//  AppDelegate.swift
//  Panda4rep
//
//  Created by Erez on 12/16/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit
import Dropbox_iOS_SDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginDelegate, UIAlertViewDelegate {

    var window: UIWindow?
    var token: String?



    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        var navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = ColorUtils.uicolorFromHex(0xffffff)
        navigationBarAppearace.barTintColor = ColorUtils.mainColor()
        // change navigation item title color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGrayColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: ColorUtils.buttonColor()], forState:.Selected)
        
        // Override point for customization after application launch.
        var pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.whiteColor()
        
        // Register for Push Notitications, if running iOS 8
        if application.respondsToSelector("registerUserNotificationSettings:") {
            
            let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        } 
        if let launchOpts = launchOptions {
            if let notificationPayload = launchOpts[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary{
                if ((notificationPayload["offer_id"]) != nil){
                    dispatch_async(dispatch_get_main_queue()){
                        self.showAcceprCallAlert(notificationPayload)
                    }
                }
            }
        }
       
        
        //DROP_BOX
        let dbSession = DBSession(appKey: "l6c99wtstnvvhuq", appSecret: "a4hgzua2blamg7u", root: kDBRootDropbox)
        DBSession.setSharedSession(dbSession)
        //DBSession.sharedSession().unlinkAll()
        
        
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if DBSession.sharedSession().handleOpenURL(url){
            if DBSession.sharedSession().isLinked(){
                println("App linked successfully!")
            }
            return true
        }
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if CallUtils.subscriber == nil {
            CallUtils.stopCall() //meaning sidconnect from session
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let app = UIApplication.sharedApplication()
        app.applicationIconBadgeNumber = 0
        app.cancelAllLocalNotifications()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        self.token = tokenString
        ServerAPI.delegate = self
    }
    

    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func loginComplete() {
        ServerAPI.sendDeviceToken(self.token!)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if ((userInfo["offer_id"]) != nil){
            dispatch_async(dispatch_get_main_queue()){
                self.showAcceprCallAlert(userInfo)
            }
        }
        if let type = userInfo["type"] as? String{
            if type == "new_training"{
                var rootViewController = self.window!.rootViewController
                let tvc = rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("TrainingViewController") as! TrainingViewController
                let a = rootViewController?.presentedViewController
                if let nvc = a as? UINavigationController{
                    dispatch_async(dispatch_get_main_queue()){
                        nvc.pushViewController(tvc, animated: true)
                    }
                }
            }
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        println(buttonIndex)
        if (buttonIndex == 0){ //Accept
            if let offerId: AnyObject = (alertView as! UIAlertViewWithData).data?["offer_id"] {
                ServerAPI.acceptCallOffer(offerId as! NSNumber, completion: {result -> Void in
                    if let error = result["error"] as? String{
                        dispatch_async(dispatch_get_main_queue()){
                            ViewUtils.showSimpleError(error)
                        }
                    }
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "CallOfferOffered", object: nil))
                })
            }
        } else if (buttonIndex == 1){ //Cancel
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "CallOfferOffered", object: nil))
        }
    }
    
    func showAcceprCallAlert(userInfo: AnyObject){
        let product = userInfo["product"] as! String
        let start = userInfo["start"] as! String
        let offerId = userInfo["offer_id"] as! NSNumber
        

        let date = TimeUtils.serverDateTimeStrToDate(start)
        var readableTime = TimeUtils.dateToReadableStr(date)
        var acceptCallAlert = UIAlertViewWithData()
        
        acceptCallAlert.title = "New Call Offer"
        acceptCallAlert.message = "Call about \(product) will take place on \(readableTime), Would you like to accept it?"
        acceptCallAlert.addButtonWithTitle("Accept")
        acceptCallAlert.addButtonWithTitle("Cancel")
        acceptCallAlert.delegate = self
        acceptCallAlert.data = ["offer_id": offerId]
        acceptCallAlert.show()
        
        //        var rootViewController = self.window!.rootViewController
        //        let alert = UIAlertController(title: "Title", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
        //        alert.addAction(UIAlertAction(title: "Button", style: UIAlertActionStyle.Default, handler: nil))
        //        rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }


}

