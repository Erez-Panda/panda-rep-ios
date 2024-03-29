//
//  AppDelegate.swift
//  Panda4rep
//
//  Created by Erez on 12/16/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit
//import Dropbox_iOS_SDK


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginDelegate, UIAlertViewDelegate {

    var window: UIWindow?
    var token: String?
    var homeVC: HomeViewController?
    var preCallId: NSNumber?
    var inquiryId: NSNumber?
    var inquiry: NSDictionary?
    var showPreCallAlert: Bool = true



    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = ColorUtils.uicolorFromHex(0xffffff)
        navigationBarAppearace.barTintColor = ColorUtils.mainColor()
        // change navigation item title color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGrayColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: ColorUtils.buttonColor()], forState:.Selected)
        
        // Override point for customization after application launch.
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl.backgroundColor = UIColor.whiteColor()
        
        // Register for Push Notitications, if running iOS 8
        if application.respondsToSelector("registerUserNotificationSettings:") {
            
            let types:UIUserNotificationType = ([.Alert, .Badge, .Sound])
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
                if let callId = notificationPayload["call_id"] as? NSNumber{
                    dispatch_async(dispatch_get_main_queue()){
                        self.openPreCallScreen(callId)
                    }
                }
                if let inquiry = notificationPayload["inquiry"] as? NSNumber{
                    dispatch_async(dispatch_get_main_queue()){
                        self.inquiry = notificationPayload
                        self.openInquiryScreen(inquiry)
                    }
                }
                if nil != notificationPayload["canceled_call_id"] as? NSNumber{
                    self.updateHomeScreen()
                }
                
                
            }
        }
       
        
        //DROP_BOX
        let dbSession = DBSession(appKey: "l6c99wtstnvvhuq", appSecret: "a4hgzua2blamg7u", root: kDBRootDropbox)
        DBSession.setSharedSession(dbSession)
        //DBSession.sharedSession().unlinkAll()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "homeScreenReady:", name: "HomeScreenReady", object: nil)
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let urlParams = url.getKeyVals()
        if let callId = urlParams?["call_id"]{
            let f = NSNumberFormatter()
            f.numberStyle = NSNumberFormatterStyle.DecimalStyle
            if let id = f.numberFromString(callId){
                openPreCallScreen(id, showAlert: false)
            }
            
        }
        
        if DBSession.sharedSession().handleOpenURL(url){
            if DBSession.sharedSession().isLinked(){
                print("App linked successfully!")
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
        homeVC?.updateCallsAndOffers()
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
        print(error, terminator: "")
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
        if let callId = userInfo["call_id"] as? NSNumber{
            dispatch_async(dispatch_get_main_queue()){
                self.openPreCallScreen(callId)
            }
        }
        if let inquiry = userInfo["inquiry"] as? NSNumber{
            self.inquiry = userInfo
            self.openInquiryScreen(inquiry)
        }
        
        if nil != userInfo["canceled_call_id"] as? NSNumber{
            if let topvc = ViewUtils.getTopViewController(){
                if let pName = userInfo["product_name"] as? String{
                    let alert = UIAlertController(title: "Call Cancelled", message: "A call about \(pName) was cancelled", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    topvc.presentViewController(alert, animated: true, completion: nil)
                }
            }
            self.updateHomeScreen()
        }
        
        if nil != userInfo["call_update"] as? NSNumber{
            self.updateHomeScreen(userInfo)
        }
        /*
        if let type = userInfo["type"] as? String{
            if type == "new_training"{
                let rootViewController = self.window!.rootViewController
                let tvc = rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("TrainingViewController") as! TrainingViewController
                let a = rootViewController?.presentedViewController
                if let nvc = a as? UINavigationController{
                    dispatch_async(dispatch_get_main_queue()){
                        nvc.pushViewController(tvc, animated: true)
                    }
                }
            }
        }
*/
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex == 0){ //Accept
            ViewUtils.startGlobalLoader()
            if let offerId: AnyObject = (alertView as! UIAlertViewWithData).data?["offer_id"] {
                ServerAPI.acceptCallOffer(offerId as! NSNumber, completion: {result -> Void in
                    if let error = result["error"] as? String{
                        dispatch_async(dispatch_get_main_queue()){
                            ViewUtils.showSimpleError(error)
                        }
                    }
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "CallOfferOffered", object: (alertView as! UIAlertViewWithData).data))
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
        let readableTime = TimeUtils.dateToReadableStr(date)
        let acceptCallAlert = UIAlertViewWithData()
        acceptCallAlert.title = "New Call Offer"
        if let creator = userInfo["creator_name"] as? String{
            acceptCallAlert.message = "\(creator) has requested a call about \(product) on \(readableTime).\nWould you like to accept it?"
        } else {
            acceptCallAlert.message = "Call about \(product) will take place on \(readableTime), Would you like to accept it?"
        }
        if let reschedule = userInfo["reschedule"] as? Bool{
            if reschedule {
                acceptCallAlert.title = "Call Reschedule Offer"
            }
        }
        
        acceptCallAlert.addButtonWithTitle("Accept")
        acceptCallAlert.addButtonWithTitle("Cancel")
        acceptCallAlert.delegate = self
        acceptCallAlert.data = ["offer_id": offerId, "start": start]
        acceptCallAlert.show()
        
        //        var rootViewController = self.window!.rootViewController
        //        let alert = UIAlertController(title: "Title", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
        //        alert.addAction(UIAlertAction(title: "Button", style: UIAlertActionStyle.Default, handler: nil))
        //        rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showIncomingCallAlert(callId: NSNumber, showAlert: Bool = true){
        if (CallUtils.session?.sessionConnectionStatus == OTSessionConnectionStatus.NotConnected || CallUtils.session == nil){
            if let topvc = ViewUtils.getTopViewController(){
                if showAlert{
                    let alert = UIAlertController(title: "Call Time", message: "You have a scheduled call starting now", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Call Screen", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        if let vc = self.homeVC {
                            vc.navigationController?.popToRootViewControllerAnimated(false)
                            vc.openPreCallById(callId)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Ignore", style: UIAlertActionStyle.Default, handler: nil))
                    topvc.presentViewController(alert, animated: true, completion: nil)
                } else {
                    if let vc = self.homeVC {
                        ViewUtils.startGlobalLoader()
                        vc.updateCallsAndOffers(false, complition: { (result) -> Void in
                            ViewUtils.stopGlobalLoader()
                            vc.navigationController?.popToRootViewControllerAnimated(false)
                            vc.openPreCallById(callId)
                        })
                    }
                }
            }
        }
    }
    
    func homeScreenReady(notification: NSNotification){
        if let vc = notification.object as? HomeViewController{
            homeVC = vc
            if let id = preCallId{
                openPreCallScreen(id, showAlert: showPreCallAlert)
            }
            if let id = inquiryId{
                openInquiryScreen(id)
            }
        }
    }
    
    func openPreCallScreen(id: NSNumber, showAlert: Bool = true){
        if nil != self.homeVC {
            showIncomingCallAlert(id, showAlert: showAlert)
        } else {
            showPreCallAlert = showAlert
            preCallId = id
        }
    }
    
    func updateHomeScreen(updatedCall: NSDictionary? = nil){
        if let vc = self.homeVC {
            if let info = updatedCall {
                vc.updateCallStatus(info["call_update"] as! NSNumber, status: info["status"] as! String)
            } else {
                vc.pullRefresh(UIButton())
            }
        }
    }
    
    func openInquiryScreen(id: NSNumber){
        if nil != self.homeVC {
            if (CallUtils.session?.sessionConnectionStatus == OTSessionConnectionStatus.NotConnected || CallUtils.session == nil){
                if let topvc = ViewUtils.getTopViewController(){
                    var title = "New Medical Inquiry"
                    var message = "Would you like to respond?"
                    if let inquiry = self.inquiry {
                        if let product = inquiry["product_name"] as? String{
                            title += " about \(product)"
                        }
                        if let creator = inquiry["creator_name"] as? String{
                            if var text = inquiry["inquiry_text"] as? String{
                                text = text.stringByReplacingOccurrencesOfString("\n", withString: " ", options: [], range: nil)
                                message = "Dr. \(creator):\n\"\(text)\"\n\n" + message
                            }
                        }
                    }
                    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        ViewUtils.startGlobalLoader()
                        ServerAPI.respondtoMedicalInquiry(id, data: ["active":false], completion: { (result) -> Void in
                            ViewUtils.stopGlobalLoader()
                            if let error = result["error"] as? String{
                                dispatch_async(dispatch_get_main_queue()){
                                    ViewUtils.showSimpleError(error)
                                }
                            } else if let vc = self.homeVC {
                                dispatch_async(dispatch_get_main_queue()){
                                    vc.navigationController?.popToRootViewControllerAnimated(false)
                                    let inqVc = vc.storyboard?.instantiateViewControllerWithIdentifier("inquiryDisplay") as! InquiryDisplayViewController
                                    inqVc.inquiry = result
                                    vc.navigationController?.pushViewController(inqVc, animated: true)
                                }
                            }
                        })
                        
                    }))
                    alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (result) -> Void in
                        //Decline
                    }))
                    topvc.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
        } else {
            inquiryId = id
        }
    }


}

