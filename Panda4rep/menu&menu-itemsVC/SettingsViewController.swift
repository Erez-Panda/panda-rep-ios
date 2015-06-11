//
//  SettingsViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/21/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var settings: Dictionary<String, AnyObject>?
    
    @IBOutlet weak var disableVideo: UISwitch!
    
    @IBOutlet weak var notificationByEmailSwitch: UISwitch!
    
    @IBOutlet weak var scheduleByEmailSwitch: UISwitch!
    
    @IBAction func disbaleVideoSwitch(sender: UISwitch) {
        settings?["disableVideoOnCalling"] = sender.on
        StorageUtils.saveUserSettings(settings!)
    }
    
    
    @IBAction func toggleSchedulingEmailNotification(sender: UISwitch) {
        settings?["notificationByEmail"] = sender.on
        StorageUtils.saveUserSettings(settings!)
        var data = ["send_email_conformation":sender.on] as Dictionary<String,AnyObject>
        ServerAPI.setUserEmailNotifications(data) { (result) -> Void in
            //
        }
    }
    
    
    @IBAction func toggleNotificationByEmail(sender: UISwitch) {
        settings?["scheduleByEmail"] = sender.on
        StorageUtils.saveUserSettings(settings!)
        var data = ["send_email_remainder":sender.on] as Dictionary<String,AnyObject>
        ServerAPI.setUserEmailNotifications(data) { (result) -> Void in
            //
        }
    }
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    func menu(){
        ViewUtils.slideInMenu(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtils.setBackButton(self)
        ViewUtils.setMenuButton(self)
        settings = StorageUtils.getUserSettings()
        if let NBE = settings?["notificationByEmail"] as? Bool{
            notificationByEmailSwitch.setOn(NBE, animated: false)
        } else {
            notificationByEmailSwitch.setOn(true, animated: false)
        }
        
        if let SBE = settings?["scheduleByEmail"] as? Bool{
            scheduleByEmailSwitch.setOn(SBE, animated: false)
        } else {
            scheduleByEmailSwitch.setOn(true, animated: false)
        }
        
        if let VOC = settings?["disableVideoOnCalling"] as? Bool{
            disableVideo.setOn(VOC, animated: false)
        } else {
            disableVideo.setOn(false, animated: false)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
*/

}
