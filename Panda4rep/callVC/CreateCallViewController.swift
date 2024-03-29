//
//  CreateCallViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 4/30/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class CreateCallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var doctorView: UIView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var timeView: UIView!
    
    var doctorViewHeightConst: NSLayoutConstraint?
    var productViewHeightConst: NSLayoutConstraint?
    var timeViewHeightConst: NSLayoutConstraint?
    
    var doctors = []
    var products = []
    
    @IBOutlet weak var doctorsTable: UITableView!
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var toggleDoctorButton: UIButton!
    @IBOutlet weak var toggleProductButton: UIButton!
    @IBOutlet weak var toggleTimeButton: UIButton!
    
    var selectedDoctor: NSDictionary?
    var selectedProduct: NSDictionary?
    var selectedDate: NSDate?
    
    var parent: HomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.hidden = true
        datePicker.minimumDate = NSDate()
        
        ServerAPI.getAssignedProducts { (result) -> Void in
            self.products = result
            dispatch_async(dispatch_get_main_queue()){
                self.productTable.reloadData()
            }
        }
        /*
        ServerAPI.getRepDoctors { (result) -> Void in
            self.doctors = result
            dispatch_async(dispatch_get_main_queue()){
                self.doctorsTable.reloadData()
            }
        }
*/
        doctorView.layoutIfNeeded()
        productView.layoutIfNeeded()
        timeView.layoutIfNeeded()
        let borderColor = ColorUtils.uicolorFromHex(0xF1F1F1)
        ViewUtils.topBorderView(productView, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        ViewUtils.topBorderView(timeView, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        ViewUtils.bottomBorderView(timeView, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        
        
        doctorViewHeightConst = ViewUtils.addSizeConstaints(doctorView, width: nil, height: 70)[1]
        productViewHeightConst = ViewUtils.addSizeConstaints(productView, width: nil, height: 70)[1]
        timeViewHeightConst = ViewUtils.addSizeConstaints(timeView, width: nil, height: 70)[1]
        
        doctorsTable.layoutMargins = UIEdgeInsetsZero
        doctorsTable.separatorInset = UIEdgeInsetsZero
        
        productTable.layoutMargins = UIEdgeInsetsZero
        productTable.separatorInset = UIEdgeInsetsZero
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func toggleView(view: UIView){
        var constraint : NSLayoutConstraint?
        var button : UIButton?
        if view == doctorView {
            constraint = doctorViewHeightConst!
            button = toggleDoctorButton
        } else if view == productView {
            constraint = productViewHeightConst!
            button = toggleProductButton
        } else if view == timeView {
            constraint = timeViewHeightConst!
            button = toggleTimeButton
        }
        if let b = button{
            if b.selected {
                b.selected = false
                constraint?.constant = 70
                if view == timeView {
                    datePicker.hidden = true
                }
            } else {
                b.selected = true
                constraint?.constant = 300
                if view == timeView {
                    datePicker.hidden = false
                }
            }
        }
    }

    @IBAction func toggleDoctorView(sender: UIButton) {
        //toggleView(doctorView)
    }
    
    
    @IBAction func toggleProductView(sender: UIButton) {
        toggleView(productView)
    }
    
    @IBAction func toggleTimeView(sender: UIButton) {
        toggleView(timeView)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.parent?.pullRefresh(sender)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == productTable{
            return products.count
            
        } else if tableView == doctorsTable{
            return doctors.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == productTable{
            let cell = tableView.dequeueReusableCellWithIdentifier("productCell") as! TableViewCellWithLabelAndButton
            if let product = self.products[indexPath.row]["product"] as? NSDictionary{
                cell.label.text = product["name"] as? String
            }
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
            
        } else if tableView == doctorsTable{
            let cell = tableView.dequeueReusableCellWithIdentifier("doctorCell") as! TableViewCellWithLabelAndButton
            if let user = self.doctors[indexPath.row]["user"] as? NSDictionary{
                let firstName = user["first_name"] as! String
                let lastName = user["last_name"] as! String
                cell.label.text = "Dr. \(firstName) \(lastName)"
            }
            cell.layoutMargins = UIEdgeInsetsZero
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TableViewCellWithLabelAndButton
        if tableView == productTable{
            productLabel.text = cell.label.text
            productLabel.textColor = UIColor.blackColor()
            toggleView(productView)
            selectedProduct = self.products[indexPath.row]["product"] as? NSDictionary
            
        } else if tableView == doctorsTable{
            doctorLabel.text = cell.label.text
            doctorLabel.textColor = UIColor.blackColor()
            toggleView(doctorView)
            selectedDoctor = self.doctors[indexPath.row] as? NSDictionary
        }
    }
    
    func selectDoctor(doctor: NSDictionary){
        var doc = doctor
        if let user = doctor["user"] as? NSDictionary {
            doc = user
        }
        let lastName = doc["last_name"] as? String
        if lastName != nil {
            doctorLabel.text = "Dr. \(lastName!)"
        } else {
            doctorLabel.text = "Unknown"
        }
        doctorLabel.textColor = UIColor.blackColor()
        selectedDoctor = doctor
    }
    
    @IBAction func dateChanged(sender: AnyObject) {
        selectedDate = datePicker.date
        timeLabel.text = TimeUtils.dateToReadableStr(datePicker.date)
        timeLabel.textColor = UIColor.blackColor()
    }
    

    @IBAction func createCall(sender: AnyObject) {
        self.activity.startAnimating()
        let userId = StorageUtils.getUserData(StorageUtils.DataType.Profile)["id"] as! NSNumber
        if let doc = selectedDoctor{
            if let prod = selectedProduct{
                if let date = selectedDate{
                    var callData = [
                        "caller": userId,
                        "title": "Call created by rep",
                        "start": TimeUtils.dateToServerString(date),
                        "end": TimeUtils.dateToServerString(date.dateByAddingTimeInterval(20*60)),
                        "product": prod["id"] as! NSNumber
                        ] as Dictionary<String,AnyObject>
                    var newCall = ServerAPI.newGuestCall
                    if nil != doc["user"] as? NSDictionary { //Real user
                        callData["callee"] = doc["id"] as! NSNumber
                        newCall = ServerAPI.newCall
                    } else { // Guest user
                        callData["guest_callee"] = doc["id"] as! NSNumber
                    }
                    newCall(callData, completion: { (result) -> Void in
                        dispatch_async(dispatch_get_main_queue()){
                            self.activity.stopAnimating()
                            if let error = result["error"] as? String{
                                ViewUtils.showSimpleError(error)
                            } else {
                                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "CallCreated", object: result))
                            }
                            self.cancel(UIButton())
                        }
                    })
                } else {
                    self.activity.stopAnimating()
                    ViewUtils.showSimpleError("Please select date")
                }
            } else {
                self.activity.stopAnimating()
                ViewUtils.showSimpleError("Please select product")
            }
        } else {
            self.activity.stopAnimating()
            ViewUtils.showSimpleError("Please select callee")
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showDoctorList"){
            let svc = segue.destinationViewController as! DoctorListViewController
            svc.parentVC = self
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
