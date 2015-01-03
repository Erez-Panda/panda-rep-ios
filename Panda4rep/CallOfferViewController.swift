//
//  CallOfferViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/25/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class CallOfferViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate{

    @IBOutlet var offersTable: UITableView!
    
    var callOffers: NSArray!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.callOffers.count
    }
    
    @IBAction func showOffer(sender: AnyObject) {
        
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("callOfferCell") as UITableViewCell
        let callOffer = self.callOffers[indexPath.row] as NSDictionary
        let request = callOffer["call_request"] as NSDictionary
        let startTime = request["start"] as NSString
        let date = TimeUtils.serverDateTimeStrToDate(startTime)
        var readableTime = TimeUtils.dateToReadableStr(date)
        cell.textLabel?.text = readableTime
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let callOffer = self.callOffers[indexPath.row] as NSDictionary
        let request = callOffer["call_request"] as NSDictionary
        //let product = request["product"] as NSDictionary
        let pName = "product"//product["name"] as NSString
        let startTime = request["start"] as NSString
        
        showAcceprCallAlert(["product": pName, "start":startTime, "offer_id": callOffer["id"] as NSNumber])
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        ServerAPI.getUserCallOffers({result -> Void in
                self.callOffers = result
                dispatch_async(dispatch_get_main_queue()){
                    self.offersTable.reloadData()
                }
            })
        self.callOffers = []
    }
    
    func alertView(alertView: UIAlertViewWithData, didDismissWithButtonIndex buttonIndex: Int) {
        println(buttonIndex)
        if (buttonIndex == 0){ //Accept
            if let offerId: AnyObject = alertView.data?["offer_id"] {
                ServerAPI.acceptCallOffer(offerId as NSNumber, completion: {result -> Void in
                    
                })
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func showAcceprCallAlert(userInfo: AnyObject){
        let product = userInfo["product"] as String
        let start = userInfo["start"] as String
        let offerId = userInfo["offer_id"] as NSNumber
        
        
        let date = TimeUtils.serverDateTimeStrToDate(start)
        var readableTime = TimeUtils.dateToReadableStr(date)
        var acceptCallAlert = UIAlertViewWithData()
        
        acceptCallAlert.title = "New Call Offer"
        acceptCallAlert.message = "Call about \(product) will take place on \(readableTime), Would you like to accept it?"
        acceptCallAlert.addButtonWithTitle("Accept")
        acceptCallAlert.addButtonWithTitle("Cancel")
        acceptCallAlert.delegate = self
        acceptCallAlert.data = ["offer_id": offerId]
        acceptCallAlert.show()
    }

    
    
    
}
