//
//  PreCallViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 4/28/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class PreCallViewController: PandaViewController, UITableViewDataSource, UITableViewDelegate {
    var call : NSDictionary?
    var resources : NSArray?
    var selectedresources : NSMutableArray = []

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var agendaView: UIView!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attachmentTable: UITableView!
    
    var sessionNumber : NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                            self.notesTextView.attributedText = ViewUtils.getAttrText("Session number: \(self.sessionNumber!) \nLast Call Summary:\n\(details!)", color: UIColor.blackColor(), size: 18.0, fontName:"OpenSans")
                        }
                    
                    }
                }
            }
            
            
        }
        // Do any additional setup after loading the view.
        ViewUtils.borderView(callButton, borderWidth: 1.0, borderColor: UIColor.clearColor(), borderRadius: 5)
        ViewUtils.borderView(backButton, borderWidth: 1.0, borderColor: ColorUtils.mainColor(), borderRadius: 5)
        productLabel.attributedText = ViewUtils.getAttrText("Product", color: ColorUtils.uicolorFromHex(0xE1E1E1), size: 24.0, fontName:"OpenSans")
        if let c = call {
            if let product = c["product"] as? NSDictionary{
                productNameLabel.attributedText = ViewUtils.getAttrText(product["name"] as! String, color: UIColor.grayColor(), size: 24.0, fontName:"OpenSans")
            }
            if let callee = c["callee"] as? NSDictionary{
                let lastName = (callee["user"] as? NSDictionary)?["last_name"] as! String
                titleLabel.attributedText = ViewUtils.getAttrText("Your call with Dr. \(lastName)", color: UIColor.grayColor(), size: 24.0, fontName:"OpenSans-Semibold")
            }
            dateLabel.attributedText = ViewUtils.getAttrText(TimeUtils.dateToReadableStr(c["start"] as! NSDate), color: UIColor.grayColor(), size: 24.0, fontName:"OpenSans")
        }
    }
    
    override func viewDidLayoutSubviews() {
        let borderColor = ColorUtils.uicolorFromHex(0xF1F1F1)
        ViewUtils.bottomBorderView(dateLabel, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        ViewUtils.leftBorderView(productNameLabel, borderWidth: 1.0, borderColor: borderColor, offset: -20)
        ViewUtils.topBorderView(notesTextView, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        ViewUtils.bottomBorderView(notesTextView, borderWidth: 1.0, borderColor: borderColor, offset: -1.0)
        ViewUtils.bottomBorderView(agendaView, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        //ViewUtils.bottomBorderView(attachmentView, borderWidth: 1.0, borderColor: UIColor.lightGrayColor(), offset: 0)
        
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
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}