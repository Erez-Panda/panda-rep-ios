//
//  ContactUsViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/16/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class ContactUsViewController: PandaViewController, UITextViewDelegate, UITextFieldDelegate {
    
    let placeholder = "Please type your feedback/inquiry here"
    @IBOutlet weak var inquiryTextView: UITextView!
    
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var subjectText: UITextField!
    func doneButtonClickedDismissKeyboard() {
        self.inquiryTextView.resignFirstResponder()
    }
    
    func addDoneToolBarToKeyboard(textView: UITextView){
        var doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.Default
        doneToolbar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonClickedDismissKeyboard")]
        doneToolbar.sizeToFit()
        textView.inputAccessoryView = doneToolbar;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        inquiryTextView.layoutIfNeeded()
        addDoneToolBarToKeyboard(self.inquiryTextView)
        ViewUtils.bottomBorderView(inquiryTextView, borderWidth: 1.0, borderColor: UIColor.lightGrayColor(), offset: -inquiryTextView.frame.height)
        self.title = "Contact Us"
        inquiryTextView.attributedText = ViewUtils.getAttrText(placeholder, color: UIColor.lightGrayColor(), size: 16.0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.attributedText.string == placeholder){
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == ""){
            textView.attributedText = ViewUtils.getAttrText(placeholder, color: UIColor.lightGrayColor(), size: 16.0)
        }
    }
    

    @IBAction func sendInquiry(sender: AnyObject) {
        if self.inquiryTextView.text != "" && self.inquiryTextView.text != placeholder{
            //send inquiry...
            ServerAPI.sendSupportEmail(["title": subjectText.text,"text": inquiryTextView.text], completion: { (result) -> Void in
                //
            })
            confirmView.hidden = false
        } else {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(CGPoint: CGPointMake(inquiryTextView.center.x - 5, inquiryTextView.center.y))
            animation.toValue = NSValue(CGPoint: CGPointMake(inquiryTextView.center.x + 5, inquiryTextView.center.y))
            inquiryTextView.layer.addAnimation(animation, forKey: "position")
        }
        
    }
    
    
    @IBAction func close(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
