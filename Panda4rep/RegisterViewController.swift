//
//  RegisterViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/17/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class RegisterViewController : UITableViewController, UITextFieldDelegate {
    

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var firstName: UITextField!
    var user: NSDictionary!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println(textField.text)
        textField.resignFirstResponder()
        if (textField == self.firstName){
            self.lastName.becomeFirstResponder()
        } else if (textField == self.lastName){
            self.email.becomeFirstResponder()
        } else if (textField == self.email){
            self.password.becomeFirstResponder()
        }
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func send(sender: AnyObject) {
        let userData = ["user":[ "first_name":self.firstName.text,
            "last_name":self.lastName.text,
            "email":self.email.text,
            "password":self.password.text],
            "type": "MEDREP"] as Dictionary<String,AnyObject>
        ServerAPI.registerUser(userData , completion: {result -> Void in
            LoginUtils.login(self.email.text, password: self.password.text, sender: self, successSegue: "showMainFromRegisterSegue", notApprovedSegue: "showNotApprovedFromRegisterSegue", completion: {result -> Void in
            })
        })
    }
}

