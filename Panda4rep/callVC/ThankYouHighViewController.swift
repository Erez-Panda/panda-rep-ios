//
//  ThankYouHighViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/8/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class ThankYouHighViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtils.borderView(closeButton, borderWidth: 1.0, borderColor: UIColor.whiteColor(), borderRadius: 3.0)
        closeButton.setAttributedTitle(ViewUtils.getAttrText("Close", color: UIColor.whiteColor(), size: 23.0, fontName: "OpenSans-Light"), forState: UIControlState.Normal)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func close(sender: AnyObject) {
        CallUtils.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
