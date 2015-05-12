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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.hidden = true
        datePicker.minimumDate = NSDate()
        datePicker.minuteInterval = 30
        
        ServerAPI.getAssignedProducts { (result) -> Void in
            self.products = result
            dispatch_async(dispatch_get_main_queue()){
                self.productTable.reloadData()
            }
        }
        
        ServerAPI.getRepDoctors { (result) -> Void in
            self.doctors = result
            dispatch_async(dispatch_get_main_queue()){
                self.doctorsTable.reloadData()
            }
        }
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
        toggleView(doctorView)
    }
    
    
    @IBAction func toggleProductView(sender: UIButton) {
        toggleView(productView)
    }
    
    @IBAction func toggleTimeView(sender: UIButton) {
        toggleView(timeView)
    }
    
    @IBAction func cancel(sender: AnyObject) {
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
                    let callData = [
                        "caller": userId,
                        "callee": doc["id"] as! NSNumber,
                        "title": "Call created by rep",
                        "start": TimeUtils.dateToServerString(date),
                        "end": TimeUtils.dateToServerString(date.dateByAddingTimeInterval(20*60)),
                        "product": prod["id"] as! NSNumber
                        ] as Dictionary<String,AnyObject>
                    ServerAPI.newCall(callData, completion: { (result) -> Void in
                        dispatch_async(dispatch_get_main_queue()){
                            self.activity.stopAnimating()
                        }
                        // check if call was created
                        dispatch_async(dispatch_get_main_queue()){
                            self.cancel(UIButton())
                        }
                    })
                }
            }
        }

    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
