//
//  ChatViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/10/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet weak var chatTitle: UILabel!
    var lastChatBox: UIView?
    var bottomConstraint: NSLayoutConstraint?


    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var chatText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let callee = CallUtils.currentCall?["callee"] as? NSDictionary{
            let firstName = (callee["user"] as? NSDictionary)?["first_name"] as! String
            let lastName = (callee["user"] as? NSDictionary)?["last_name"] as! String
            chatTitle.attributedText = ViewUtils.getAttrText("Chat with \(firstName) \(lastName)", color: UIColor.whiteColor(), size: 20.0)
        }
            
        chatText.attributedPlaceholder = ViewUtils.getAttrText("Type a message here...", color: UIColor.lightGrayColor(), size: 16.0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShown:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        
        UIEventRegister.tapRecognizer(self, action: "closeKeyboard")
        // Do any additional setup after loading the view.
    }
    
    func closeKeyboard(){
        chatText.resignFirstResponder()
    }

    @IBAction func close(sender: AnyObject) {
        //self.dismissViewControllerAnimated(true, completion: nil)
        ViewUtils.slideViewOutVertical(self.view)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        sendMessageToRemote(textField.text)
        textField.text = ""
        return true
    }
    
    func sendMessageToRemote(message: String){
        if message != "" {
            var maybeError : OTError?
            CallUtils.session?.signalWithType("chat_text", string: message, connection: nil, error: &maybeError)
            addChatBox(chatText.text, isSelf: true)
        }
    }
    

    @IBAction func sendMessage(sender: AnyObject) {
        sendMessageToRemote(chatText.text)
        chatText.text = ""
    }
    
    func addChatBox(message: String, isSelf: Bool){
        let chatBox = ChatBoxView(message: message, leftAlign: !isSelf)
        scrollView.addSubview(chatBox)
        let screenSize: CGRect = UIScreen.mainScreen().bounds

        if (lastChatBox == nil){
            ViewUtils.addConstraintsToSuper(chatBox, superView: scrollView, top: 150.0, left: nil , bottom: nil, right: nil)
        } else {
            let vConst = NSLayoutConstraint(item: chatBox, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: lastChatBox, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 10.0)
            scrollView.addConstraint(vConst)
        }
        
        ViewUtils.addConstraintsToSuper(chatBox, superView: scrollView, top: nil, left: isSelf ? screenSize.width-chatBox.frame.width : 20 , bottom: nil, right: nil)

        
        
        
        lastChatBox = chatBox
        
        if let bc = bottomConstraint {
            scrollView.removeConstraint(bc)
        }
        bottomConstraint  = NSLayoutConstraint(item: lastChatBox!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -60.0)
        scrollView.addConstraint(bottomConstraint!)
        
        scrollView.contentOffset.y = scrollView.contentSize.height
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func keyboardWillShown(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  = -(keyboardSize.height )
        })
    }
    
    func keyboardWillHide(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0
        })
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

}
