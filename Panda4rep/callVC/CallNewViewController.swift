//
//  CallNewViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/6/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
import FontAwesomeIconFactory

let videoWidth : CGFloat = 264/1.5
let videoHeight : CGFloat = 198/1.5



// Change to YES to subscribe to your own stream.
let SubscribeToSelf = false

class CallNewViewController: UIViewController, UIGestureRecognizerDelegate, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, UIScrollViewDelegate{

    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var presentationWebView: UIWebView?
    @IBOutlet weak var chatBadge: UILabel!
    @IBOutlet weak var toggleVideoButton: UIButton!
    @IBOutlet weak var toggleSoundButton: UIButton!
    @IBOutlet weak var presentaionImage: UIImageView?
    @IBOutlet weak var buttomView: UIView!
    @IBOutlet weak var toggleControllPanelButton: NIKFontAwesomeButton!
    @IBOutlet weak var scrollView: TouchUIScrollView!
    
    @IBOutlet weak var bottomViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var sideViewLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var toggleToolsButton: NIKFontAwesomeButton!
    @IBOutlet weak var pointer: NIKFontAwesomeButton!
    
    @IBOutlet weak var toolsPanelConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlPanelConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var isDragging = false
    var isPointing = false
    var chatViewController: ChatViewController?
    var controlPanelTimer: NSTimer?
    var publisherSizeConst: [NSLayoutConstraint]?
    var controlPanelHidden = true
    var toolsPanelHidden = true
    var messageQ : NSArray = []
    var currentImage: UIImage?
    var showIncoming = true
    
    var resources: NSArray?
    var videoResources: NSArray?
    var selectedResIndex = 0
    var displayResources: NSArray?
    var currentImageIndex = 0
    var currentImageUrl: String?
    
    var callStartTime: NSDate?
    var sessionNumber: NSNumber?
    
    var firstTime = true
    var drawingMode = false
    var preLoadedImages: Array<Array<UIImage?>?>?
    var preLoadedImagesUrl: Array<Array<String?>?>?
    var isChangingPresentation = false
    var showNextSlide = false
    var remoteSignatureView : PassiveLinearInterpView?
    

    @IBOutlet weak var drawingView: LinearInterpView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if firstTime {
            UIEventRegister.gestureRecognizer(self, rightAction:"prev:", leftAction: "next:", upAction: "up:", downAction: "down:")
            let longTapReco = UILongPressGestureRecognizer(target: self, action: "longTap:")
            longTapReco.cancelsTouchesInView = false
            self.view.addGestureRecognizer(longTapReco)
            scrollView.parent = self
            var resultPredicate = NSPredicate(format: "type == %d", 2)
            videoResources = resources?.filteredArrayUsingPredicate(resultPredicate)
            resultPredicate = NSPredicate(format: "type == %d", 1)
            resources = resources?.filteredArrayUsingPredicate(resultPredicate)
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        if firstTime{
            buttomView.layoutIfNeeded()
            ViewUtils.cornerRadius(toggleControllPanelButton, corners: [.TopLeft, .TopRight], cornerRadius: 20.0)
            ViewUtils.cornerRadius(toggleToolsButton, corners: [.TopLeft, .TopRight], cornerRadius: 10.0)
            //ViewUtils.addGradientLayer(buttomView, topColor: UIColor(red:0.1/255, green:0.1/255, blue:0.1/255, alpha:0.0), bottomColor: UIColor(red:0.1/255, green:0.1/255, blue:0.1/255, alpha:0.9))
            ViewUtils.roundView(chatBadge, borderWidth: 1.0, borderColor: UIColor.whiteColor())
            if ((currentImage) != nil){
                presentaionImage?.image = currentImage
            }
            
            sideView.translatesAutoresizingMaskIntoConstraints = false
            buttomView.translatesAutoresizingMaskIntoConstraints = false
            
            //controlPanelTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("hideControls"), userInfo: AnyObject?(), repeats: false)
        } else {
            
        }
        
    }

    
    override func viewDidAppear(animated: Bool) {
        if firstTime{
            CallUtils.doPublish()
            toggleVideo(UIButton())
            changeDisplayResource(0)
            firstTime = false
        }
    }
    
