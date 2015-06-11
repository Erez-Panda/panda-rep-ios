//
//  ViewController.swift
//  Panda4doctor
//
//  Created by Erez on 11/23/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var loginView: UIView!
    
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var liveMedTitleLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    var keyboardVisable = false
    
    @IBAction func login(sender: UIButton) {
        self.activityIndicatorView.startAnimating()
        
        NSUserDefaults.standardUserDefaults().setObject(["username": userEmail.text, "password": userPassword.text], forKey: "credentials")
        NSUserDefaults.standardUserDefaults().synchronize()
        LoginUtils.login(userEmail.text, password: userPassword.text, sender: self, successSegue:"showHomeFromLogin", completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicatorView.stopAnimating()
            }
        })
  
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.userEmail){
            self.userPassword.becomeFirstResponder()
        } else if (textField == self.userPassword){
            self.login(self.loginButton)
            textField.resignFirstResponder()
        }
        return true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShown"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
        UIEventRegister.tapRecognizer(self, action:"closeKeyboard")
        liveMedTitleLabel.attributedText = ViewUtils.getAttrText("LiveMed", color: ColorUtils.uicolorFromHex(0x8E8DA2), size: 30.0, fontName: "OpenSans-Semibold" )
        
    }
    
    func closeKeyboard(){
        userEmail.resignFirstResponder()
        userPassword.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        loginView.layoutIfNeeded()
        ViewUtils.borderView(loginButton, borderWidth: 1.0, borderColor:  UIColor.clearColor(), borderRadius: 3.0)
        ViewUtils.borderView(loginView, borderWidth: 1.0, borderColor:  ColorUtils.uicolorFromHex(0xDFDFDF), borderRadius: 3.0)
        var middleBorder = CALayer()
        
        middleBorder.frame = CGRectMake(0.0, loginView.frame.size.height/2, loginView.frame.size.width, 1.0);
        middleBorder.backgroundColor = ColorUtils.uicolorFromHex(0xDFDFDF).CGColor
        loginView.layer.addSublayer(middleBorder)
    }
    func keyboardWillShown(){
 
        if (!keyboardVisable){
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y  -= 30
            })
        }
        keyboardVisable = true
    }
    func keyboardWillHide(){

        if (keyboardVisable){
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y = 0.0
            })
        }
        keyboardVisable = false
    }

    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        if (isValidEmail(userEmail.text)){
            self.activityIndicatorView.startAnimating()
            ServerAPI.resetUserPassword(["email": userEmail.text], completion: { (result) -> Void in
                
                if let error = result["error"] as? String {
                    dispatch_async(dispatch_get_main_queue()){
                        self.activityIndicatorView.stopAnimating()
                        ViewUtils.showSimpleError(error)
                        
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()){
                        self.activityIndicatorView.stopAnimating()
                        var alert = UIAlertView()
                        alert.title = "Reset password email has been sent"
                        alert.message = "Please follow email instructions to reset your password"
                        alert.addButtonWithTitle("Ok")
                        alert.show()
                    }
                }
            })

        } else {
            ViewUtils.showSimpleError("Please enter your email in the \"Email\" field")
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValid = emailTest.evaluateWithObject(testStr)
        return isValid && !testStr.isEmpty
        
    }
    /*
    
    override func prefersStatusBarHidden() -> Bool {
        return false
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

