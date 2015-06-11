//
//  LanuchViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/5/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    //var introViewController: IntroViewController?

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    

    func showIntro(){
        dispatch_async(dispatch_get_main_queue()){
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.addChildViewController(vc)
            self.view.addSubview(vc.view)
            vc.didMoveToParentViewController(self)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        if (!NetworkUtils.isConnectedToNetwork()){
            ViewUtils.showSimpleError("This application requiers internet connection. Please connect to the internet and reopen application")
        }
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let credentials : AnyObject = defaultUser.objectForKey("credentials") {
            LoginUtils.login(credentials["username"]as! String, password: credentials["password"] as! String, sender: self, successSegue:"showHomeFromLaunch" , completion: {result -> Void in
                if (!result){
                    self.showIntro()
                }
            })
        } else {
            self.showIntro()
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
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
*/
    

}
