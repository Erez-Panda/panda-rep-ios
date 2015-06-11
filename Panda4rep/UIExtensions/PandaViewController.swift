//
//  PandaViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/20/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class PandaViewController: UIViewController {
    func back(){
        if ( self == (self.navigationController?.viewControllers  as! [UIViewController])[0]){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    func menu(){
        ViewUtils.slideInMenu(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtils.setBackButton(self)
        ViewUtils.setMenuButton(self)
        

        // Do any additional setup after loading the view. 
    }
    
    override func viewWillAppear(animated: Bool) {
        if let t  = self.title {
            //GAIUtils.sendScreenUsage(t)
        }
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
