//
//  CallViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/17/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit


let videoWidth : CGFloat = 264/1.5
let videoHeight : CGFloat = 198/1.5




// Change to YES to subscribe to your own stream.
let SubscribeToSelf = false

class CallViewController:UIViewController ,UITextFieldDelegate, UIGestureRecognizerDelegate, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate{
    
    @IBOutlet weak var presentationImg: UIImageView!
    
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var smallChatView: UITextView!
    @IBOutlet weak var chatMessage: UITextField!
    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    var activeChatView: UITextView!
    var isDragging: Bool = false
    

    var user: NSDictionary!
    var currentCall: NSDictionary!
    var resources: NSArray?
    var selectedResIndex = 0
    var displayResources: NSArray?
    var currentImageIndex = 0
    var callStartTime: NSDate?
    var sessionNumber: NSNumber?
    
    @IBAction func sendMessage(sender: UIButton) {
        
        var maybeError : OTError?
        CallUtils.session?.signalWithType("chat_text", string: self.chatMessage.text, connection: nil, error: &maybeError)
        self.activeChatView.text = (self.activeChatView.text + "me: " + self.chatMessage.text + "\n")
        self.chatMessage.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.smallChatView.hidden = true
        activeChatView = chatView
        // Step 1: As the view is loaded initialize a new instance of OTSession
        if (self.currentCall != nil){
            CallUtils.initCall(self.currentCall["session"] as String, token: self.currentCall["token"] as String, delegate: self)

            self.activeChatView.text = (self.activeChatView.text + "Waiting for remote side to connect...\n")
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        registerForKeyboardNotifications()
        UIEventRegister.gestureRecognizer(self, rightAction:"prev:", leftAction: "next:", upAction: "up:", downAction: "down:")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "viewDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "viewDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        
        if let dispRes = displayResources?[0] as? NSDictionary{
            loadImage(dispRes["id"] as NSNumber)
        }
        
    }
    
    func viewDidEnterBackground(){
        CallUtils.pauseCall()
    }
    
    func viewDidBecomeActive(){
        CallUtils.resumeCall()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.anyObject() as UITouch
        ((touch.gestureRecognizers as NSArray)[0] as UIGestureRecognizer).cancelsTouchesInView = false
        let touchLocation = touch.locationInView(self.view) as CGPoint
        
        
        
        if let subscriberRect = CallUtils.subscriber?.view.frame {
            if (CGRectContainsPoint(subscriberRect, touchLocation)){
                self.isDragging = true
            }
        }
        
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        self.isDragging = false
    }
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        println("CANCEL")
    }
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch: UITouch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInView(self.view) as CGPoint
        if (self.isDragging){
            if let subscriber = CallUtils.subscriber?.view {
                UIView.animateWithDuration(0.0,
                    delay: 0.0,
                    options: (UIViewAnimationOptions.BeginFromCurrentState|UIViewAnimationOptions.CurveEaseInOut),
                    animations:  {subscriber.center = touchLocation},
                    completion: nil)
            }
        }
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
        notificationCenter.addObserver(self,
            selector: "keyboardDidHide:",
            name: UIKeyboardDidHideNotification,
            object: nil)
    }
    
    func keyboardWillBeShown(sender: NSNotification){
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            return
        }
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  -= keyboardSize.height
        })
    }
    func keyboardWillBeHidden(sender: NSNotification){
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            return
        }
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  += keyboardSize.height
        })
    }
    
    func keyboardDidHide(sender: NSNotification){
        rotated()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("\(textField.text)")
        textField.resignFirstResponder()
        return true
    }
    
    func rotated(){
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            self.chatMessage.resignFirstResponder()
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            self.presentationImg.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: screenSize.height)
            //self.presentationImg.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.height, height: screenSize.width)
            CallUtils.subscriber?.view.frame = CGRect(x: screenSize.width-videoWidth, y: 0.0, width: videoWidth, height: videoHeight)
            self.activeChatView.hidden = true
            self.chatMessage.hidden = true
            self.sendButton.hidden = true
            println("landscape")
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            self.presentationImg.frame.rectByUnion(CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: screenSize.height*0.6))
            let imageHeight = self.presentationImg.frame.size.height
            CallUtils.subscriber?.view.frame = CGRect(x: screenSize.width-videoWidth , y: imageHeight+10, width: videoWidth, height: videoHeight)
            println("portraight")
            self.activeChatView.hidden = false
            self.chatMessage.hidden = false
            self.sendButton.hidden = false
        }
        
    }
    
    @IBAction func endCall(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = false
        CallUtils.stopCall()
        self.performSegueWithIdentifier("showPostCallSegue", sender: AnyObject?())
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPostCallSegue"){
            var svc = segue.destinationViewController as PostCallViewController
            let callData = ["callId": self.currentCall["id"] as NSNumber,
                            "start" : self.callStartTime!,
                            "sessionNumber": self.sessionNumber!] as Dictionary<String, AnyObject>
            svc.callData = callData

        }
    }
    
    override func viewWillAppear(animated: Bool) {
        // Step 2: As the view comes into the foreground, begin the connection process.
        CallUtils.doConnect()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    
    func loadImage(imageFile: NSNumber){
        ServerAPI.getFileUrl(imageFile, completion: { (result) -> Void in
            let url = NSURL(string: result)
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue()){
                    self.presentationImg.image = UIImage(data: data)
                }
            }
            var maybeError : OTError?
            CallUtils.session?.signalWithType("load_res", string: result, connection: nil, error: &maybeError)
        })

    }
    
    

    func next(sender: UISwipeGestureRecognizer) {
        if self.isDragging {return}
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
        if self.isDragging {return}
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
        if self.isDragging {return}
        if (selectedResIndex+1 >= self.resources?.count){
            selectedResIndex = -1
        }
        selectedResIndex++
        changeDisplayResource(selectedResIndex)
    }
    func down(sender: UISwipeGestureRecognizer) {
        if self.isDragging {return}
        if selectedResIndex <= 0{
            selectedResIndex = self.resources!.count
        }
        selectedResIndex--
        changeDisplayResource(selectedResIndex)
    }
    
    
    func changeDisplayResource(index: Int) {
        if let resource = self.resources?[index] as? NSDictionary{
            if let resourceId = resource["id"] as? NSNumber{
                ServerAPI.getResourceDisplay(resourceId, completion: { (result) -> Void in
                    self.displayResources = result
                    if let dispRes = self.displayResources?[0] as? NSDictionary{
                        self.loadImage(dispRes["id"] as NSNumber)
                    }
  
                })
            }
        }
    }

    
    // MARK: - OTSession delegate callbacks
    
    func sessionDidConnect(session: OTSession) {
        NSLog("sessionDidConnect (\(session.sessionId))")
        // Step 2: We have successfully connected, now instantiate a publisher and
        // begin pushing A/V streams into OpenTok.
        CallUtils.doPublish()
    }
    
    func sessionDidDisconnect(session : OTSession) {
        NSLog("Session disconnected (\( session.sessionId))")
    }
    
    func session(session: OTSession, streamCreated stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        CallUtils.stream = stream
        // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
        // have seen on the OpenTok session.
        if CallUtils.subscriber == nil && !SubscribeToSelf {
            //self.activeChatView.text = (self.activeChatView.text + "Remote side sent video stream\n")
            self.activeChatView.text = ""
            CallUtils.doSubscribe(stream)
        }
    }
    
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        self.navigationController?.navigationBarHidden = false
        
        if CallUtils.subscriber?.stream.streamId == stream.streamId {
            self.activeChatView.text = (self.activeChatView.text + "Remote side stopped video stream\n")
            CallUtils.doUnsubscribe()
        }
    }
    
    func session(session: OTSession, connectionCreated connection : OTConnection) {
        NSLog("session connectionCreated (\(connection.connectionId))")
        if connection.connectionId != CallUtils.session?.connection.connectionId {
            self.activeChatView.text = (self.activeChatView.text + "Remote side connected to session\n")
        }
    }
    
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        NSLog("session connectionDestroyed (\(connection.connectionId))")
        self.activeChatView.text = (self.activeChatView.text + "Remote side disconnected from session\n")
    }
    
    func session(session: OTSession, didFailWithError error: OTError) {
        NSLog("session didFailWithError (%@)", error)
    }
    
    func session(session: OTSession!, receivedSignalType type: String!, fromConnection connection: OTConnection!, withString string: String!) {
        if connection.connectionId != CallUtils.session?.connection.connectionId {
            if(type == "chat_text"){
                self.activeChatView.text = (self.activeChatView.text + string + "\n")
            }
        }
    }
    
    // MARK: - OTSubscriber delegate callbacks
    
    func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        NSLog("subscriberDidConnectToStream (\(subscriberKit))")
        self.navigationController?.navigationBarHidden = true
        self.endCallButton.hidden = false
        if let view = CallUtils.subscriber?.view {
            let imageHeight = self.presentationImg.frame.size.height
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            view.frame = CGRect(x: screenSize.width-videoWidth , y: imageHeight+10, width: videoWidth, height: videoHeight)
            self.view.addSubview(view)
            activeChatView = smallChatView
            self.chatView.hidden = true
            self.activeChatView.text = self.chatView.text
            self.activeChatView.hidden = false
            self.callStartTime = NSDate()

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
