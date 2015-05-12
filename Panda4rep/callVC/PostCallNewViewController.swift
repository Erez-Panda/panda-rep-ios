//
//  PostCallNewViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/6/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
import FontAwesomeIconFactory

class PostCallNewViewController: PandaViewController, FloatRatingViewDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var callerNameLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var nextTimeTextView: UITextView!
    @IBOutlet weak var followupTextView: UITextView!
    
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var nextTimeView: UIView!
    @IBOutlet weak var followupView: UIView!
    
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var attacmentTable: UITableView!
    
    @IBOutlet weak var sendFollowupButton: NIKFontAwesomeButton!
    
    var call: NSDictionary?
    
    var startTime : NSDate?
    var endTime : NSDate?
    var sessionNumber : NSNumber?
    
    var attachments : NSMutableArray = []
    
    let summaryDefaultText = "Key insights"
    let nextTimeDefaultText = "Where to start next call"
    
    var updatePostData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendFollowupButton.selected = true
        
        self.floatRatingView.emptyImage = UIImage(named: "star_off")
        self.floatRatingView.fullImage = UIImage(named: "star_on")
        // Optional params
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIViewContentMode.ScaleAspectFill
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 1
        self.floatRatingView.rating = 0
        self.floatRatingView.editable = true
        self.floatRatingView.halfRatings = false
        self.floatRatingView.floatRatings = false
        
        if call == nil {
            call = CallUtils.currentCall
        } else {
            updatePostData = true
            if let callId = call?["id"] as? NSNumber{
                ServerAPI.getPostCall(callId, completion: { (result) -> Void in
                    if result.count > 0 {
                        dispatch_async(dispatch_get_main_queue()){
                            if let rating = result["rating"] as? NSNumber{
                                self.floatRatingView.rating = Float(rating)
                            }
                            if let summary = result["details"] as? String{
                                if count(summary) > 0 {
                                    self.summaryTextView.text = summary
                                    self.summaryTextView.textColor = UIColor.blackColor()
                                }
                            }
                        }
                    }
                })
            }
        }
        
        if let callee = call?["callee"] as? NSDictionary{
            let firstName = (callee["user"] as? NSDictionary)?["first_name"] as! String
            let lastName = (callee["user"] as? NSDictionary)?["last_name"]as! String
            callerNameLabel.text =  callerNameLabel.text! + "\(firstName) \(lastName)"
            
        }

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShown:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        ViewUtils.addDoneToolBarToKeyboard(self.summaryTextView, vc: self)
        ViewUtils.addDoneToolBarToKeyboard(self.nextTimeTextView, vc: self)
        ViewUtils.addDoneToolBarToKeyboard(self.followupTextView, vc: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        ViewUtils.borderView(saveButton, borderWidth: 1.0, borderColor: UIColor.clearColor(), borderRadius: 5)
        ViewUtils.borderView(backButton, borderWidth: 1.0, borderColor: ColorUtils.buttonColor(), borderRadius: 5)
        let borderColor = ColorUtils.uicolorFromHex(0xF1F1F1)
        ViewUtils.bottomBorderView(summaryView, borderWidth: 1.0, borderColor: borderColor, offset: 0)
        ViewUtils.bottomBorderView(nextTimeView, borderWidth: 1.0, borderColor: borderColor, offset: -1.0)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == self.summaryDefaultText && textView == summaryTextView{
            textView.text = ""
        }
        if textView.text == self.nextTimeDefaultText && textView == nextTimeTextView{
            textView.text = ""
        }
        textView.textColor = UIColor.blackColor()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" && textView == summaryTextView{
            summaryTextView.text = self.summaryDefaultText
            textView.textColor = UIColor.lightGrayColor()
        }
        if textView.text == "" && textView == nextTimeTextView{
            nextTimeTextView.text = self.nextTimeDefaultText
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShown(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0 //-(keyboardSize.height )
        })
    }
    
    func keyboardWillHide(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0
        })
    }
    
    func doneButtonClickedDismissKeyboard() {
        self.summaryTextView.resignFirstResponder()
        self.nextTimeTextView.resignFirstResponder()
        self.followupTextView.resignFirstResponder()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "presentAttachmentList"){
            var svc = segue.destinationViewController as! AttachmentListViewController
            svc.postCallVC = self
            if let product = call?["product"] as? NSDictionary{
                if let id = product["id"] as? NSNumber{
                    svc.productId = id
                }
                
            }
            
        }
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        //self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating)
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        //self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating)
    }
    
    @IBAction func save(sender: UIButton) {
        if let callId = call?["id"] as? NSNumber{
            if updatePostData{
                let data = ["call":  callId,
                    "rating": self.floatRatingView.rating,
                    "details": self.summaryTextView.text] as Dictionary<String, AnyObject>
                ServerAPI.newPostCall(data, completion: { (result) -> Void in
                    //
                })
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                if let end = endTime {
                    if let start = startTime{
                        let callLength = (end.timeIntervalSince1970 - start.timeIntervalSince1970) * 1000 //to milisec
                        if let sNumber = sessionNumber{
                            let data = ["call":  callId,
                                "rating": self.floatRatingView.rating,
                                "details": self.summaryTextView.text,
                                "callLength": callLength,
                                "start": TimeUtils.dateToServerString(startTime!),
                                "sessionNumber" : Int(sNumber) + 1] as Dictionary<String, AnyObject>
                            ServerAPI.newPostCall(data, completion: { (result) -> Void in
                                //
                            })
                        }
                    }
                }
                CallUtils.getCallViewController()?.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                    //
                })
            }
            if sendFollowupButton.selected {
                let data = ["text":  self.followupTextView.text,
                    "attachments": attachments,
                    "call": callId] as Dictionary<String, AnyObject>
                ServerAPI.sendFollowupEmail(data, completion: { (result) -> Void in
                    //
                })
                
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attachments.count
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("attachmentCell") as! TableViewCellWithLabelAndButton
        cell.label.text = attachments[indexPath.row]["name"] as? String
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: "removeAtachment:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 34
    }
    
    func removeAtachment(sender: UIButton){
        attachments.removeObjectAtIndex(sender.tag)
        attacmentTable.reloadData()
    }
    
    func addAttachment(attchment: NSDictionary){
        attachments.addObject(attchment)
        attacmentTable.reloadData()
    }
    
    
    @IBAction func toggleFollowupEmail(sender: NIKFontAwesomeButton) {
        if sender.selected {
            sender.selected = false
            sender.iconHex = "f096"
            attachmentView.hidden = true
            followupTextView.hidden = true
        } else {
            sender.selected = true
            sender.iconHex = "f046"
            attachmentView.hidden = false
            followupTextView.hidden = false
        }
        
    }
    
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
