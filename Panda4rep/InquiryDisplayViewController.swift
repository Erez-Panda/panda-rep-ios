//
//  InquiryDisplayViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 8/5/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class InquiryDisplayViewController: PandaViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var inquiryTextView: UITextView!
    @IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var responseLabel: UILabel!
    @IBOutlet weak var inquiryLabel: UILabel!
    var inquiry : NSDictionary?
    let responseDefaultText = "Write your response here"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShown:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        ViewUtils.addDoneToolBarToKeyboard(self.responseTextView, vc: self)
        
        if let text = inquiry?["inquiry"] as? String {
            inquiryTextView.text = text
        }
        
        if let product = inquiry?["product"] as? NSDictionary {
            if let name = product["name"] as? String{
                productTitleLabel.text = name
            }
        }
        
        if let text = inquiry?["inquiry"] as? String {
            inquiryTextView.text = text
        }
        
        if let creator = inquiry?["creator"] as? NSDictionary{
            if let user = creator["user"] as? NSDictionary{
                if let name = user["last_name"] as? String{
                    inquiryLabel.text = "Inquiry from Dr. \(name):"
                }
            }
        }

        // Do any additional setup after loading the view.
    }
    
    func keyboardWillShown(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        let screenHeight = UIScreen.mainScreen().bounds.height
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            let frame = self.responseLabel.layer.presentationLayer().frame
            //self.view.frame.origin.y  -= max(0,(keyboardSize.height+frame.origin.y+frame.height) - screenHeight)
            if (keyboardSize.height+frame.origin.y+frame.height > screenHeight){
                self.scrollView.contentOffset.y = frame.origin.y
            }
        })
        
    }
    
    func keyboardWillHide(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0
            self.scrollView.contentOffset.y = 0
        })
    }
    
    func doneButtonClickedDismissKeyboard() {
        self.responseTextView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == responseDefaultText && textView == responseTextView{
            textView.text = ""
        }
        textView.textColor = UIColor.blackColor()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" && textView == responseTextView{
            responseTextView.text = self.responseDefaultText
            textView.textColor = UIColor.lightGrayColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func send(sender: AnyObject) {
        if count(responseTextView.text) > 0 {
            var data = ["response": responseTextView.text,
            "request": inquiry!["id"] as! NSNumber,
            "product": (inquiry!["product"] as! NSDictionary)["id"] as! NSNumber] as Dictionary<String, AnyObject>
            ServerAPI.sendMedicalInquiryResponse(data, completion: { (result) -> Void in
                //
            })
            self.navigationController?.popViewControllerAnimated(true)
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
