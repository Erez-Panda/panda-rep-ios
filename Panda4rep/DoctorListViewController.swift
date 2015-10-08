//
//  DoctorListViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 5/13/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
import FontAwesomeIconFactory

class DoctorListViewController: UIViewController, MPGTextFieldDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var newContactView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var specialty: MPGTextField_Swift!
    
    @IBOutlet weak var searchTitleView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var address: UITextField!
    
    
    @IBOutlet weak var presentedName: UILabel!
    @IBOutlet weak var presentedEmail: UILabel!
    @IBOutlet weak var newContactTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectDoctorButton: UIButton!
    @IBOutlet weak var editDoctorButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var specialties : [Dictionary<String, AnyObject>] = []
    var doctors : NSMutableArray = []
    var filteredDoctors = []
    var selectedSpecialty : NSDictionary?
    var refreshControl : UIRefreshControl!
    var selectedDoctor : NSDictionary?
    var editMode = false
    
    var doctorUsers : NSArray = []
    var filteredDoctorUsers = []
    
    var parentVC : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        specialty.mDelegate = self
        // Do any additional setup after loading the view.
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        ViewUtils.slideViewOutVertical(newContactView, animate: false)
        ServerAPI.getDictionary("doctor_specialty", completion: { (result) -> Void in
            for i in 0..<result.count{
                if let specialty = result[i] as? NSDictionary{
                    self.specialties.append(["DisplayText":specialty["name"] as! String, "id": specialty["id"] as! NSNumber])
                }
            }
        })
        ServerAPI.getRepDoctors { (result) -> Void in
            self.doctorUsers = result
            self.filteredDoctorUsers = self.doctorUsers
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
            }
        }
        doctors = NSMutableArray(array: StorageUtils.getItems(StorageUtils.DataType.DoctorContact))
        filteredDoctors = doctors
        presnetDoctorAtIndexPath(NSIndexPath(forRow: 0,inSection: 0))

        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "pullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    func pullRefresh(sender:AnyObject){
        ServerAPI.getContacts({ (result) -> Void in
            StorageUtils.setItems(StorageUtils.DataType.DoctorContact, items: result)
            self.doctors = NSMutableArray(array: result)
            self.filteredDoctors = self.doctors
            dispatch_async(dispatch_get_main_queue()){
                self.refreshControl.endRefreshing()
                self.presnetDoctorAtIndexPath(NSIndexPath(forRow:0,inSection: 0))
                self.tableView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        ViewUtils.rightBorderView(searchTitleView, borderWidth: 1, borderColor: UIColor.lightGrayColor())
        ViewUtils.rightBorderView(searchBar, borderWidth: 1, borderColor: UIColor.lightGrayColor())
        ViewUtils.rightBorderView(tableView, borderWidth: 1, borderColor: UIColor.lightGrayColor())
    }
    
    func dataForPopoverInTextField(textfield: MPGTextField_Swift) -> [Dictionary<String, AnyObject>] {
        return specialties
    }
    
    func textFieldDidEndEditing(textField: MPGTextField_Swift, withSelection data: Dictionary<String, AnyObject>) {
        selectedSpecialty = data
    }
    
    func textFieldShouldSelect(textField: MPGTextField_Swift) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.firstName){
            self.lastName.becomeFirstResponder()
        } else if (textField == self.lastName){
            self.email.becomeFirstResponder()
        } else if (textField == self.email){
            self.specialty.becomeFirstResponder()
        } else if (textField == self.specialty){
            self.phone.becomeFirstResponder()
        } else if (textField == self.phone){
            self.address.becomeFirstResponder()
        } else if (textField == self.address){
            textField.resignFirstResponder()
            self.saveNewContact(UIButton())
        }
        return true
    }
    

    @IBAction func addContact(sender: NIKFontAwesomeButton) {
        newContactTopConstraint.constant = UIScreen.mainScreen().bounds.height
        newContactView.hidden = false
        deleteButton.hidden = true
        ViewUtils.slideViewinVertical(newContactView)
    }
    
    @IBAction func cancelNewContact(sender: UIButton) {
        cleanNewCotactForm()
        ViewUtils.slideViewOutVertical(newContactView, animate: !editMode)
        newContactTopConstraint.constant = 0
        editMode = false
    }
    

    @IBAction func saveNewContact(sender: UIButton) {
        var data: Dictionary<String, AnyObject> = [:]
        if (!firstName.text!.isEmpty && !lastName.text!.isEmpty && !email.text!.isEmpty) {
            data = ["first_name": firstName.text!,
                "last_name":lastName.text!,
                "email": email.text! ] as Dictionary<String, AnyObject>
            if let spec_id = selectedSpecialty?["id"] as? NSNumber{
                data["specialty"] = spec_id
            }
            if !phone.text!.isEmpty {
                data["phone"] = phone.text!
            }
            if !address.text!.isEmpty {
                data["address"] = address.text!
            }
            if editMode{
                if let id = selectedDoctor?["id"] as? NSNumber{
                    ServerAPI.updateContact(data, id: id, completion: { (result) -> Void in
                    })
                }
                editMode = false
            } else {
                ServerAPI.newContact(data, completion: { (result) -> Void in
                    if let id = result["id"] as? NSNumber{
                        data["id"] = id
                    }
                    StorageUtils.addItem(StorageUtils.DataType.DoctorContact, dictionary: data)
                    self.doctors.addObject(data)
                    self.filteredDoctors = self.doctors
                    dispatch_async(dispatch_get_main_queue()){
                        self.tableView.reloadData()
                    }
                })
            }


            ViewUtils.slideViewOutVertical(newContactView, animate: true)
            newContactTopConstraint.constant = 0
            cleanNewCotactForm()
        }
    }
    func cleanNewCotactForm(){
        firstName.text = ""
        lastName.text = ""
        email.text = ""
        phone.text = ""
        address.text = ""
        specialty.text = ""
    }
    
    @IBAction func selectDoctor(sender: UIButton) {
        if selectedDoctor != nil {
            if let vc = parentVC as? CreateCallViewController{
                vc.selectDoctor(selectedDoctor!)
            }
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
            })
        }
    }
    
    @IBAction func editContact(sender: UIButton) {
        if let doctor = selectedDoctor {
            editMode = true
            deleteButton.hidden = false
            firstName.text = doctor["first_name"] as? String
            lastName.text = doctor["last_name"] as? String
            email.text = doctor["email"] as? String
            phone.text = doctor["phone"] as? String
            address.text = doctor["address"] as? String
            if let s_id = doctor["specialty"] as? NSNumber{
                specialty.text = getSpecialtyName(s_id)
            }
            newContactTopConstraint.constant = UIScreen.mainScreen().bounds.height
            newContactView.hidden = false
            ViewUtils.slideViewinVertical(newContactView, animate: false)
        }
    }
    
    @IBAction func deleteContact(sender: UIButton) {
        if let id = selectedDoctor?["id"] as? NSNumber{
            ServerAPI.deleteContact(id, completion: { (result) -> Void in
                
            })
            self.doctors.removeObject(selectedDoctor!)
            self.filteredDoctors = self.doctors
            self.tableView.reloadData()
            StorageUtils.setItems(StorageUtils.DataType.DoctorContact, items: doctors)
            cancelNewContact(sender)
        }
    }
    func getSpecialtyName(id: NSNumber) -> String{
        for specialty in specialties{
            if let s_id = specialty["id"] as? NSNumber{
                if id == s_id{
                    return specialty["DisplayText"] as! String
                }
            }
        }
        return ""
    }
    
    
    @IBAction func cancelSelection(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.filteredDoctors.count
        } else {
            return self.filteredDoctorUsers.count
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("doctorCell")!
        let doctorsArray = (indexPath.section == 0) ? filteredDoctors : filteredDoctorUsers
        if var doctor = doctorsArray[indexPath.row] as? NSDictionary {
            if let user = doctor["user"] as? NSDictionary {
                doctor = user
            }
            let firstName = doctor["first_name"] as? String
            let lastName = doctor["last_name"] as? String
            if firstName != nil && lastName != nil {
                cell.textLabel?.text = "\(firstName!) \(lastName!)"
            } else {
                 cell.textLabel?.text = doctor["email"] as? String
            }
        }
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        presnetDoctorAtIndexPath(indexPath)
        if (editMode){
            editContact(UIButton())
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            if self.filteredDoctors.count > 0 {
                return " Contacts"
            } else {
                return nil
            }
        } else {
            if self.filteredDoctorUsers.count > 0 {
                return " Registered Users"
            } else {
                return nil
            }
        }
    }
    
    
    func presnetDoctorAtIndexPath(indexPath: NSIndexPath){
        let doctorsArray = (indexPath.section == 0) ? filteredDoctors : filteredDoctorUsers
        if doctorsArray.count > indexPath.row{
            if var doctor = doctorsArray[indexPath.row] as? NSDictionary {
                if let user = doctor["user"] as? NSDictionary {
                    selectedDoctor = doctor
                    editDoctorButton.hidden = true
                    if editMode {
                        cancelNewContact(UIButton())
                    }
                    doctor = user
                }
                let firstName = doctor["first_name"] as? String
                let lastName = doctor["last_name"] as? String
                if firstName != nil && lastName != nil {
                    presentedName.text = "\(firstName!) \(lastName!)"
                } else {
                    presentedName.text = "Unknown"
                }
                presentedEmail.text = doctor["email"] as? String
                if indexPath.section == 0 {
                    selectedDoctor = doctor
                    editDoctorButton.hidden = false
                }
                selectDoctorButton.hidden = false
            }
        } else {
            presentedName.text = ""
            presentedEmail.text = ""
            selectDoctorButton.hidden = true
            editDoctorButton.hidden = true
        }

    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredDoctors = doctors
            filteredDoctorUsers = doctorUsers
        } else {
            if doctors.count > 0 {
                let resultPredicate = NSPredicate(format: "first_name contains[c] %@ OR last_name contains[c] %@", argumentArray:[searchText, searchText] )
                filteredDoctors = self.doctors.filteredArrayUsingPredicate(resultPredicate)
            }
            if  doctorUsers.count > 0 {
                let resultPredicate = NSPredicate(format: "user.first_name contains[c] %@ OR user.last_name contains[c] %@", argumentArray:[searchText, searchText] )
                filteredDoctorUsers = self.doctorUsers.filteredArrayUsingPredicate(resultPredicate)
            }
        }
        self.tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
