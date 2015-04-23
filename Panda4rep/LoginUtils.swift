//
//  LoginUtils.swift
//  Panda4rep
//
//  Created by Erez on 1/1/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//


struct LoginUtils {
    
    static func showLoginError(){
        dispatch_async(dispatch_get_main_queue()){
            var noCallAlert = UIAlertView()
            noCallAlert.title = "Login Error"
            noCallAlert.message = "Your username or password are incorrect"
            noCallAlert.addButtonWithTitle("Ok")
            noCallAlert.show()
        }
    }
    
    static func login(username: String, password: String, sender: UIViewController, successSegue: String, notApprovedSegue: String, completion: (result: Bool) -> Void) -> Void{
        NSUserDefaults.standardUserDefaults().setObject(["username": username, "password": password], forKey: "credentials")
        NSUserDefaults.standardUserDefaults().synchronize()
        ServerAPI.login(username, password: password, completion: {result -> Void in
            if (result) {
                ServerAPI.getUser({result -> Void in
                    if result["type"] as! String == "MEDREP" {
                        if result["status"] as? String == "approved" {
                            StorageUtils.saveUserData(result)
                            dispatch_async(dispatch_get_main_queue()){
                                sender.performSegueWithIdentifier(successSegue, sender: AnyObject?())
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue()){
                                sender.performSegueWithIdentifier(notApprovedSegue, sender: AnyObject?())
                            }
                        }
                    } else {
                        //not a med-rep, don't login
                        self.showLoginError()
                    }
                    completion(result: true)
                })
            }else {
                self.showLoginError()
                completion(result: false)
            }
        })
    }
    

}
