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
    var calls: NSArray = []
    var filteredCalls : NSArray = []
    var offers: NSArray = []
    var filteredOffers : NSArray = []

    
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
        
        ServerAPI.getUserCallOffers { (result) -> Void in
            self.offers = self.generateCallOffersArray(result)
            ServerAPI.getUserCalls({ (result) -> Void in
                self.calls = result
                self.calls = self.updateStartDate(self.calls)
                self.filteredCalls = self.calls
                dispatch_async(dispatch_get_main_queue()){
                    self.activityIndicator.stopAnimating()
                    self.filterResults(self.selectedDate)
                }
            })
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "pullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "callOfferOffered", name: "CallOfferOffered", object: nil)
    }
    
    func callOfferOffered(){
        pullRefresh(nil)
    }
    
    func pullRefresh(sender:AnyObject?){
        ServerAPI.getUserCallOffers { (result) -> Void in
            self.offers = self.generateCallOffersArray(result)
        
            ServerAPI.getUserCalls({ (result) -> Void in
                self.calls = result
                self.calls = self.updateStartDate(self.calls)
                self.filteredCalls = self.calls
                dispatch_async(dispatch_get_main_queue()){
                    self.filterResults(self.selectedDate)
                    self.refreshControl.endRefreshing()
                }
            })
        }
    }
    
    func dateSelectorView(dateSelectorView: DateSelectorView, didSelecetDate date: NSDate) {
        selectedDate = date
        filterResults(date)
    }
    
    func filterResults(date: NSDate){

        let resultPredicate = NSPredicate(format: "start >= %@ AND start <= %@", argumentArray:[date, date.dateByAddingTimeInterval(60*60*24)])
        if calls.count > 0 || offers.count > 0{
            filteredCalls = self.calls.filteredArrayUsingPredicate(resultPredicate)
            filteredOffers = self.offers.filteredArrayUsingPredicate(resultPredicate)
            if (filteredOffers.count > 0){
                filteredCalls = filteredCalls.arrayByAddingObjectsFromArray(filteredOffers as [AnyObject])
            }
            if (filteredCalls.count == 0){
                noCallsLabel.hidden = false
                //self.tableView.hidden = true
            } else {
                noCallsLabel.hidden = true
                //self.tableView.hidden = false
            }
            self.tableView.reloadData()
        } else {
            noCallsLabel.hidden = false
        }
    }
    
    func updateStartDate(arr: NSArray) -> NSArray{
        var timedCalls : NSMutableArray = []
        for (var index = 0; index < arr.count; ++index){
            let time: NSDate  = TimeUtils.serverDateTimeStrToDate(calls[index]["start"] as! String)
            let endTime: NSDate  = TimeUtils.serverDateTimeStrToDate(calls[index]["end"] as! String)
            var callee : NSDictionary = [:]
            if let user = calls[index]["callee"] as? NSDictionary {
                callee = user
            } else if let guest = calls[index]["guest_callee"] as? NSDictionary {
                callee = guest
            }
            
            let product = calls[index]["product"] as! NSDictionary
            let resources = calls[index]["resources"] as! NSArray
            let id = calls[index]["id"] as! NSNumber
            var item = ["start": time, "product": product, "end": endTime, "id": id, "resources": resources] as Dictionary<String,AnyObject>
            if callee.count > 0 {
                item["callee"] = callee
            }
            timedCalls[index] = item
        }
        
        return timedCalls
    }
    
    func generateCallOffersArray(arr: NSArray) -> NSArray{
        var callOffers : NSMutableArray = []
        for (var index = 0; index < arr.count; ++index){
            
            if let callRequest = arr[index]["call_request"] as? NSDictionary {
                let active = callRequest["active"] as! Bool
                if active {
                    let time: NSDate  = TimeUtils.serverDateTimeStrToDate(callRequest["start"] as! String)
                    
                    var callee : NSDictionary = [:]
                    if let user = callRequest["creator"] as? NSDictionary {
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
                    callOffers.addObject(item)
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
        if let call = filteredCalls[indexPath.row] as? NSDictionary {
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
                } else {
                    firstName = callee["first_name"] as! String
                    lastName = callee["last_name"] as! String
                }
                cell.rep.text = "\(firstName) \(lastName)"
            } else {
                cell.rep.text = "Unknown user"
            }
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let call = filteredCalls[indexPath.row] as? NSDictionary {
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

    }
    
    func acceptCall(sender: UIButton){
        if let call = filteredCalls[sender.tag] as? NSDictionary {
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
                    cell.activity.stopAnimating()
                    self.pullRefresh(sender)
                })
            }
        }
    }
    
    
    @IBAction func createNewCall(sender: AnyObject) {
    }
    


}
