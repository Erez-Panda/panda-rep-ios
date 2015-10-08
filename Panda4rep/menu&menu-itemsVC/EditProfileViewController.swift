//
//  EditProfileViewController.swift
//  Panda4doctor
//
//  Created by Erez on 1/27/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var user: NSDictionary!
    var userProfile : NSDictionary!
    var userKeys = ["specialty","phone", "email"]
    var doctorSpecialties: NSArray!
    var specialtyId: NSNumber?
    var noChange = true
    var newProfile : Dictionary<String, AnyObject>?
    var imagePicker: UIImagePickerController?
    var imageChange = false
    
    @IBOutlet weak var specialtyTable: UITableView!
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    func back(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewUtils.setBackButton(self)
        newProfile = userProfile as? Dictionary<String, AnyObject>
        if iOS8{
            profileTable.layoutMargins = UIEdgeInsetsZero
        }
        profileTable.separatorInset = UIEdgeInsetsZero
        profileTable.tableFooterView = UIView(frame: CGRectZero)
        
        if iOS8{
            specialtyTable.layoutMargins = UIEdgeInsetsZero
        }
        specialtyTable.separatorInset = UIEdgeInsetsZero
        
        ViewUtils.getProfileImage { (result) -> Void in
            self.profileImage.image = result
        }
        ViewUtils.roundView(profileImage, borderWidth: 2.0, borderColor: ColorUtils.buttonColor())

        ViewUtils.borderView(galleryButton, borderWidth: 1.0, borderColor: UIColor.whiteColor(), borderRadius: 3)
        ViewUtils.borderView(photoButton, borderWidth: 1.0, borderColor: UIColor.whiteColor(), borderRadius: 3)
        
        let firstName = user["first_name"] as! String
        let lastName = user["last_name"] as! String
        registerForKeyboardNotifications()
        
        // Do any additional setup after loading the view.
        UIEventRegister.tapRecognizer(self, action:"closeKeyboard:")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        takeProfilePhoto(.Camera)
    }
    
    @IBAction func choosePhoto(sender: AnyObject) {
        takeProfilePhoto(.PhotoLibrary)
    }
    
    func takeProfilePhoto(type: UIImagePickerControllerSourceType) {
        imagePicker =  UIImagePickerController()
        imagePicker!.delegate = self
        imagePicker!.sourceType = type
        
        presentViewController(imagePicker!, animated: true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        profileImage.image = image
        imageChange = true
    }
    
    func closeKeyboard(sender : AnyObject){
        let tap = sender as! UITapGestureRecognizer
        profileTable.resignFirstResponder()

        if (!specialtyTable.hidden){
            if let indexPath = specialtyTable.indexPathForRowAtPoint(tap.locationInView(specialtyTable)){
                if let specilaty = self.doctorSpecialties[indexPath.row] as? NSDictionary{
                    let specialtyButtonCell = profileTable.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as! TableViewCellWithButtonAndTitle
                    newProfile?["specialty"] = specilaty["id"] as? NSNumber
                    profileTable.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                    
                    
                }
            }
            ViewUtils.slideViewOutVertical(specialtyTable)
        }
        
    }
    
    
    @IBAction func save(sender: AnyObject) {
        //activityIndicator.startAnimating()
        let nameCell = profileTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! SplitTableViewCellWithTitle

        if imageChange {
            ServerAPI.uploadFile(UIImageJPEGRepresentation(profileImage.image!, 1.0)!, filename: "\(nameCell.lastNameTextField.text)_profile_image") { (result) -> Void in
                let file = result as! NSDictionary
                ViewUtils.profileImage = nil
                self.saveProfile(file["id"] as! NSNumber)
                
            }
        } else {
            saveProfile(-1)
        }

    }
    
    func saveProfile(imageId: NSNumber){
        let userId = StorageUtils.getUserData(StorageUtils.DataType.Profile)["id"] as! NSNumber
        let nameCell = profileTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! SplitTableViewCellWithTitle
        let emailCell = profileTable.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as? TableViewCellWithTitle
        let phoneCell = profileTable.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? TableViewCellWithTitle
        

        
        var user = ["first_name":nameCell.firstNameTextField.text!,
            "last_name": nameCell.lastNameTextField.text!,
            "email": self.user["email"] as! String] as Dictionary<String,AnyObject>
        if (emailCell != nil) {
            user["email"] = emailCell!.textInput.text
        }
        StorageUtils.updateUser(user, type: StorageUtils.DataType.User)
        user["password"] = "123" //Changes nothing, just for server integrity
        var userData = ["specialty": self.specialtyId!] as Dictionary<String,AnyObject>
        if imageId.integerValue > -1 {
            userData["image_file"] = imageId
            ViewUtils.profileImage = nil
        }
        if (phoneCell != nil) {
            userData["phone"] = phoneCell!.textInput.text
        }
        StorageUtils.updateUser(userData, type: StorageUtils.DataType.Profile)
        userData["user"] = user
        ServerAPI.updateUser(userData , id: userId, completion: {result -> Void in
            dispatch_async(dispatch_get_main_queue()){
                self.back()
            }
        })
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == profileTable){
            return self.userKeys.count+1
        } else {
            return doctorSpecialties.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == specialtyTable{
            let cell = tableView.dequeueReusableCellWithIdentifier("specialtyCell")!
            if  indexPath.row < doctorSpecialties.count {
                if let specilaty = self.doctorSpecialties[indexPath.row] as? NSDictionary{
                    cell.textLabel?.textColor = ColorUtils.uicolorFromHex(0x777777)
                    cell.textLabel?.font = UIFont(name: "OpenSans", size: 14.0)
                    cell.textLabel?.text = specilaty["name"] as? String
                }
            }
            if iOS8 {cell.layoutMargins = UIEdgeInsetsZero}
            return cell
        } else {
            if (indexPath.row == 0){
                let cell = tableView.dequeueReusableCellWithIdentifier("firstLastNameCell") as! SplitTableViewCellWithTitle
                cell.firstNameTextField.text = user["first_name"] as! String
                cell.lastNameTextField.text = user["last_name"] as! String
                if iOS8 {cell.layoutMargins = UIEdgeInsetsZero}
                return cell
                
            }
            
            let key = self.userKeys[indexPath.row-1] as String
            if (key == "specialty"){// || key == "sub-specialty"){
                let cell = tableView.dequeueReusableCellWithIdentifier("editProfileButtonCell") as! TableViewCellWithButtonAndTitle
                specialtyId = self.newProfile?["specialty"] as! Int
                let val = self.getDoctorSpecialtyById(self.newProfile?["specialty"] as! Int)
                cell.button.setAttributedTitle(ViewUtils.getAttrText(val, color: UIColor.blackColor(), size: 14.0), forState: UIControlState.Normal)
                cell.button.addTarget(self, action: "openSpecialtyMenu", forControlEvents: UIControlEvents.TouchUpInside)
                cell.dropDown.addTarget(self, action: "openSpecialtyMenu", forControlEvents: UIControlEvents.TouchUpInside)
                cell.label.text = key
                if iOS8 {cell.layoutMargins = UIEdgeInsetsZero}
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("editProfileCell") as! TableViewCellWithTitle
                var value  = ""
                if (key == "email"){
                    cell.textInput.userInteractionEnabled = false
                }
                if let text = self.user[key] as? String{
                    value = text
                } else if let text = self.userProfile[key] as? String{
                    value = text
                }
                cell.textInput.text = value
                cell.label.text = key
                if iOS8 {cell.layoutMargins = UIEdgeInsetsZero}
                return cell
            }
        }
    }
    
    func openSpecialtyMenu(){
        specialtyTable.hidden = false
        ViewUtils.slideViewinVertical(specialtyTable)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (tableView == profileTable){
            return 66.0
        } else {
            return 55.0
        }
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeShown:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    func keyboardWillBeShown(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  -= (keyboardSize.height-50)
        })
    }
    func keyboardWillBeHidden(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0
        })
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
