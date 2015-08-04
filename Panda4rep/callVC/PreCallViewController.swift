//
//  PreCallViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 4/28/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
import FontAwesomeIconFactory

class PreCallViewController: PandaViewController, UITableViewDataSource, UITableViewDelegate, CallDelegate {
    var call : NSDictionary?
    var resources : NSArray?
    var selectedresources : NSMutableArray = []

    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var reminderButton: NIKFontAwesomeButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var agendaView: UIView!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attachmentTable: UITableView!
    
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var sessionLabel: UILabel!
    var sessionNumber : NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CallUtils.delegate = self
        if let c = call {
            if let callViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CallNewViewController") as? CallNewViewController {
                if let id = c["id"] as? NSNumber {
                    CallUtils.connectToCallSessionById(id.stringValue, delegateViewController: callViewController, completion: { (result) -> Void in
                        //
                    })
                }
            }
            if let res = c["resources"] as? NSArray {
                ServerAPI.getResourceById(res) { (result) -> Void in
                    self.resources = result
                    if (result.count > 0) {
                        for i in 0..<self.resources!.count{
                            self.selectedresources.addObject(self.resources![i])
                        }
                        dispatch_async(dispatch_get_main_queue()){
                            self.attachmentTable.reloadData()
                        }
                    }
                }
            }
            if let product = c["product"] as? NSDictionary {
                if let callee = c["callee"] as? NSDictionary{
                    ServerAPI.getLatestPostCall(product["id"] as! NSNumber, callee: callee["id"] as! NSNumber) { result -> Void in
                        self.sessionNumber = result["sessionNumber"] as? NSNumber
                        if (self.sessionNumber == nil){
                            self.sessionNumber = 0
                        }
                        var details = result["details"] as? String
                        if (details == nil){
                            details = "N/A"
                        }
                        dispatch_async(dispatch_get_main_queue()){
                            self.sessionLabel.text = self.sessionLabel.text! + " \(self.sessionNumber!)"
                            self.summaryTextView.text = details
                        }
                    
                    }
                }
            }
            if let guest = c["guest_callee"] as? NSDictionary {
                disableReminderButton("Reminder N/A")
            }
            
        }
        // Do any additional setup after loading the view.
        ViewUtils.borderView(callButton, borderWidth: 1.0, borderColor: UIColor.clearColor(), borderRadius: 5)
        ViewUtils.borderView(reminderButton, borderWidth: 1.0, borderColor: UIColor.clearColor(), borderRadius: 5)
        productLabel.attributedText = ViewUtils.getAttrText("Product", color: ColorUtils.uicolorFromHex(0xE1E1E1), size: 24.0, fontName:"OpenSans")
        if let c = call {
            if let product = c["product"] as? NSDictionary{
                productNameLabel.attributedText = ViewUtils.getAttrText(product["name"] as! String, color: UIColor.grayColor(), size: 24.0, fontName:"OpenSans")
            }
            if let callee = c["callee"] as? NSDictionary{
                var lastName = ""
                if let user = callee["user"] as? NSDictionary{
                    lastName = user["last_name"] as! String
                } else {
                    lastName = callee["last_name"] as! String
                }
                
                titleLabel.attributedText = ViewUtils.getAttrText("Your call with Dr. \(lastName)", color: UIColor.grayColor(), size: 24.0, fontName:"OpenSans-Semibold")
            }
            dateLabel.attributedText = ViewUtils.getAttrText(TimeUtils.dateToReadableStr(c["start"] as! NSDate), color: UIColor.grayColor(), size: 24.0, fontName:"OpenSans")
        }
    }
    
    override func viewDidLayoutSubviews() {
        let borderColor = ColorUtils.uicolorFromHex(0xF1F1F1)
        ViewUtils.bottomBorderView(dateLabel, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        ViewUtils.leftBorderView(productNameLabel, borderWidth: 1.0, borderColor: borderColor, offset: -20)
        ViewUtils.topBorderView(summaryView, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        ViewUtils.bottomBorderView(summaryView, borderWidth: 1.0, borderColor: borderColor, offset: -1.0)
        ViewUtils.bottomBorderView(agendaView, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        //ViewUtils.bottomBorderView(attachmentView, borderWidth: 1.0, borderColor: UIColor.lightGrayColor(), offset: 0)
        
    }
    func remoteSideConnected(){
        disableReminderButton("Remote Connected")
        callButton.enabled = true
        callButton.backgroundColor = ColorUtils.buttonColor()
    }
    
    func remoteSideDisconnected() {
        enableReminderButton("Send Reminder")
        callButton.enabled = false
        callButton.backgroundColor = UIColor.lightGrayColor()
    }
    
    func remoteSideDecliend() {
        //ViewUtils.showSimpleError("Doctor has declined the call")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == attachmentTable {
            if let r = self.resources {
                return r.count
            }
        }
        return 0
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("attachmentCell") as! AttachmentTableViewCell
        if let resource = self.resources?[indexPath.row] as? NSDictionary {
            let name = resource["name"] as! String
            cell.nameLabel.attributedText = ViewUtils.getAttrText(name, color: UIColor.blackColor(), size: 16.0, fontName:"OpenSans")
            cell.checkboxButton.tag = indexPath.row
            cell.checkboxButton.addTarget(self, action: "toggleCheckbox:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    /*
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! AttachmentTableViewCell
        cell.checkboxButton.selected = !cell.checkboxButton.selected
*/
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 34
    }
    
    func toggleCheckbox(checkbox: UIButton){
        if checkbox.selected{
            checkbox.selected = false
            selectedresources[checkbox.tag] = [:]
        } else {
            checkbox.selected = true
            selectedresources[checkbox.tag] = resources![checkbox.tag]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*
        if (segue.identifier == "showCallScreen"){
            var svc = segue.destinationViewController as! CallNewViewController
            var activeRes : NSMutableArray = []
            for i in 0..<self.selectedresources.count{
                if self.selectedresources[i]["name"] != nil{
                    activeRes.addObject(self.selectedresources[i])
                }
            }
            svc.resources = activeRes
        }
        */
        
    }
    
    
    @IBAction func openCallScreen(sender: AnyObject) {
        if let vc = CallUtils.getCallViewController() {
            var activeRes : NSMutableArray = []
            for i in 0..<self.selectedresources.count{
                if self.selectedresources[i].count > 0{
                    activeRes.addObject(self.selectedresources[i])
                }
            }
            vc.resources = activeRes
            vc.sessionNumber = self.sessionNumber
            let home = self.navigationController?.popViewControllerAnimated(false)
            home?.presentViewController(vc, animated: true, completion: {
            })
        }
    }
    
    @IBAction func sendReminder(sender: AnyObject) {
        disableReminderButton("Sent")
        if let c = call {
            if let id = c["id"] as? NSNumber{
                ServerAPI.sendCallingNotification(["call":id], completion: { (result) -> Void in
                    //
                })
            }
        }
    }
    
    func disableReminderButton(message: String){
        reminderButton.enabled = false
        reminderButton.backgroundColor = UIColor.lightGrayColor()
        reminderButton.setTitle(message, forState: UIControlState.Normal)
        reminderButton.color = UIColor.clearColor()
        reminderButton.titleEdgeInsets.left = 0
    }
    
    func enableReminderButton(message: String){
        reminderButton.enabled = true
        reminderButton.backgroundColor = ColorUtils.buttonColor()
        reminderButton.setTitle(message, forState: UIControlState.Normal)
        reminderButton.color = UIColor.whiteColor()
        reminderButton.titleEdgeInsets.left = 6
    }

}
