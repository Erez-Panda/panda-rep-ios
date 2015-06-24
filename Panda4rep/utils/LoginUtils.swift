//
//  LoginUtils.swift
//  Panda4doctor
//
//  Created by Erez on 1/1/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import LocalAuthentication

struct LoginUtils {
    static var isLoggedIn = false
    static func showPasswordAlert() {
        
    }
    static func authenticateUser(completion: (result: Bool) -> Void) -> Void{
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        var reasonString = "Authentication is needed to access LiveMed."
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    completion(result: true)
                    return
                }
                else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    println(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        println("Authentication was cancelled by the system")
                        
                    case LAError.UserCancel.rawValue:
                        println("Authentication was cancelled by the user")
                        
                    case LAError.UserFallback.rawValue:
                        println("User selected to enter custom password")
                        self.showPasswordAlert()
                        
                    default:
                        println("Authentication failed")
                        self.showPasswordAlert()
                    }
                    completion(result: false)
                }
                
            })]
        }
        else{
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                println("TouchID is not enrolled")
                
            case LAError.PasscodeNotSet.rawValue:
                println("A passcode has not been set")
                
            default:
                // The LAError.TouchIDNotAvailable case.
                println("TouchID not available")
            }
            
            // Optionally the error description can be displayed on the console.
            println(error?.localizedDescription)
            completion(result: true)
            return
            // Show the custom alert view to allow users to enter the password.
            //self.showPasswordAlert()
            //completion(result: false)
        }
    }
    
    static func showLoginError(){
        dispatch_async(dispatch_get_main_queue()){
            var noCallAlert = UIAlertView()
            noCallAlert.title = "Login Error"
            noCallAlert.message = "Your username and password do not match"
            noCallAlert.addButtonWithTitle("Ok")
            noCallAlert.show()
        }
    }
    
    static func login(username: String, password: String, sender: UIViewController, successSegue: String, completion: (result: Bool) -> Void) -> Void{
        NSUserDefaults.standardUserDefaults().setObject(["username": username, "password": password], forKey: "credentials")
        NSUserDefaults.standardUserDefaults().synchronize()
        ServerAPI.login(username, password: password, completion: {result -> Void in
            if (result) {
                ServerAPI.getUser({result -> Void in
                    if result["type"] as! String == "MEDREP" {
                            StorageUtils.saveUserData(result)
                            self.isLoggedIn = true
                            dispatch_async(dispatch_get_main_queue()){
                                sender.performSegueWithIdentifier(successSegue, sender: AnyObject?())
                            }
                    } else {
                        //not a doctor, don't login
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
