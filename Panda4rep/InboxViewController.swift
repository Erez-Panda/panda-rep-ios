//
//  ZoneLettersViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/23/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class InboxViewController: PandaViewController, UITableViewDataSource, UITableViewDelegate {

    var messages: Array<Dictionary<String,AnyObject>> = []
    var currentIndex : Int?
    var messageIdToDisplay: NSNumber?
    var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyInboxLabel: UILabel!
    
    var selectedInquiry: NSDictionary?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        loadLetterRequests()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "pullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func pullRefresh(sender:AnyObject?){
        loadLetterRequests()
    }
    
    func loadLetterRequests(){
        ServerAPI.getOpenLetterRequests({ (result) -> Void in
            
            self.messages = self.updateStartDate(result)
            self.messages.sortInPlace({ (letter, nextLetter) -> Bool in
                if let created = letter["created"] as? NSDate {
                    if let nextCreated = nextLetter["created"] as? NSDate {
                        if created.laterDate(nextCreated) == created{
                            return true
                        }
                    }
                }
                return false
            })
            dispatch_async(dispatch_get_main_queue()){
                if self.messages.count == 0 {
                    self.emptyInboxLabel.hidden = false
                } else {
                    self.emptyInboxLabel.hidden = true
                }
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        loadLetterRequests()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateStartDate(arr: NSArray) -> Array<Dictionary<String,AnyObject>>{
        var timedLetters : Array<Dictionary<String,AnyObject>> = []
        
        for var index = 0; index < arr.count; ++index {
            var item: Dictionary<String,AnyObject>
            let time: NSDate  = TimeUtils.serverDateTimeStrToDate(arr[index]["created"] as! String)
            let inquiry = arr[index]["inquiry"] as! String
            let id = arr[index]["id"] as! NSNumber
            item = ["created": time,
                    "inquiry": inquiry,
                    "id": id] as Dictionary<String,AnyObject>
            if let creator = arr[index]["creator"] as? NSDictionary{
                item["creator"] = creator
            }
            if let product = arr[index]["product"] as? NSDictionary{
                item["product"] = product
            }
            timedLetters.append(item)
        }
        return timedLetters
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showInquirySegue" {
            let svc = segue.destinationViewController as! InquiryDisplayViewController
            svc.inquiry = selectedInquiry
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("inquiryCell") as! MedicalInquiryTableViewCell
        let letter = messages[indexPath.row]
        if let product = letter["product"] as? NSDictionary{
            cell.drug.text = product["name"] as? String
        }
        
        if let creator = letter["creator"] as? NSDictionary{
            if let user = creator["user"] as? NSDictionary{
                if let name = user["last_name"] as? String{
                    cell.doctor.text = "Dr. \(name)"
                }
            }
        }
        cell.time.text = TimeUtils.dateToReadableStr(letter["created"] as! NSDate)
        cell.button.tag = indexPath.row
        cell.button.setAttributedTitle(ViewUtils.getAttrText("Reply", color: ColorUtils.buttonColor(), size: 18.0), forState: UIControlState.Normal)
        cell.button.addTarget(self, action: "reply:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.layoutMargins = UIEdgeInsetsZero
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*
        let letter = messages[indexPath.row]
        if let response = letter["response"] as? NSDictionary{
            showResponse(indexPath.row)
        }
        */
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
   
    func reply(sender: UIButton){
        selectedInquiry = messages[sender.tag]
        ServerAPI.respondtoMedicalInquiry(selectedInquiry!["id"] as! NSNumber, data: ["active": false]) { (result) -> Void in
            //
        }
        performSegueWithIdentifier("showInquirySegue", sender: self)
        
    }
}
