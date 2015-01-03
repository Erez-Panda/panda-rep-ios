//
//  MainViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/17/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class MainViewController: UIViewController{
    
    var user:NSDictionary!
    var products: NSArray!
    var assignedTraining: NSArray?
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showProfileSegue"){
            var svc = segue.destinationViewController as ProfileViewController
            svc.user = self.user
        } else if (segue.identifier == "showTrainingSegue"){
            var svc = segue.destinationViewController as TrainingViewController
            svc.assignedTraining = self.assignedTraining
        } else if (segue.identifier == "showPreCallSegue"){
            var svc = segue.destinationViewController as PreCallViewController
            svc.user = self.user
        }
        
        
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
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let userData : AnyObject = defaultUser.objectForKey("userData") {
            self.user = userData as NSDictionary
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userName = user?["first_name"] as? String{
            welcomeLabel.text = "Welcome \(userName)"
        }
        
        ServerAPI.getProducts({result -> Void in
            self.products = result
        })
        
        
        ServerAPI.getAssignedTraining({ (result) -> Void in
            self.assignedTraining = result
        })
        
        
    }
    
    @IBAction func logout(sender: AnyObject) {
        ServerAPI.loginout({result -> Void in
            StorageUtils.cleanUserData()
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("WelcomeViewController") as WelcomeViewController
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }

}

