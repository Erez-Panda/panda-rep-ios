//
//  PostCallViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/29/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class PostCallViewController: UIViewController, FloatRatingViewDelegate, UITextViewDelegate {
    
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet weak var callSummary: UITextView!
    
    var callData: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        /** Note: With the exception of contentMode, all of these
            properties can be set directly in Interface builder **/
        
        // Required float rating view params
        self.floatRatingView.emptyImage = UIImage(named: "StarEmpty.png")
        self.floatRatingView.fullImage = UIImage(named: "StarFull.png")
        // Optional params
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 1
        self.floatRatingView.rating = 0
        self.floatRatingView.editable = true
        self.floatRatingView.halfRatings = false
        self.floatRatingView.floatRatings = false
        
        // Segmented control init
//        self.ratingSegmentedControl.selectedSegmentIndex = 1
//        
//        // Labels init
//        self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating)
//        self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ratingTypeChanged(sender: UISegmentedControl) {
        self.floatRatingView.halfRatings = sender.selectedSegmentIndex==1
        self.floatRatingView.floatRatings = sender.selectedSegmentIndex==2
    }

    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        //self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating)
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        //self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating)
    }
    
    @IBAction func send(sender: UIButton) {
        let callLength = (NSDate().timeIntervalSince1970 - (callData["start"] as NSDate).timeIntervalSince1970) * 1000 //to milisec
        let sessionNumber = (callData["sessionNumber"] as Int) + 1
        let data = ["call": callData["callId"] as NSNumber,
                    "rating": self.floatRatingView.rating,
                    "details": self.callSummary.text,
                    "callLength": callLength,
                    "start": TimeUtils.dateToServerString(callData["start"] as NSDate),
                    "sessionNumber" : sessionNumber ] as Dictionary<String, AnyObject>
        ServerAPI.newPostCall(data, completion: { (result) -> Void in
            //
        })
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
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
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  -= 150
        })
    }
    func keyboardWillBeHidden(sender: NSNotification){
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  += 150
        })
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
}
