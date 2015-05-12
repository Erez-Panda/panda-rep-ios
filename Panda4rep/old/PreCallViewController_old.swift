//
//  PreCallViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/22/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class PreCallViewController_old: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate {
    
    
    
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var introTextView: UITextView!
    @IBOutlet weak var viewPicker: UIPickerView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var firstCallText: UITextView!
    
    var resources: NSArray?
    var user: NSDictionary!
    var selectedRes: NSDictionary?
    var displayResources: NSArray?
    var currentCall: NSDictionary?
    var sessionNumber: NSNumber?
    var selectedResIndex = 0
    
    func replaceTextValues(lastCall: NSDictionary, productName: String, doctorName: String){
        if let details = lastCall["details"] as? String{
            self.summaryTextView.text = details
            let date = TimeUtils.serverDateTimeStrToDate(lastCall["start"] as! String)
            var readableTime = TimeUtils.dateToReadableStr(date)
            self.detailsTextView.text = self.detailsTextView.text.stringByReplacingOccurrencesOfString("START_DATE", withString: readableTime)
            var callLength = lastCall["callLength"] as! NSNumber
            callLength = callLength.integerValue/(1000*60)
            self.detailsTextView.text = self.detailsTextView.text.stringByReplacingOccurrencesOfString("CALL_LENGTH", withString:callLength.stringValue )
            let sessionNumber = lastCall["sessionNumber"] as! NSNumber
            self.detailsTextView.text = self.detailsTextView.text.stringByReplacingOccurrencesOfString("SESSION_NUMBER", withString: sessionNumber.stringValue)
            self.detailsTextView.text = self.detailsTextView.text.stringByReplacingOccurrencesOfString("PRODUCT_NAME", withString: productName)
        } else {
            self.summaryTextView.hidden = true
            self.detailsTextView.hidden = true
            self.detailsTextView.hidden = true
            self.firstCallText.hidden = false
            self.firstCallText.text = self.firstCallText.text.stringByReplacingOccurrencesOfString("PRODUCT_NAME", withString: productName)
            self.firstCallText.text = self.firstCallText.text.stringByReplacingOccurrencesOfString("DOCTOR_NAME", withString: doctorName)
        }
        self.introTextView.text = self.introTextView.text.stringByReplacingOccurrencesOfString("PRODUCT_NAME", withString: productName)
        self.introTextView.text = self.introTextView.text.stringByReplacingOccurrencesOfString("DOCTOR_NAME", withString: doctorName)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServerAPI.getCurrentCall( {result -> Void in
            self.currentCall = result
            if let product = self.currentCall?["product"] as? NSDictionary {
                if let callee = self.currentCall?["callee"] as? NSDictionary {
                    ServerAPI.getLatestPostCall(product["id"] as! NSNumber, callee: callee["id"] as! NSNumber) { result -> Void in
                        var doctor = self.currentCall?["callee"] as? NSDictionary
                        doctor = doctor?["user"] as? NSDictionary
                        let productName = product["name"] as! String
                        let doctorName = doctor!["last_name"] as! String
                        dispatch_async(dispatch_get_main_queue()){
                            self.replaceTextValues(result, productName: productName, doctorName: doctorName)
                        }
                        
                        self.sessionNumber = result["sessionNumber"] as? NSNumber
                        if (self.sessionNumber == nil){
                            self.sessionNumber = 0
                        }
                    }
                }
            }
            if let res = self.currentCall?["resources"] as? NSArray {
                ServerAPI.getResourceById(res) { (result) -> Void in
                    self.resources = result
                    if (result.count > 0) {
                        if let selected = result[0] as? NSDictionary {
                            self.selectedRes = selected
                            dispatch_async(dispatch_get_main_queue()){
                                self.viewPicker.reloadAllComponents()
                            }
                        }
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    var noCallAlert = UIAlertView()
                    noCallAlert.title = "You have no scheduled call"
                    noCallAlert.message = "We will assign you a call as soon as possible and let you know"
                    noCallAlert.addButtonWithTitle("Ok")
                    noCallAlert.delegate = self
                    noCallAlert.show()
                }
            }
        })

        self.resources = []
    }
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.resources!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let resource = self.resources![row] as! NSDictionary
        return resource["name"] as! String
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let resource = self.resources![row] as! NSDictionary
        self.selectedRes = resource
        self.selectedResIndex = row
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let resource = self.resources![row] as! NSDictionary
        let titleData = resource["name"] as! String
        var myTitle = NSAttributedString(string: titleData, attributes:[NSFontAttributeName:UIFont(name: "Georgia", size: 15.0 )!, NSForegroundColorAttributeName: UIColor.blueColor()])
        return myTitle
    }
    
    @IBAction func loadResource(sender: UIButton) {
        if let resourceId = self.selectedRes?["id"] as? NSNumber{
            ServerAPI.getResourceDisplay(resourceId, completion: { (result) -> Void in
                self.displayResources = result
                dispatch_async(dispatch_get_main_queue()){
                    self.performSegueWithIdentifier("showCallSegue", sender: AnyObject?())
                }
            })
        }
        

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showCallSegue"){
            var svc = segue.destinationViewController as! CallViewController
            svc.user = self.user
            svc.selectedResIndex = self.selectedResIndex
            svc.resources = self.resources
            svc.displayResources = self.displayResources
            svc.currentCall = self.currentCall
            svc.sessionNumber = self.sessionNumber
        }
    }
    
}
