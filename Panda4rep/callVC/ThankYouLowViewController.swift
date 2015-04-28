//
//  ThankYouLowViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/8/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class ThankYouLowViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UITextView!
    
    @IBOutlet weak var subTitle: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var optionFourButton: UIButton!
    @IBOutlet weak var optionThreeButton: UIButton!
    @IBOutlet weak var optionTwoButton: UIButton!
    @IBOutlet weak var optionOneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtils.borderView(sendButton, borderWidth: 1.0, borderColor: UIColor.lightGrayColor(), borderRadius: 3.0)
        sendButton.enabled = false
        titleLabel.attributedText = ViewUtils.addCenterAttr(ViewUtils.getAttrText(titleLabel.text, color: ColorUtils.buttonColor(), size: 32.0, fontName:"OpenSans-Light"))
        subTitle.attributedText = ViewUtils.addCenterAttr(ViewUtils.getAttrText(subTitle.text, color: UIColor.whiteColor(), size: 14.0))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onButtonClick(){
        optionOneButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        optionTwoButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        optionThreeButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        optionFourButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        sendButton.enabled = true
        sendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        ViewUtils.borderView(sendButton, borderWidth: 1.0, borderColor: UIColor.whiteColor(), borderRadius: 3.0)
    }
    

    @IBAction func send(sender: AnyObject) {
        //send data
        CallUtils.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    @IBAction func skip(sender: AnyObject) {
        CallUtils.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
    }

    @IBAction func optionFourSelected(sender: UIButton) {
        onButtonClick()
        sender.setTitleColor(ColorUtils.buttonColor(), forState: UIControlState.Normal)
        
    }
    @IBAction func optionThreeSelected(sender: UIButton) {
        onButtonClick()
        sender.setTitleColor(ColorUtils.buttonColor(), forState: UIControlState.Normal)
    }
    @IBAction func optionTwoSelected(sender: UIButton) {
        onButtonClick()
        sender.setTitleColor(ColorUtils.buttonColor(), forState: UIControlState.Normal)
    }
    @IBAction func optionOneSelected(sender: UIButton) {
        onButtonClick()
        sender.setTitleColor(ColorUtils.buttonColor(), forState: UIControlState.Normal)
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
