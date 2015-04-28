//
//  LoginViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/17/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBAction func login(sender: UIButton) {
        self.activityIndicatorView.startAnimating()
        LoginUtils.login(email.text, password: password.text, sender: self, successSegue: "showMainFromLoginSegue", completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicatorView.stopAnimating()
            }
        })
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("\(textField.text)")
        textField.resignFirstResponder()
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
        
    }
    func keyboardWillShown(){
        
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  -= 30
        })
    }
    func keyboardWillHide(){
        
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  += 30
        })
    }
    
}