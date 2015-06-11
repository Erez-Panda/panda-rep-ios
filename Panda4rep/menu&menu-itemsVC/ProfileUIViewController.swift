//
//  ProfileUIViewController.swift
//  Panda4doctor
//
//  Created by Erez on 1/27/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class ProfileUIViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var user: NSDictionary?
    var userProfile : NSDictionary?
    var userKeys = ["specialty","phone", "email", "password"]
    var doctorSpecialties: NSArray?
    var specialtyCell : ProfileTableViewCell?
    @IBOutlet weak var profileTable: UITableView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    func getDoctorSpecialtyById(id: Int) -> String{
        if let ds = doctorSpecialties {
            for specilty in ds {
                if id == specilty["id"] as! Int{
                    return specilty["name"] as! String
                }
            }
        }
        return ""
    }
    
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfile = StorageUtils.getUserData(StorageUtils.DataType.Profile)
        ViewUtils.setBackButton(self)
        if iOS8{
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.tableFooterView = UIView(frame: CGRectZero)
        ViewUtils.getProfileImage { (result) -> Void in
            self.profileImage.image = result
        }
        ServerAPI.getDictionary("doctor_specialty") { (result) -> Void in
            self.doctorSpecialties = result
            let val = self.getDoctorSpecialtyById(self.userProfile?["specialty"] as! Int)
            let text = ViewUtils.getAttrText(val, color: UIColor.blackColor(), size: 16.0)
            dispatch_async(dispatch_get_main_queue()){
                self.specialtyCell!.valueLabel.attributedText = text
            }
            
        }
        ViewUtils.roundView(profileImage, borderWidth: 2.0, borderColor: ColorUtils.buttonColor())
        

        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        userProfile = StorageUtils.getUserData(StorageUtils.DataType.Profile)
        user = StorageUtils.getUserData(StorageUtils.DataType.User)
        let firstName = user?["first_name"] as! String
        let lastName = user?["last_name"] as! String
        nameLabel.attributedText = ViewUtils.getAttrText("Dr. \(firstName) \(lastName)", color: UIColor.whiteColor(), size: 20.0, fontName: "OpenSans-Semibold")
        let val = self.getDoctorSpecialtyById(self.userProfile?["specialty"] as! Int)
        let text = ViewUtils.getAttrText(val, color: UIColor.blackColor(), size: 16.0)
        self.specialtyCell?.valueLabel.attributedText = text
        profileTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userKeys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell") as! ProfileTableViewCell
        let key = self.userKeys[indexPath.row] as String
        cell.titleLabel.attributedText = ViewUtils.getAttrText("\(key):", color: UIColor.lightGrayColor(), size: 16.0)
        if key == "specialty" {
            specialtyCell = cell
            let val = self.getDoctorSpecialtyById(self.userProfile?["specialty"] as! Int)
            cell.valueLabel.attributedText = ViewUtils.getAttrText(val, color: UIColor.blackColor(), size: 16.0)
        } else if var val = self.user?[key] as? String {
            if key == "password" {
                val = "*********"
            }
            cell.valueLabel.attributedText = ViewUtils.getAttrText(val, color: UIColor.blackColor(), size: 16.0)
            
        } else if var val = self.userProfile?[key] as? String {
            cell.valueLabel.attributedText = ViewUtils.getAttrText(val, color: UIColor.blackColor(), size: 16.0)
        }
        if iOS8 {cell.layoutMargins = UIEdgeInsetsZero}
        return cell
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showEditProfile"){
            let svc = segue.destinationViewController as! EditProfileViewController
            svc.user = user
            svc.userProfile = userProfile
            svc.doctorSpecialties = doctorSpecialties
        }
    }

    
    @IBAction func openMenu(sender: AnyObject) {
        ViewUtils.slideInMenu(self)
    }
    /*
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
*/

    
}