    func loadImage(imageFile: NSNumber){
        ServerAPI.getFileUrl(imageFile, completion: { (result) -> Void in
            self.currentImageUrl = result as String
            let url = NSURL(string: result as String)
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue()){
                    self.presentaionImage?.image = UIImage(data: data)
                    self.isChangingPresentation = false
                    self.activity.stopAnimating()
                }
            }
            var maybeError : OTError?
            CallUtils.session?.signalWithType("load_res", string: result as String, connection: nil, error: &maybeError)
        })
    }
    
    func changeDisplayResource(index: Int) {
        if preLoadedImages?[index] == nil{
            if !isChangingPresentation{
                if self.resources?.count > 0{
                    if let resource = self.resources?[index] as? NSDictionary{
                        if (resource["type"] as! NSNumber == 1){
                            if let resourceId = resource["id"] as? NSNumber {
                                isChangingPresentation = true
                                activity.startAnimating()
                                remoteSignatureView?.removeFromSuperview()
                                ServerAPI.getResourceDisplay(resourceId, completion: { (result) -> Void in
                                    if result.count > 0 {
                                        self.displayResources = result
                                    } else {
                                        self.displayResources = nil
                                    }
                                    if let dispRes = self.displayResources?[0] as? NSDictionary{
                                        self.loadImage(dispRes["id"] as! NSNumber)
                                    }
                                    self.preLoadDisplayResources()
                                })
                            }
                        }
                    }
                }
            }
        } else {
            self.next(UISwipeGestureRecognizer())
        }
    }
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func preLoadImage(imageFile: NSNumber, index: Int){
        ServerAPI.getFileUrl(imageFile, completion: { (result) -> Void in
            let scopeIndex = index
            let scopeSelectedResIndex = self.selectedResIndex
            self.currentImageUrl = result as String
            let url = NSURL(string: result as String)
            
            var maybeError : OTError?
            CallUtils.session?.signalWithType("preload_res", string: result as String, connection: nil, error: &maybeError)
            if url != nil {
                self.getDataFromUrl(url!) { data in
                    self.preLoadedImages?[scopeSelectedResIndex]?[scopeIndex] = UIImage(data: data!)
                    self.preLoadedImagesUrl?[scopeSelectedResIndex]?[scopeIndex] = result as String
                    dispatch_async(dispatch_get_main_queue()){
                        if self.showNextSlide {
                            self.activity.stopAnimating()
                            self.showNextSlide = false
                            self.next(UISwipeGestureRecognizer())
                        }
                        
                    }
                }
            }
        })
    }
    
    func preLoadDisplayResources(){
        if let resources = displayResources {
            if let allResources = self.resources {
                if preLoadedImages == nil {
                    preLoadedImages = [Array<UIImage?>?](count:allResources.count, repeatedValue: nil)
                }
                if preLoadedImagesUrl == nil {
                    preLoadedImagesUrl = [Array<String?>?](count:allResources.count, repeatedValue: nil)
                }
                if preLoadedImages?[selectedResIndex] == nil {
                    preLoadedImages?[selectedResIndex] = [UIImage?](count:resources.count, repeatedValue: nil)
                    preLoadedImagesUrl?[selectedResIndex] = [String?](count:resources.count, repeatedValue: nil)
                    for index in 0..<resources.count {
                        if let dispRes = resources[index] as? NSDictionary{
                            self.preLoadImage(dispRes["id"] as! NSNumber, index: index)
                        }
                    }
                }
            }
        }
    }
    
    func next(sender: UISwipeGestureRecognizer) {
        if self.isDragging || self.drawingMode {return}
        if (currentImageIndex+1 == preLoadedImages?[selectedResIndex]?.count){
            return
        }
        if let image = preLoadedImages?[selectedResIndex]?[currentImageIndex+1]{
            remoteSignatureView?.removeFromSuperview()
            currentImageIndex++
            self.presentaionImage?.image = image
            
            if let urlStr = preLoadedImagesUrl?[selectedResIndex]?[currentImageIndex]{
                var maybeError : OTError?
                CallUtils.session?.signalWithType("load_res", string: urlStr, connection: nil, error: &maybeError)
            }
        } else {
            showNextSlide = true
            activity.startAnimating()
        }
        /*else if let dispRes = displayResources?[currentImageIndex] as? NSDictionary{
            if let imgFile = dispRes["id"] as? NSNumber{
                loadImage(imgFile)
                
            }
        }*/
    }
    func prev(sender: UISwipeGestureRecognizer) {
        if self.isDragging || self.drawingMode {return}
        if currentImageIndex <= 0{
            return
        }
        
        if let image = preLoadedImages?[selectedResIndex]?[currentImageIndex-1]{
            remoteSignatureView?.removeFromSuperview()
            currentImageIndex--
            self.presentaionImage?.image = image
            
            if let urlStr = preLoadedImagesUrl?[selectedResIndex]?[currentImageIndex]{
                var maybeError : OTError?
                CallUtils.session?.signalWithType("load_res", string: urlStr, connection: nil, error: &maybeError)
            }
        } /*else if let dispRes = displayResources?[currentImageIndex] as? NSDictionary{
            if let imgFile = dispRes["id"] as? NSNumber{
                loadImage(imgFile)
            }
        }*/
    }
    
    func up(sender: UISwipeGestureRecognizer) {
        let old = selectedResIndex
        if self.isDragging || self.drawingMode {return}
        if (selectedResIndex+1 >= self.resources?.count){
            selectedResIndex = -1
        }
        selectedResIndex++
        if old != selectedResIndex{
            currentImageIndex = -1
            changeDisplayResource(selectedResIndex)
        }
    }
    func down(sender: UISwipeGestureRecognizer) {
        let old = selectedResIndex
        if self.isDragging || self.drawingMode {return}
        if selectedResIndex <= 0{
            selectedResIndex = self.resources!.count
        }
        selectedResIndex--
        if old != selectedResIndex{
            currentImageIndex = -1
            changeDisplayResource(selectedResIndex)
        }
    }
    
    func longTap(sender: UILongPressGestureRecognizer){
        isPointing = true
        pointer.hidden = false
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return presentaionImage
    }
    
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        var maybeError : OTError?
        var paramStr = ""
        paramStr += "\(scale)_"
        paramStr += "\(scrollView.contentOffset.x/scrollView.contentSize.width),"
        paramStr += "\(scrollView.contentOffset.y/scrollView.contentSize.height)"
        CallUtils.session?.signalWithType("zoom_scale", string:paramStr, connection: nil, error: &maybeError)
    }
    

    @IBAction func toggleSound(sender: AnyObject) {
        if let pAudio = CallUtils.publisher?.publishAudio{
            CallUtils.publisher?.publishAudio = !pAudio
            if (!pAudio){
                toggleSoundButton.setImage(UIImage(named: "audio_on_icon"), forState: UIControlState.Normal)
            } else {
                toggleSoundButton.setImage(UIImage(named: "audio_off_icon"), forState: UIControlState.Normal)
            }
        }
    }
    
    func shrinkPublisher(){
        if let view = CallUtils.publisher?.view {
            //view.removeConstraints(publisherSizeConst!)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                view.frame.origin = CGPointMake(2*videoWidth/3, 2*videoHeight/3)
                view.frame.size = CGSizeMake(videoWidth/3, videoHeight/3)
                
            })
        }
    }


    @IBAction func toggleVideo(sender: AnyObject) {
        if let pVideo = CallUtils.publisher?.publishVideo{
            CallUtils.publisher?.publishVideo = !pVideo
            if (!pVideo){
                toggleVideoButton.setImage(UIImage(named: "video_on_icon"), forState: UIControlState.Normal)
                if let view = CallUtils.publisher?.view {
                    if let subView = CallUtils.subscriber?.view{
                        subView.addSubview(view)
                        ViewUtils.addConstraintsToSuper(view, superView: subView, top:nil, left: nil, bottom: 0.0, right: 0.0)
                        publisherSizeConst = ViewUtils.addSizeConstaints(view, width: videoWidth, height: videoHeight)
                        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("shrinkPublisher"), userInfo: AnyObject?(), repeats: false)
                    } else {
                        self.view.addSubview(view)
                        
                        ViewUtils.addConstraintsToSuper(view, superView: self.view, top:0.0, left: nil, bottom: nil, right: 0.0)
                        ViewUtils.addSizeConstaints(view, width: videoWidth, height: videoHeight)
                    }
                }
            } else {
                toggleVideoButton.setImage(UIImage(named: "video_off_icon"), forState: UIControlState.Normal)
                if let view = CallUtils.publisher?.view {
                    view.removeFromSuperview()
                }
            }

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func endCall(sender: AnyObject) {
        //self.performSegueWithIdentifier("showPostCall", sender: AnyObject?())
        dismissViewControllerAnimated(false, completion: nil)
        CallUtils.rootViewController?.selectedCall = nil
        CallUtils.rootViewController?.performSegueWithIdentifier("showPostCallScreen", sender: self)
        CallUtils.stopArchive()
        CallUtils.stopCall()
    }
    
    func showControlPanel(){
        controlPanelHidden = false
        updateControlPanelConstraint(0)
    }
    
    func hideControls(){
        controlPanelHidden = true
        toolsPanelHidden = true
        updateControlPanelConstraint(-80)
        updateToolsPanelConstraint(60)
    }
    
    @IBAction func toggleControlPanel(sender: NIKFontAwesomeButton) {
        controlPanelHidden = !controlPanelHidden
        updateControlPanelConstraint((controlPanelHidden ? -80 : 0))
    }
    
    func updateControlPanelConstraint(value: CGFloat){
        UIView.animateWithDuration(0.325, animations: {
            self.controlPanelConstraint.constant = value
            self.view.layoutIfNeeded()
        })
    }
    
    func updateToolsPanelConstraint(value: CGFloat){
        UIView.animateWithDuration(0.325, animations: {
            self.toolsPanelConstraint.constant = value
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func toggleToolsPanel(sender: NIKFontAwesomeButton) {
        toolsPanelHidden = !toolsPanelHidden
        updateToolsPanelConstraint(self.toolsPanelHidden ? 60 : 0)

    }
    
    @IBAction func openDropbox(sender: NIKFontAwesomeButton) {

    }
    
    @IBAction func stopSharing(sender: NIKFontAwesomeButton) {
        stopSharing()
    }
    
    func stopSharing(){
        CallUtils.doScreenUnpublish()
        self.presentationWebView?.hidden = true
        var maybeError : OTError?
        CallUtils.session?.signalWithType("unload_video", string: "", connection: nil, error: &maybeError)
        self.presentationWebView?.loadHTMLString("", baseURL:nil)
    }
    
    @IBAction func toggleDrawingMode(sender: NIKFontAwesomeButton) {
        if self.drawingMode {
            drawingMode = false
            drawingView.enabled = false
            drawingView.userInteractionEnabled = false
            sender.color = UIColor.whiteColor()
            //self.view.sendSubviewToBack(drawingView)
            if (self.view.subviews[3] as NSObject == drawingView){
                self.view.exchangeSubviewAtIndex(2, withSubviewAtIndex: 3)
            }
            
        } else {
            drawingMode = true
            drawingView.enabled = true
            drawingView.userInteractionEnabled = true
            sender.color = UIColor.blueColor()
            if (self.view.subviews[2] as NSObject == drawingView){
                self.view.exchangeSubviewAtIndex(2, withSubviewAtIndex: 3)
            }
            //self.view.bringSubviewToFront(drawingView)
        }
    }
    /*
    @IBAction func togglePointer(sender: NIKFontAwesomeButton) {
        isPointing = !isPointing
        if isPointing {
            scrollView.userInteractionEnabled = false
            sender.color = UIColor.blueColor()
        }
        else {
            pointer.hidden = true
            scrollView.userInteractionEnabled = true
            sender.color = UIColor.whiteColor()
            var maybeError : OTError?
            CallUtils.session?.signalWithType("pointer_hide", string: "", connection: nil, error: &maybeError)
        }
    }
    */
    
    func showDropboxItem(url: NSURL!){
        if let data = NSData(contentsOfURL: url){
            self.presentationWebView!.loadData(data, MIMEType: "application/pdf", textEncodingName: "ISO-8859-1", baseURL: url)
            self.presentationWebView!.hidden = false
            CallUtils.doScreenPublish(presentationWebView!)
        }
    }
    
    func showVideoItem(url: String){
        stopSharing()
        var embedHTML = "<html><head>"
        embedHTML += "<style type=\"text/css\">"
        embedHTML += "body {"
        embedHTML += "background-color: transparent;color: white;}</style></head><body style=\"margin:0; position:absolute; top:50%; left:50%; -webkit-transform: translate(-50%, -50%);\"><embed webkit-playsinline id=\"yt\" src=\"\(url)\" type=\"application/x-shockwave-flash\"width=\"\(320)\" height=\"\(300)\"></embed></body></html>"
        
        self.presentationWebView!.loadHTMLString(embedHTML, baseURL:nil)
        self.presentationWebView!.hidden = false
        var maybeError : OTError?
        CallUtils.session?.signalWithType("load_video", string: url + "?autoplay=1&fs=1", connection: nil, error: &maybeError)
    }
    
    @IBAction func cleanDrawing(sender: AnyObject) {
        drawingView.cleanView()
        var maybeError : OTError?
        CallUtils.session?.signalWithType("line_clear", string: "", connection: nil, error: &maybeError)
    }


    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if let touch: UITouch = touches.first{
            //((touch.gestureRecognizers as NSArray)[0] as! UIGestureRecognizer).cancelsTouchesInView = false
            let touchLocation = touch.locationInView(self.view) as CGPoint
            
            if drawingMode {
                var maybeError : OTError?
                let screenBounds = UIScreen.mainScreen().bounds
                CallUtils.session?.signalWithType("line_start_point", string: "\(touchLocation.x/screenBounds.width),\(touchLocation.y/screenBounds.height)", connection: nil, error: &maybeError)
            }
            if isPointing {
                let point = CGPointMake(touchLocation.x-(pointer.frame.width/2), touchLocation.y-55)
                pointer.frame.origin = point
                var maybeError : OTError?
                let screenBounds = UIScreen.mainScreen().bounds
                CallUtils.session?.signalWithType("pointer_position", string: "\(point.x/screenBounds.width),\(point.y/screenBounds.height)", connection: nil, error: &maybeError)
            }
            
            if let subscriberRect = CallUtils.subscriber?.view.frame {
                if (CGRectContainsPoint(subscriberRect, touchLocation)){
                    self.isDragging = true
                }
            }
            if (CallUtils.isFakeCall){
                if let subscriberRect = CallUtils.publisher?.view.frame {
                    if (CGRectContainsPoint(subscriberRect, touchLocation)){
                        self.isDragging = true
                    }
                }
            } else if CallUtils.subscriber != nil{
                if let view = CallUtils.publisher?.view {
                    let touchLocationinsideVideo = touch.locationInView(CallUtils.subscriber?.view) as CGPoint
                    if (CGRectContainsPoint(view.frame, touchLocationinsideVideo)){
                        
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            if (view.frame.origin.x > 10){
                                view.frame.origin = CGPointMake(0.0, 0.0)
                                view.frame.size = CGSizeMake(videoWidth, videoHeight)
                            } else {
                                view.frame.origin = CGPointMake(2*videoWidth/3, 2*videoHeight/3)
                                view.frame.size = CGSizeMake(videoWidth/3, videoHeight/3)
                            }
                        })
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        self.isDragging = false
        if isPointing {
            isPointing = false
            pointer.hidden = true
            var maybeError : OTError?
            CallUtils.session?.signalWithType("pointer_hide", string: "", connection: nil, error: &maybeError)
        }
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        print("CANCEL")
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        if let touch: UITouch = touches.first{
            let touchLocation = touch.locationInView(self.view) as CGPoint
            if drawingMode {
                var maybeError : OTError?
                let screenBounds = UIScreen.mainScreen().bounds
                CallUtils.session?.signalWithType("line_point", string: "\(touchLocation.x/screenBounds.width),\(touchLocation.y/screenBounds.height)", connection: nil, error: &maybeError)
            }
            if isPointing {
                let point = CGPointMake(touchLocation.x-(pointer.frame.width/2), touchLocation.y-55)
                pointer.frame.origin = point
                var maybeError : OTError?
                let screenBounds = UIScreen.mainScreen().bounds
                CallUtils.session?.signalWithType("pointer_position", string: "\(point.x/screenBounds.width),\(point.y/screenBounds.height)", connection: nil, error: &maybeError)
            }
            if (self.isDragging){
                if let subscriber = CallUtils.subscriber?.view {
                    UIView.animateWithDuration(0.0,
                        delay: 0.0,
                        options: ([UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut]),
                        animations:  {subscriber.center = touchLocation},
                        completion: nil)
                }
                if (CallUtils.isFakeCall){
                    if let subscriber = CallUtils.publisher?.view {
                        UIView.animateWithDuration(0.0,
                            delay: 0.0,
                            options: ([UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut]),
                            animations:  {subscriber.center = touchLocation},
                            completion: nil)
                    }
                }
            }
        }
    }
    

    func addMessageToQ(message: String){
        messageQ = messageQ.arrayByAddingObject(message)
        chatBadge?.text = String(messageQ.count)
        chatBadge?.hidden = false
        showControlPanel()
    }
    func releaseMessageQ(){
        if (messageQ.count > 0){
            for message in messageQ {
                chatViewController!.addChatBox(message as! String, isSelf: false)
            }
            messageQ = []
            chatBadge.hidden = true
        }
    }
    
    @IBAction func openChat(sender: AnyObject) {
        

        hideControls()
        if let chat = self.chatViewController{
            chat.view.frame.origin.y = self.view.frame.size.height
            chat.view.hidden = false
            releaseMessageQ()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                chat.view.frame.origin.y = 0.0
            })
            
        } else {
            self.chatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as? ChatViewController
            self.chatViewController?.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)
            self.addChildViewController(chatViewController!)
            self.view.addSubview(chatViewController!.view)
            self.view.bringSubviewToFront(chatViewController!.view)
            chatViewController!.didMoveToParentViewController(self)
            releaseMessageQ()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.chatViewController!.view.frame.origin.y = 0.0
            })

            
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPostCall"){
            let svc = segue.destinationViewController as! PostCallNewViewController
            svc.startTime = self.callStartTime
            svc.endTime = NSDate()
            svc.sessionNumber = self.sessionNumber
        } else if (segue.identifier == "presentDropboxList"){
            let svc = segue.destinationViewController as! DropboxListViewController
            svc.parentVC = self
        } else if (segue.identifier == "presentVideoResources"){
            let svc = segue.destinationViewController as! VideoResourceViewController
            svc.parentVC = self
            svc.videoDocuments = videoResources
        }
        
        
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    override func viewWillAppear(animated: Bool) {
        // Step 2: As the view comes into the foreground, begin the connection process.
        //CallUtils.doConnect()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    // MARK: - OTSession delegate callbacks
    
    func sessionDidConnect(session: OTSession) {
        NSLog("sessionDidConnect (\(session.sessionId))")
        
        // Step 2: We have successfully connected, now instantiate a publisher and
        // begin pushing A/V streams into OpenTok.
        //CallUtils.doPublish()
        
    }
    
    func sessionDidDisconnect(session : OTSession) {
        NSLog("Session disconnected (\( session.sessionId))")
    }
    
    func session(session: OTSession, streamCreated stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
        // have seen on the OpenTok session.
        if CallUtils.subscriber?.stream.streamId != stream.streamId {
            callStartTime = NSDate()
            CallUtils.stream = stream
            CallUtils.doSubscribe(stream)
            CallUtils.startArchive()
        }
    }
    
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        if (stream.videoType == OTStreamVideoType.Screen){
            CallUtils.doScreenUnsubscribe()
        } else {
            self.navigationController?.navigationBarHidden = false
            if CallUtils.subscriber?.stream.streamId == stream.streamId {
                CallUtils.doUnsubscribe()
            }
        }
    }
    
    func session(session: OTSession, connectionCreated connection : OTConnection) {
        NSLog("session connectionCreated (\(connection.connectionId))")
        if connection.connectionId != CallUtils.session?.connection.connectionId {
            CallUtils.remoteSideConnected()
        }
    }
    
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        NSLog("session connectionDestroyed (\(connection.connectionId))")
        if connection.connectionId != CallUtils.session?.connection.connectionId {
            CallUtils.remoteSideDisconnected()
        }
    }
    
    func session(session: OTSession, didFailWithError error: OTError) {
        NSLog("session didFailWithError (%@)", error)
    }
    
    func session(session: OTSession!, receivedSignalType type: String!, fromConnection connection: OTConnection!, withString string: String!) {
        if connection?.connectionId != CallUtils.session?.connection?.connectionId {
            if(type == "chat_text"){
                if let chat = self.chatViewController {
                    if (chat.view.frame.origin.y > 10){
                        addMessageToQ(string)
                    } else {
                        chat.addChatBox(string, isSelf: false)
                    }
                } else {
                    addMessageToQ(string)
                }
            } else if (type == "send_current_res"){
                var maybeError : OTError?
                CallUtils.session?.signalWithType("load_res", string: self.currentImageUrl, connection: nil, error: &maybeError)
                
                if preLoadedImagesUrl?[selectedResIndex] != nil {
                    for url in self.preLoadedImagesUrl![selectedResIndex]! {
                        CallUtils.session?.signalWithType("preload_res", string: url, connection: nil, error: &maybeError)
                    }
                }
            } else if type == "decline_call" {
                CallUtils.remoteSideDeclined()
                
            } else if type == "signature_points"{
                let data = getKeyVals(string)
                let screen =  UIScreen.mainScreen().bounds
                let document = presentaionImage!.image!
                let zoom = CGFloat((data!["zoom"] as NSString?)!.floatValue)

                let screenWidth = CGFloat((data!["screenWidth"] as NSString?)!.floatValue)
                let screenHeight = CGFloat((data!["screenHeight"] as NSString?)!.floatValue)
                let width = CGFloat((data!["width"] as NSString?)!.floatValue) / zoom
                let height = CGFloat((data!["height"] as NSString?)!.floatValue) / zoom

                //One of these have to be 0
                let documentScaleRatio = max(document.size.width/screen.width, document.size.height/screen.height)
                let heightDiff = ((screen.height*documentScaleRatio) - document.size.height)/documentScaleRatio
                let widthDiff = ((screen.width*documentScaleRatio) - document.size.width)/documentScaleRatio
                //Image is aspect fit, scale factor will be the biggest change on image
                let scaleRatio = max((screen.width-widthDiff)/screenWidth, (screen.height-heightDiff)/screenHeight)
                let x = CGFloat((data!["originX"] as NSString?)!.floatValue) * (screen.width-widthDiff)
                let y = CGFloat((data!["originY"] as NSString?)!.floatValue) * (screen.height-heightDiff)
                remoteSignatureView = PassiveLinearInterpView(frame: CGRectMake(x+widthDiff/2,y+heightDiff/2,width*scaleRatio,height*scaleRatio))
                //remoteSignatureView!.path?.lineWidth *= scaleRatio/zoom
                let linesStr = data!["points"]!.componentsSeparatedByString("***")
                for line in linesStr {
                    var pointsStr = line.componentsSeparatedByString("-")
                    for i in 0..<pointsStr.count {
                        if let p = getPointFromPointStr(pointsStr[i], scaleRatio: scaleRatio,zoom: zoom){
                            if i == 0{
                                remoteSignatureView!.moveToPoint(p)
                            } else {
                                remoteSignatureView!.addPoint(p)
                            }
                        }
                    }
                }
                
                presentaionImage?.addSubview(remoteSignatureView!)
            }
            
        }
    }
        
    func getPointFromPointStr(pointStr: String, scaleRatio: CGFloat, zoom: CGFloat)-> CGPoint?{
        if pointStr.containsString(","){
            var coordsStr = pointStr.characters.split{$0 == ","}.map { String($0) }
            let x = (coordsStr[0] as NSString).floatValue
            let y = (coordsStr[1] as NSString).floatValue
            return CGPoint(x: CGFloat(x)/zoom  * scaleRatio,y: CGFloat(y)/zoom * scaleRatio)
        } else {
            return nil
        }
    }
    
    func getKeyVals(string: String) -> Dictionary<String, String>? {
        var results = [String:String]()
        let keyValues = string.componentsSeparatedByString("&")
        if keyValues.count > 0 {
            for pair in keyValues {
                let kv = pair.componentsSeparatedByString("=")
                if kv.count > 1 {
                    results.updateValue(kv[1], forKey: kv[0])
                }
            }
            
        }
        return results
    }
    
    // MARK: - OTSubscriber delegate callbacks
    
    func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        NSLog("subscriberDidConnectToStream (\(subscriberKit))")
        self.navigationController?.navigationBarHidden = true
        if let view = CallUtils.subscriber?.view {
            self.view.addSubview(view)
            ViewUtils.addConstraintsToSuper(view, superView: self.view, top:0.0, left: nil, bottom: nil, right: 0.0)
            ViewUtils.addSizeConstaints(view, width: videoWidth, height: videoHeight)
            if let pubView = CallUtils.publisher?.view {
                pubView.removeFromSuperview()
                view.addSubview(pubView)
                ViewUtils.addConstraintsToSuper(pubView, superView: view, top:nil, left: nil, bottom: 0.0, right: 0.0)
                publisherSizeConst = ViewUtils.addSizeConstaints(pubView, width: videoWidth, height: videoHeight)
                NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("shrinkPublisher"), userInfo: AnyObject?(), repeats: false)
            }
        }
    }
    
    func subscriber(subscriber: OTSubscriberKit, didFailWithError error : OTError) {
        NSLog("subscriber %@ didFailWithError %@", subscriber.stream.streamId, error)
    }
    
    // MARK: - OTPublisher delegate callbacks
    
    func publisher(publisher: OTPublisherKit, streamCreated stream: OTStream) {
        NSLog("publisher streamCreated %@", stream)
        
        // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
        // all participants in the OpenTok session. We will attempt to subscribe to
        // our own stream. Expect to see a slight delay in the subscriber video and
        // an echo of the audio coming from the device microphone.
        if CallUtils.subscriber == nil && SubscribeToSelf {
            CallUtils.doSubscribe(stream)
        }
    }
    
    func publisher(publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        NSLog("publisher streamDestroyed %@", stream)
        
        if CallUtils.subscriber?.stream.streamId == stream.streamId {
            CallUtils.doUnsubscribe()
        }
    }
    
    func publisher(publisher: OTPublisherKit, didFailWithError error: OTError) {
        NSLog("publisher didFailWithError %@", error)
    }

}