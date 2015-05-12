//
//  HomeViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 4/23/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AKPickerViewDelegate, AKPickerViewDataSource {
    
    let months = ["January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"]

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

    
    @IBOutlet weak var newCallButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var monthPicker: AKPickerView!
    @IBOutlet weak var dayPicker: AKPickerView!
    var refreshControl:UIRefreshControl!
    
    var currYear = 0
    var selectedMonth = 0
    var selectedDay = 0
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtils.setMenuButton(self)
        activityIndicator.startAnimating()
        //tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        monthPicker.delegate = self
        monthPicker.dataSource = self
        monthPicker.interitemSpacing = 100
        monthPicker.pickerViewStyle = AKPickerViewStyle.Flat
        monthPicker.font = UIFont(name: "OpenSans-Semibold", size: 28.0)!
        monthPicker.highlightedTextColor = UIColor.blackColor()
        monthPicker.textColor = ColorUtils.uicolorFromHex(0x727272)
        monthPicker.highlightedFont = UIFont(name: "OpenSans-Semibold", size: 28.0)!
        
        dayPicker.delegate = self
        dayPicker.dataSource = self
        dayPicker.interitemSpacing = 25
        dayPicker.font = UIFont(name: "OpenSans-Light", size: 40.0)!
        dayPicker.highlightedTextColor = ColorUtils.mainColor() //ColorUtils.uicolorFromHex(0x727272)
        dayPicker.highlightedFont = UIFont(name: "OpenSans-Light", size: 40.0)!// UIFont(name: "OpenSans-Semibold", size: 34.0)!
        dayPicker.addBorder = true
        
        let dateComp = TimeUtils.getDateComponentsFromDate(NSDate())
        currYear = dateComp.year
        
        selectedMonth = dateComp.month
        selectedDay = TimeUtils.getDayInYear(NSDate())
        offset = selectedDay
        
        dayPicker.layoutIfNeeded()
        monthPicker.layoutIfNeeded()
        
        ViewUtils.bottomBorderView(dayPicker, borderWidth: 1.0, borderColor: UIColor.lightGrayColor(), offset: 0)
        ViewUtils.topBorderView(dayPicker, borderWidth: 1.0, borderColor: UIColor.lightGrayColor(), offset: 0)
        ViewUtils.borderView(newCallButton, borderWidth: 1.0, borderColor: UIColor.clearColor(), borderRadius: 4)
        
        ServerAPI.getUserCalls({ (result) -> Void in
            self.calls = result
            self.calls = self.updateStartDate(self.calls)
            self.filteredCalls = self.calls
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicator.stopAnimating()
                //self.filterResults(TimeUtils.getDateFromComponents(self.currYear, month: nil, day: self.offset))
                self.monthPicker.selectItem(self.selectedMonth-1, animated: true)
                self.dayPicker.selectItem(20, animated: true)
            }
        })
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "pullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }
    
    func pullRefresh(sender:AnyObject){
        ServerAPI.getUserCalls({ (result) -> Void in
            self.calls = result
            self.calls = self.updateStartDate(self.calls)
            self.filteredCalls = self.calls
            dispatch_async(dispatch_get_main_queue()){
                self.filterResults(TimeUtils.getDateFromComponents(self.currYear, month: nil, day: self.offset))
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {

    }

    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        if monthPicker == pickerView {
            return 12
        } else {
            return 40//TimeUtils.getYearNumberOfDays(currYear!)
        }
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        if monthPicker == pickerView {
            return months[item]
        } else{
            let date = TimeUtils.getDateFromComponents(currYear, month: nil, day: item + 1 + offset-21)
            let comp = TimeUtils.getDateComponentsFromDate(date)
            return String(format: "%02d", comp.day)
        }
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        if monthPicker == pickerView {
            if selectedMonth != item + 1{
                selectedMonth = item + 1
                let currDate = TimeUtils.getDateFromComponents(currYear, month: nil, day: offset)
                offset = TimeUtils.getDayInYear(TimeUtils.getDateFromComponents(currYear, month: selectedMonth, day: TimeUtils.getDateComponentsFromDate(currDate).day))
                dayPicker.scrollToItem(20, animated: true)
            }
        } else {
            selectedDay = item+1
            offset =  offset + (selectedDay - 21)
            
            monthPicker.selectItem(TimeUtils.getMonthFromDate(TimeUtils.getDateFromComponents(currYear, month: nil, day: offset))-1, animated: true)
            
            dayPicker.reloadData()
            if (dayPicker.selectedItem != 20){
                dayPicker.selectItem(20, animated: false)
            }
        }
        //println(TimeUtils.getDateFromComponents(currYear!, month: nil, day: offset))
        filterResults(TimeUtils.getDateFromComponents(currYear, month: nil, day: offset))
    }

    
    func filterResults(date: NSDate){

        let resultPredicate = NSPredicate(format: "start >= %@ AND start <= %@", argumentArray:[date, date.dateByAddingTimeInterval(60*60*24)])
        if calls.count > 0 {
            filteredCalls = self.calls.filteredArrayUsingPredicate(resultPredicate)
            if (filteredCalls.count == 0){
                //self.tableView.hidden = true
            } else {
                self.tableView.hidden = false
            }
            self.tableView.reloadData()
        }
    }
    
    func updateStartDate(arr: NSArray) -> NSArray{
        var timedCalls : NSMutableArray = []
        for (var index = 0; index < arr.count; ++index){
            let time: NSDate  = TimeUtils.serverDateTimeStrToDate(calls[index]["start"] as! String)
            let endTime: NSDate  = TimeUtils.serverDateTimeStrToDate(calls[index]["end"] as! String)
            let callee = calls[index]["callee"] as! NSDictionary
            let product = calls[index]["product"] as! NSDictionary
            let resources = calls[index]["resources"] as! NSArray
            let id = calls[index]["id"] as! NSNumber
            let item = ["start": time, "callee": callee, "product": product, "end": endTime, "id": id, "resources": resources] as Dictionary<String,AnyObject>
            timedCalls[index] = item
        }
        
        return timedCalls
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
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredCalls.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("zoneCallCell") as! ZoneCallTableViewCell
        if let call = filteredCalls[indexPath.row] as? NSDictionary {
            let product = call["product"] as! NSDictionary
            cell.drug.attributedText = ViewUtils.getAttrText(product["name"] as! String, color: UIColor.lightGrayColor(), size: 20.0, fontName:"OpenSans-Light")
            cell.time.attributedText = ViewUtils.getAttrText(TimeUtils.dateToReadableTimeStr(call["start"] as! NSDate), color: UIColor.grayColor(), size: 24.0, fontName:"OpenSans")
            let callee = call["callee"] as! NSDictionary
            let firstName = (callee["user"] as? NSDictionary)?["first_name"] as! String
            let lastName = (callee["user"] as? NSDictionary)?["last_name"] as! String
            cell.rep.attributedText = ViewUtils.getAttrText("\(firstName) \(lastName)", color: UIColor.grayColor(), size: 24.0, fontName:"OpenSans")
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let call = filteredCalls[indexPath.row] as? NSDictionary {
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
    
    
    @IBAction func createNewCall(sender: AnyObject) {
    }
    


}
