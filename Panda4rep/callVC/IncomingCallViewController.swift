//
//  IncomingCallViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/6/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class IncomingCallViewController: UIViewController {

    
    @IBOutlet weak var drugTextView: UITextView!
    @IBOutlet weak var callerName: UILabel!
    @IBOutlet weak var callerImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        CallUtils.incomingViewController = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        callerImage.layoutIfNeeded()
        if let caller = CallUtils.currentCall?["caller"] as? NSDictionary{
            let firstName = (caller["user"] as? NSDictionary)?["first_name"] as! String
            let lastName = (caller["user"] as? NSDictionary)?["last_name"] as! String
            callerName.attributedText = ViewUtils.getAttrText("\(firstName) \(lastName)", color: UIColor.whiteColor(), size: 22.0)
            if let imageFileId = caller["image_file"] as? NSNumber{
                ViewUtils.getImageFile(imageFileId, completion: { (result) -> Void in
                    //self.callerImage.image = result
                })
            }
            
        }
        if let product = CallUtils.currentCall?["product"] as? NSDictionary {
            let name = product["name"] as! String
            let text = "Your \(name) expert is ready to start call"
            let attrText = ViewUtils.getAttrText(text, color: UIColor.whiteColor(), size: 20.0)
            let p: NSMutableParagraphStyle = NSMutableParagraphStyle()
            p.alignment = NSTextAlignment.Center
            attrText.addAttribute(NSParagraphStyleAttributeName, value: p, range: NSMakeRange(0,count(text)))
            drugTextView.attributedText = attrText
        }
        ViewUtils.roundView(callerImage, borderWidth: 3.0, borderColor: ColorUtils.uicolorFromHex(0x7E7C89))
        self.view.addSubview(ViewUtils.addRoundBorderView(callerImage, borderWidth: 2.0, borderColor: ColorUtils.uicolorFromHex(0x575665), boderSpacing: 8.0))
        self.view.addSubview(ViewUtils.addRoundBorderView(callerImage, borderWidth: 1.0, borderColor: ColorUtils.uicolorFromHex(0x474658), boderSpacing: 20.0))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func closeSelf(sender: AnyObject) {
        CallUtils.stopCall()
        self.dismissViewControllerAnimated(true, completion: {
            CallUtils.incomingViewController = nil
        })
    }
    @IBAction func startCall(sender: AnyObject) {
        CallUtils.getCallViewController()?.showIncoming = false
        self.presentViewController(CallUtils.getCallViewController()!, animated: true, completion: nil)
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
