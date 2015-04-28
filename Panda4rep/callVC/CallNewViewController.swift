//
//  CallNewViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/6/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
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
    var isDragging = false
    var chatViewController: ChatViewController?
    var controlPanelTimer: NSTimer?
    var isFirstLoad = true
    var publisherSizeConst: [NSLayoutConstraint]?
    var controlPanelHidden = false
    var messageQ : NSArray = []
    var currentImage: UIImage?
    var showIncoming = true

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controlPanelTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("hideControls"), userInfo: AnyObject?(), repeats: false)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action:"tap:"))

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        if (isFirstLoad){
            buttomView.layoutIfNeeded()
            self.view.bringSubviewToFront(buttomView)
            if let webView = presentationWebView{
                self.view.bringSubviewToFront(webView)
            }
            ViewUtils.addGradientLayer(buttomView, topColor: UIColor(red:0.1/255, green:0.1/255, blue:0.1/255, alpha:0.0), bottomColor: UIColor(red:0.1/255, green:0.1/255, blue:0.1/255, alpha:0.9))
            if CallUtils.subscriber == nil && !SubscribeToSelf {
                //self.activeChatView.text = (self.activeChatView.text + "Remote side sent video stream\n")
                //self.activeChatView.text = ""
                if (!CallUtils.isFakeCall){
                    if let stream = CallUtils.stream{
                        CallUtils.doSubscribe(stream)
                    }
                }
                CallUtils.doPublish()
                
            }
            if (CallUtils.isFakeCall){
                if let view = CallUtils.publisher?.view {
                    self.view.addSubview(view)
                    
                    ViewUtils.addConstraintsToSuper(view, superView: self.view, top:0.0, left: nil, bottom: nil, right: 0.0)
                    ViewUtils.addSizeConstaints(view, width: videoWidth, height: videoHeight)

                }
                presentaionImage?.image = UIImage(named: "fake_call_image.png")
            }
            ViewUtils.roundView(chatBadge, borderWidth: 1.0, borderColor: UIColor.whiteColor())
            if ((currentImage) != nil){
                presentaionImage?.image = currentImage
            }
            isFirstLoad = false
        } else {
            controlPanelTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("hideControls"), userInfo: AnyObject?(), repeats: false)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let settings = StorageUtils.getUserSettings()
        if let hideVideo = settings["disableVideoOnCalling"] as? Bool{
            if !hideVideo{
                toggleVideo(UIButton())
            }
        } else {
            toggleVideo(UIButton())
        }
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
        controlPanelHidden = true
    }
    
    func hideControls(){
        if let controls = buttomView {
            ViewUtils.slideViewOutVertical(controls)
        }
        controlPanelHidden = true
    }
    
    @IBAction func endCall(sender: AnyObject) {
        self.performSegueWithIdentifier("showPostCall", sender: AnyObject?())
        CallUtils.stopCall()
        CallUtils.incomingViewController = nil
        showIncoming = true //for next time
        
    }
    func showControlPanel(){
        controlPanelHidden = false
        if let controls = buttomView {
            ViewUtils.slideViewinVertical(controls)
        }
        controlPanelTimer?.invalidate()
        controlPanelTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: Selector("hideControls"), userInfo: AnyObject?(), repeats: false)
    }
    
    func tap(sender:  UITapGestureRecognizer) {
        var location = sender.locationInView(self.buttomView)
        if (CGRectContainsPoint(self.toggleVideoButton.frame, location)){
            self.toggleVideo(sender)
        }
        if (CGRectContainsPoint(self.toggleSoundButton.frame, location)){
            self.toggleSound(sender)
        }
        if (CGRectContainsPoint(self.endButton.frame, location)){
            self.endCall(sender)
        }
        if (CGRectContainsPoint(self.chatButton.frame, location)){
            self.openChat(sender)
        }
        if (self.presentedViewController == nil){
            if (controlPanelHidden){
                showControlPanel()
            } else {
                hideControls(true)
            }
        }
        
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        if let touch: UITouch = touches.first as? UITouch{
            ((touch.gestureRecognizers as NSArray)[0] as! UIGestureRecognizer).cancelsTouchesInView = false
            let touchLocation = touch.locationInView(self.view) as CGPoint
            

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
            } else {
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
            chatViewController!.didMoveToParentViewController(self)
            releaseMessageQ()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.chatViewController!.view.frame.origin.y = 0.0
            })

            
        }
    }
    
    func requestForCurrentSlide(){
            var maybeError : OTError?
            CallUtils.session?.signalWithType("send_current_res", string: "", connection: nil, error: &maybeError)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
            CallUtils.stream = stream
            CallUtils.doSubscribe(stream)
        } else if (CallUtils.isFakeCall){
            CallUtils.stream = stream
        }

    }
    
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        if (stream.videoType == OTStreamVideoType.Screen){
            CallUtils.doScreenUnsubscribe()
        } else {
            self.navigationController?.navigationBarHidden = false
            if CallUtils.subscriber?.stream.streamId == stream.streamId {
                //self.activeChatView.text = (self.activeChatView.text + "Remote side stopped video stream\n")
                CallUtils.doUnsubscribe()
            }
        }
    }
    
    func session(session: OTSession, connectionCreated connection : OTConnection) {
        NSLog("session connectionCreated (\(connection.connectionId))")
        if connection.connectionId != CallUtils.session?.connection.connectionId {
            //self.activeChatView.text = (self.activeChatView.text + "Remote side connected to session\n")
            CallUtils.remoteSideConnected()
        }
    }
    
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        NSLog("session connectionDestroyed (\(connection.connectionId))")
        //self.activeChatView.text = (self.activeChatView.text + "Remote side disconnected from session\n")
    }
    
    func session(session: OTSession, didFailWithError error: OTError) {
        NSLog("session didFailWithError (%@)", error)
    }
    
    func session(session: OTSession!, receivedSignalType type: String!, fromConnection connection: OTConnection!, withString string: String!) {
        if connection?.connectionId != CallUtils.session?.connection?.connectionId {
            if (type == "load_res"){
                presentationWebView?.hidden = true
                var imageUrl = string
                if let url = NSURL(string: imageUrl){
                    if let data = NSData(contentsOfURL: url){
                        if let pImg = presentaionImage {
                            pImg.image = UIImage(data: data)
                        } else {
                            currentImage = UIImage(data: data)
                        }
                        
                        
                    }
                }
            }
            if (type == "load_video"){
                var linkObj = string
                presentationWebView?.hidden = false
                var embedHTML = "<html><head>"
                embedHTML += "<style type=\"text/css\">"
                embedHTML += "body {"
                embedHTML +=    "background-color: transparent;color: white;}\\</style>\\</head><body style=\"margin:0\">\\<embed webkit-playsinline id=\"yt\" src=\"\(linkObj)\" type=\"application/x-shockwave-flash\" \\width=\"\(presentationWebView?.frame.width)\" height=\"\(presentationWebView?.frame.height)\"></embed>\\</body></html>"
                
                presentationWebView?.loadHTMLString(embedHTML, baseURL:nil)
            }
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
            }
        }
    }
    
    // MARK: - OTSubscriber delegate callbacks
    
    func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        NSLog("subscriberDidConnectToStream (\(subscriberKit))")
        self.navigationController?.navigationBarHidden = true
        //self.endCallButton.hidden = false
        if let view = CallUtils.subscriber?.view {
            self.view.addSubview(view)
            
            ViewUtils.addConstraintsToSuper(view, superView: self.view, top:0.0, left: nil, bottom: nil, right: 0.0)
            ViewUtils.addSizeConstaints(view, width: videoWidth, height: videoHeight)
            //activeChatView = smallChatView
           // self.chatView.hidden = true
            //self.activeChatView.text = self.chatView.text
           // self.activeChatView.hidden = false
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