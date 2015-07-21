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
    
    
    @IBOutlet weak var bottomViewBottomConst: NSLayoutConstraint!
    @IBOutlet weak var sideViewLeadingConst: NSLayoutConstraint!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var toggleToolsButton: NIKFontAwesomeButton!
    
    var isDragging = false
    var chatViewController: ChatViewController?
    var controlPanelTimer: NSTimer?
    var publisherSizeConst: [NSLayoutConstraint]?
    var controlPanelHidden = false
    var toolsPanelHidden = false
    var messageQ : NSArray = []
    var currentImage: UIImage?
    var showIncoming = true
    
    var resources: NSArray?
    var selectedResIndex = 0
    var displayResources: NSArray?
    var currentImageIndex = 0
    var currentImageUrl: String?
    
    var callStartTime: NSDate?
    var sessionNumber: NSNumber?
    
    var firstTime = true
    var drawingMode = false
    

    @IBOutlet weak var drawingView: LinearInterpView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if firstTime {
            UIEventRegister.gestureRecognizer(self, rightAction:"prev:", leftAction: "next:", upAction: "up:", downAction: "down:")
        }
        
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        if firstTime{
            buttomView.layoutIfNeeded()
            ViewUtils.cornerRadius(toggleControllPanelButton, corners: (UIRectCorner.TopLeft|UIRectCorner.TopRight), cornerRadius: 20.0)
            ViewUtils.cornerRadius(toggleToolsButton, corners: (UIRectCorner.BottomRight|UIRectCorner.TopRight), cornerRadius: 10.0)
            //ViewUtils.addGradientLayer(buttomView, topColor: UIColor(red:0.1/255, green:0.1/255, blue:0.1/255, alpha:0.0), bottomColor: UIColor(red:0.1/255, green:0.1/255, blue:0.1/255, alpha:0.9))
            ViewUtils.roundView(chatBadge, borderWidth: 1.0, borderColor: UIColor.whiteColor())
            if ((currentImage) != nil){
                presentaionImage?.image = currentImage
            }
            
            sideView.setTranslatesAutoresizingMaskIntoConstraints(false)
            buttomView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
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
                }
            }
            var maybeError : OTError?
            CallUtils.session?.signalWithType("load_res", string: result as String, connection: nil, error: &maybeError)
        })
    }
    
    func changeDisplayResource(index: Int) {
        if self.resources?.count > 0{
            if let resource = self.resources?[index] as? NSDictionary{
                if (resource["type"] as! NSNumber == 1){
                    if let resourceId = resource["id"] as? NSNumber {
                        ServerAPI.getResourceDisplay(resourceId, completion: { (result) -> Void in
                            self.displayResources = result
                            if let dispRes = self.displayResources?[0] as? NSDictionary{
                                self.loadImage(dispRes["id"] as! NSNumber)
                            }
                            
                        })
                    }
                }
            }
        }
    }
    
    func next(sender: UISwipeGestureRecognizer) {
        if self.isDragging || self.drawingMode {return}
        if (currentImageIndex+1 == self.displayResources?.count){
            return
        }
        currentImageIndex++
        if let dispRes = displayResources?[currentImageIndex] as? NSDictionary{
            if let imgFile = dispRes["id"] as? NSNumber{
                loadImage(imgFile)
                
            }
        }
    }
    func prev(sender: UISwipeGestureRecognizer) {
        if self.isDragging || self.drawingMode {return}
        if currentImageIndex <= 0{
            return
        }
        currentImageIndex--
        if let dispRes = displayResources?[currentImageIndex] as? NSDictionary{
            if let imgFile = dispRes["id"] as? NSNumber{
                loadImage(imgFile)
            }
        }
    }
    
    func up(sender: UISwipeGestureRecognizer) {
        if self.isDragging || self.drawingMode {return}
        if (selectedResIndex+1 >= self.resources?.count){
            selectedResIndex = -1
        }
        selectedResIndex++
        changeDisplayResource(selectedResIndex)
    }
    func down(sender: UISwipeGestureRecognizer) {
        if self.isDragging || self.drawingMode {return}
        if selectedResIndex <= 0{
            selectedResIndex = self.resources!.count
        }
        selectedResIndex--
        changeDisplayResource(selectedResIndex)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return presentaionImage
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
    
    func hideControls(animate: Bool){
        ViewUtils.slideViewOutVertical(buttomView, animate: animate)
        ViewUtils.slideViewOutVertical(toggleControllPanelButton, animate: animate, offset: toggleControllPanelButton.frame.height)
        controlPanelHidden = true
    }
    
    func hideControls(){
        
        //self.view.removeConstraint(sideViewLeadingConst)
        //self.view.removeConstraint(bottomViewBottomConst)
        if let controls = buttomView {
            //toggleControllPanelButton.iconHex = "f102"
            ViewUtils.slideViewOutVertical(controls)
            ViewUtils.slideViewOutVertical(toggleControllPanelButton, offset: toggleControllPanelButton.frame.height)
            
        }
        controlPanelHidden = true
    }
    
    @IBAction func endCall(sender: AnyObject) {
        self.performSegueWithIdentifier("showPostCall", sender: AnyObject?())
        CallUtils.stopArchive()
        CallUtils.stopCall()
    }
    func showControlPanel(){
        controlPanelHidden = false
        if let controls = buttomView {
            ViewUtils.slideViewinVertical(controls)
            ViewUtils.slideViewinVertical(toggleControllPanelButton, offset: controls.frame.height)
            //toggleControllPanelButton.iconHex = "f103"
        }
        //controlPanelTimer?.invalidate()
        //controlPanelTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("hideControls"), userInfo: AnyObject?(), repeats: false)
    }
    
    @IBAction func toggleControlPanel(sender: NIKFontAwesomeButton) {
        if (self.presentedViewController == nil){
            if (controlPanelHidden){
                showControlPanel()
            } else {
                hideControls(true)
            }
        }
    }
    
    func showToolsPanel(){
        ViewUtils.slideViewInFromLeft(sideView)
        ViewUtils.slideViewInFromLeft(toggleToolsButton, offset: sideView.frame.width)
        toolsPanelHidden = false
    }
    
    func hideToolsPanel(){
        ViewUtils.slideViewOutToLeft(sideView)
        ViewUtils.slideViewOutToLeft(toggleToolsButton, offset: toggleToolsButton.frame.width)
        toolsPanelHidden = true
    }
    
    @IBAction func toggleToolsPanel(sender: NIKFontAwesomeButton) {
        if toolsPanelHidden {
            showToolsPanel()
        } else {
            hideToolsPanel()
        }
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
            sender.color = UIColor.whiteColor()
            //self.view.sendSubviewToBack(drawingView)
            if (self.view.subviews[3] as! NSObject == drawingView){
                self.view.exchangeSubviewAtIndex(2, withSubviewAtIndex: 3)
            }
            
        } else {
            drawingMode = true
            drawingView.enabled = true
            sender.color = UIColor.blueColor()
            if (self.view.subviews[2] as! NSObject == drawingView){
                self.view.exchangeSubviewAtIndex(2, withSubviewAtIndex: 3)
            }
            //self.view.bringSubviewToFront(drawingView)
        }
    }
    
    func showDropboxItem(url: NSURL!){
        if let data = NSData(contentsOfURL: url){
            self.presentationWebView!.loadData(data, MIMEType: "application/pdf", textEncodingName: "ISO-8859-1", baseURL: nil)
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

    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if let touch: UITouch = touches.first as? UITouch{
            ((touch.gestureRecognizers as NSArray)[0] as! UIGestureRecognizer).cancelsTouchesInView = false
            let touchLocation = touch.locationInView(self.view) as CGPoint
            
            if drawingMode {
                var maybeError : OTError?
                let screenBounds = UIScreen.mainScreen().bounds
                CallUtils.session?.signalWithType("line_start_point", string: "\(touchLocation.x/screenBounds.width),\(touchLocation.y/screenBounds.height)", connection: nil, error: &maybeError)
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
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        self.isDragging = false
    }
    override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        println("CANCEL")
    }
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        if let touch: UITouch = touches.first as? UITouch{
            let touchLocation = touch.locationInView(self.view) as CGPoint
            if drawingMode {
                var maybeError : OTError?
                let screenBounds = UIScreen.mainScreen().bounds
                CallUtils.session?.signalWithType("line_point", string: "\(touchLocation.x/screenBounds.width),\(touchLocation.y/screenBounds.height)", connection: nil, error: &maybeError)
            }
            if (self.isDragging){
                if let subscriber = CallUtils.subscriber?.view {
                    UIView.animateWithDuration(0.0,
                        delay: 0.0,
                        options: (UIViewAnimationOptions.BeginFromCurrentState|UIViewAnimationOptions.CurveEaseInOut),
                        animations:  {subscriber.center = touchLocation},
                        completion: nil)
                }
                if (CallUtils.isFakeCall){
                    if let subscriber = CallUtils.publisher?.view {
                        UIView.animateWithDuration(0.0,
                            delay: 0.0,
                            options: (UIViewAnimationOptions.BeginFromCurrentState|UIViewAnimationOptions.CurveEaseInOut),
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
        

        self.hideControls(false)
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
            var svc = segue.destinationViewController as! PostCallNewViewController
            svc.startTime = self.callStartTime
            svc.endTime = NSDate()
            svc.sessionNumber = self.sessionNumber
        } else if (segue.identifier == "presentDropboxList"){
            var svc = segue.destinationViewController as! DropboxListViewController
            svc.parentVC = self
        } else if (segue.identifier == "presentVideoResources"){
            var svc = segue.destinationViewController as! VideoResourceViewController
            svc.parentVC = self
            let resultPredicate = NSPredicate(format: "type == %d", 2)
            var callVideos = resources
            svc.videoDocuments = callVideos?.filteredArrayUsingPredicate(resultPredicate)
        }
        
        
    }
    
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue)
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
            }
        }
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