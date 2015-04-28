//
//  HomeViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 4/23/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menu(){
        ViewUtils.slideInMenu(self)
    }
    

    var calls: NSArray = []
    var filteredCalls : NSArray = []
    enum FilterType {
        case Future
        case Past
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtils.setMenuButton(self)
        activityIndicator.startAnimating()
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        

        ServerAPI.getUserCalls({ (result) -> Void in
            self.calls = result
            self.calls = self.updateStartDate(self.calls)
            self.filteredCalls = self.calls
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicator.stopAnimating()
                self.filterResults(.Future)
            }
        })
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func segmentSelection(sender: UISegmentedControl) {
        let selectedSegment = sender.selectedSegmentIndex;
        
        
        if (selectedSegment == 0) {
            filterResults(.Future)
        }
        else{
            filterResults(.Past)
        }
        
        
        
    }
    
    func filterResults(type: FilterType){
        let startDate = NSDate()
        var resultPredicate: NSPredicate?
        
        if (type == .Future) {
            resultPredicate = NSPredicate(format: "start >= %@", startDate)
        }
        else{
            resultPredicate = NSPredicate(format: "start <= %@", startDate)
        }
        
        filteredCalls = self.calls.filteredArrayUsingPredicate(resultPredicate!)
        if (filteredCalls.count == 0){
            self.tableView.hidden = true
        } else {
            self.tableView.hidden = false
        }
        self.tableView.reloadData()
    }
    
    func updateStartDate(arr: NSArray) -> NSArray{
        var timedCalls : NSMutableArray = []
        for (var index = 0; index < arr.count; ++index){
            let time: NSDate  = TimeUtils.serverDateTimeStrToDate(calls[index]["start"] as! String)
            let callee = calls[index]["callee"] as! NSDictionary
            let product = calls[index]["product"] as! NSDictionary
            let item = ["start": time, "callee": callee, "product": product] as Dictionary<String,AnyObject>
            timedCalls[index] = item
        }
        
        return timedCalls
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
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
            cell.drug.attributedText = ViewUtils.getAttrText(product["name"] as! String, color: UIColor.blackColor(), size: 18.0, fontName:"OpenSans-Bold")
            cell.time.text = TimeUtils.dateToReadableStr(call["start"] as! NSDate)
            let callee = call["callee"] as! NSDictionary
            let firstName = (callee["user"] as? NSDictionary)?["first_name"] as! String
            let lastName = (callee["user"] as? NSDictionary)?["last_name"] as! String
            cell.rep.text = "\(firstName) \(lastName)"
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    


}
