//
//  HomeViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 4/23/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
import HorizontalDatePicker

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DateSelectorViewDelegate {

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menu(){
        ViewUtils.slideInMenu(self)
    }
    
    var selectedCall : NSDictionary?
    var calls: Array<Dictionary<String,AnyObject>> = []
    var filteredCalls : Array<Dictionary<String,AnyObject>> = []
    var offers: Array<Dictionary<String,AnyObject>> = []
    var filteredOffers : Array<Dictionary<String,AnyObject>> = []

    
    @IBOutlet weak var dateSelector: DateSelectorView!
    @IBOutlet weak var newCallButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noCallsLabel: UILabel!
    
    var refreshControl:UIRefreshControl!
    
    var selectedDate =  NSCalendar.currentCalendar().startOfDayForDate(NSDate())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateSelector.delegate = self
        dateSelector.startDate = selectedDate
        ViewUtils.setMenuButton(self)
        activityIndicator.startAnimating()
        //tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        updateCallsAndOffers()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "pullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "callOfferOffered:", name: "CallOfferOffered", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "callOfferOffered:", name: "CallCreated", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "HomeScreenReady", object: self))
    }
    
    override func viewDidAppear(animated: Bool) {
        updateCallsAndOffers()
    }
    
    func callOfferOffered(notification: NSNotification){
        if let offer = notification.object as? NSDictionary{
            if let start = offer["start"] as? String{
                selectedDate = NSCalendar.currentCalendar().startOfDayForDate(TimeUtils.serverDateTimeStrToDate(start))
            }
        }
        updateCallsAndOffers(scrollToLast: true)
    }
    
    func updateCallsAndOffers(scrollToLast: Bool = false){
        ServerAPI.getUserCallOffers { (result) -> Void in
            self.offers = self.generateCallOffersArray(result)
            self.updateBadges()
            ServerAPI.getUserCalls({ (result) -> Void in
                self.calls = self.updateStartDate(result)
                self.filteredCalls = self.calls
                dispatch_async(dispatch_get_main_queue()){
                    self.filterResults(self.selectedDate)
                    ViewUtils.stopGlobalLoader()
                    self.activityIndicator.stopAnimating()
                    //self.dateSelector.startDate = self.selectedDate
                    self.refreshControl.endRefreshing()
                    if scrollToLast {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.filteredCalls.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
                    }
                }
            })
        }
    }
    func pullRefresh(sender:AnyObject?){
        updateCallsAndOffers()
    }
    
    func updateBadges(){
        var badges : Dictionary<NSDate, Int> = [:]
        for offer in offers{
            if let start = offer["start"] as? NSDate{
                let day = NSCalendar.currentCalendar().startOfDayForDate(start)
                if badges[day] == nil {
                    badges[day] = 1
                } else {
                    badges[day]!++
                }
                
            }
        }
        for (date, value) in badges {
            if !date.isEqualToDate(selectedDate) {
                dateSelector.setBadgeForDate(date, value: value)
            }
            
        }
    }
    
    func updateCallStatus(id: NSNumber, status: String){
        for index in 0..<calls.count {
            if calls[index]["id"] as? NSNumber == id {
                calls[index]["status"] = status
                self.filterResults(self.selectedDate)
                return
            }
        }
    }
    
    func dateSelectorView(dateSelectorView: DateSelectorView, didSelecetDate date: NSDate) {
        selectedDate = date
        filterResults(date)
    }
    
    func isCallInDay(call: Dictionary<String, AnyObject>, dayStart: NSDate) -> Bool{
        if let start = call["start"] as? NSDate{
            let dayEnd = dayStart.dateByAddingTimeInterval(60*60*24)
            if start.laterDate(dayStart) == start && start.laterDate(dayEnd) == dayEnd{
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    func filterResults(date: NSDate){
        dateSelector.selectDate(selectedDate)
        dateSelector.setBadgeForDate(date, value: 0)
        if calls.count > 0 || offers.count > 0{
            filteredCalls = self.calls.filter({ (call) -> Bool in
                return self.isCallInDay(call, dayStart: date)
            })
            filteredOffers = self.offers.filter({ (call) -> Bool in
                return self.isCallInDay(call, dayStart: date)
            })

            if (filteredOffers.count > 0){
                filteredCalls = filteredCalls + filteredOffers
            }
            if (filteredCalls.count == 0){
                noCallsLabel.hidden = false
                //self.tableView.hidden = true
            } else {
                noCallsLabel.hidden = true
                //self.tableView.hidden = false
            }
            filteredCalls.sort({ (call, nextCall) -> Bool in
                if let start = call["start"] as? NSDate {
                    if let nextStart = nextCall["start"] as? NSDate {
                        if start.laterDate(nextStart) == nextStart{
                            return true
                        }
                    }
                }
                return false
            })
            self.tableView.reloadData()
        } else {
            noCallsLabel.hidden = false
        }
    }
    
    func updateStartDate(arr: NSArray) -> Array<Dictionary<String,AnyObject>>{
        var timedCalls : Array<Dictionary<String,AnyObject>> = []
        for (var index = 0; index < arr.count; ++index){
            let time: NSDate  = TimeUtils.serverDateTimeStrToDate(arr[index]["start"] as! String)
            let endTime: NSDate  = TimeUtils.serverDateTimeStrToDate(arr[index]["end"] as! String)
            var callee : NSDictionary = [:]

            
            let product = arr[index]["product"] as! NSDictionary
            let resources = arr[index]["resources"] as! NSArray
            let id = arr[index]["id"] as! NSNumber
            var item = ["start": time, "product": product, "end": endTime, "id": id, "resources": resources] as Dictionary<String,AnyObject>
            if let user = arr[index]["callee"] as? NSDictionary {
                callee = user
            } else if let guest = arr[index]["guest_callee"] as? NSDictionary {
                callee = guest
                item["guest_callee"] = callee
            }
            if callee.count > 0 {
                item["callee"] = callee
            }
            if let status = arr[index]["status"] as? String{
                item["status"] = status
            }
            if let type = arr[index]["type"] as? String{
                item["type"] = type
            }
            timedCalls.append(item)
        }
        
        return timedCalls
    }
    
    func generateCallOffersArray(arr: NSArray) -> Array<Dictionary<String,AnyObject>>{
        var callOffers : Array<Dictionary<String,AnyObject>> = []
        for (var index = 0; index < arr.count; ++index){
            
            if let callRequest = arr[index]["call_request"] as? NSDictionary {
                let active = callRequest["active"] as! Bool
                if active {
                    let time: NSDate  = TimeUtils.serverDateTimeStrToDate(callRequest["start"] as! String)
                    
                    var callee : NSDictionary = [:]
                    if let user = callRequest["creator"] as? NSDictionary {
                        callee = user
                    } else if let user = callRequest["guest_creator"] as? NSDictionary {
                        callee = user
                    }
                    var product : NSDictionary = [:]
                    if let p = callRequest["product"] as? NSDictionary{
                        product = p
                    }
                    let id = arr[index]["id"] as! NSNumber
                    var item = ["offer": true,"start": time, "product": product, "id": id] as Dictionary<String,AnyObject>
                    if callee.count > 0 {
                        item["callee"] = callee
                    }
                    callOffers.append(item)
                }
            }
        }
        
        return callOffers
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPrecallScreen"){
            var svc = segue.destinationViewController as! PreCallViewController
            svc.call = self.selectedCall
        }
        if (segue.identifier == "showPostCallScreen"){
            var svc = segue.destinationViewController as! PostCallNewViewController
            svc.call = self.selectedCall
            if let callVC = sender as? CallNewViewController{
                svc.startTime = callVC.callStartTime
                svc.endTime = NSDate()
                svc.sessionNumber = callVC.sessionNumber
            }
        }
        if (segue.identifier == "presentCreateCall"){
            var svc = segue.destinationViewController as! CreateCallViewController
            svc.parent = self
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCalls.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : ZoneCallTableViewCell = ZoneCallTableViewCell()
        let call = filteredCalls[indexPath.row]
        if let isOffer = call["offer"] as? Bool{
            cell = tableView.dequeueReusableCellWithIdentifier("acceptCallCell") as! AcceptCallTableViewCell
            (cell as! AcceptCallTableViewCell).acceptButton.addTarget(self, action: "acceptCall:", forControlEvents: UIControlEvents.TouchUpInside)
            (cell as! AcceptCallTableViewCell).acceptButton.tag = indexPath.row
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("zoneCallCell") as! ZoneCallTableViewCell
        }
        if let product = call["product"] as? NSDictionary{
            cell.drug.text = product["name"] as? String
        }

        cell.time.text = TimeUtils.dateToReadableTimeStr(call["start"] as! NSDate)
        if let callee = call["callee"] as? NSDictionary{
            var firstName = ""
            var lastName = ""
            if let user = callee["user"] as? NSDictionary{
                firstName = user["first_name"] as! String
                lastName = user["last_name"] as! String
            } else { // no user == guest
                firstName = callee["first_name"] as! String
                lastName = callee["last_name"] as! String
            }
            cell.rep.text = "Dr. \(lastName)"
        } else {
            cell.rep.text = "Unknown user"
        }
        if let status = call["status"] as? String{
            cell.status.setTitle(status, forState: UIControlState.Normal)
            if status == "new" {
                cell.status.color = UIColor.grayColor()
            } else  if status == "accepted" {
                cell.status.color = ColorUtils.buttonColor()
            } else if status == "declined" {
                cell.status.color = UIColor.redColor()
            } else {
                cell.status.color = ColorUtils.uicolorFromHex(0xFDB606)
            }
        }
        if let type = call["type"] as? String{
            if type == "on-demand"{
                cell.status.setTitle("on demand", forState: UIControlState.Normal)
                cell.status.color = ColorUtils.buttonColor()
            }
        }
    
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let call = filteredCalls[indexPath.row]
        if let isOffer = call["offer"] as? Bool{
            return
        }
        selectedCall = call
        
        if let endTime = call["end"] as? NSDate {
            let now  = NSDate()
            if (endTime.compare(now)) == NSComparisonResult.OrderedDescending{
                self.performSegueWithIdentifier("showPrecallScreen", sender: self)
            } else {
                self.performSegueWithIdentifier("showPostCallScreen", sender: self)
            }
        }

    }
    
    func openPreCallById(id: NSNumber){
        for call in calls{
            if call["id"] as? NSNumber == id{
                selectedCall = call
                self.performSegueWithIdentifier("showPrecallScreen", sender: self)
            }
        }
    }
    
    func acceptCall(sender: UIButton){
        let call = filteredCalls[sender.tag]
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! AcceptCallTableViewCell
        cell.activity.startAnimating()
        ViewUtils.slideViewOutToRight(sender)
        if let id = call["id"] as? NSNumber{
            ServerAPI.acceptCallOffer(id, completion: {result -> Void in
                if let error = result["error"] as? String{
                    dispatch_async(dispatch_get_main_queue()){
                        ViewUtils.showSimpleError(error)
                    }
                }
                dispatch_async(dispatch_get_main_queue()){
                    cell.activity.stopAnimating()
                }
                self.updateCallsAndOffers()
            })
        }
    }
    
    
    @IBAction func createNewCall(sender: AnyObject) {
    }
    


}
