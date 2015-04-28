//
//  PostCallNewViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/6/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class PostCallNewViewController: UIViewController, FloatRatingViewDelegate {

    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var callerImage: UIImageView!
    @IBOutlet weak var callerNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if let caller = CallUtils.currentCall?["caller"] as? NSDictionary{
            let firstName = (caller["user"] as? NSDictionary)?["first_name"] as! String
            let lastName = (caller["user"] as? NSDictionary)?["last_name"]as! String
            callerNameLabel.attributedText = ViewUtils.getAttrText("\(firstName) \(lastName)", color: UIColor.whiteColor(), size: 22.0)
            if let imageFileId = caller["image_file"] as? NSNumber{
                ViewUtils.getImageFile(imageFileId, completion: { (result) -> Void in
                    //self.callerImage.image = result
                })
            }
            
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        callerImage.layoutIfNeeded()
        ViewUtils.roundView(callerImage, borderWidth: 3.0, borderColor: ColorUtils.uicolorFromHex(0x7E7C89))
        self.view.addSubview(ViewUtils.addRoundBorderView(callerImage, borderWidth: 2.0, borderColor: ColorUtils.uicolorFromHex(0x575665), boderSpacing: 8.0))
        self.view.addSubview(ViewUtils.addRoundBorderView(callerImage, borderWidth: 1.0, borderColor: ColorUtils.uicolorFromHex(0x474658), boderSpacing: 20.0))
        ViewUtils.borderView(rateButton, borderWidth: 1.0, borderColor: ColorUtils.uicolorFromHex(0x7E7C89), borderRadius: 3.0)
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        //self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating)
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        //self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating)
    }
    
    @IBAction func rate(sender: UIButton) {
        if let callId = CallUtils.currentCall?["id"] as? NSNumber{
            let data = ["call":  callId,
                "doctorRating": self.floatRatingView.rating] as Dictionary<String, AnyObject>
            ServerAPI.newPostCall(data, completion: { (result) -> Void in
                //
            })
        }
        
        if (self.floatRatingView.rating >= 3){
            self.performSegueWithIdentifier("showThankYouHigh", sender: AnyObject?())
        } else {
            self.performSegueWithIdentifier("showThankYouLow", sender: AnyObject?())
        }

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
