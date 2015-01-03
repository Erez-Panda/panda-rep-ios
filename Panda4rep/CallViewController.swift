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

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
let ApiKey = "45118952"


// Change to YES to subscribe to your own stream.
let SubscribeToSelf = false

class CallViewController:UIViewController , OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var presentationImg: UIImageView!
    
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var smallChatView: UITextView!
    @IBOutlet weak var chatMessage: UITextField!
    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    var activeChatView: UITextView!
    var isDragging: Bool = false
    
    var session : OTSession?
    var publisher : OTPublisher?
    var subscriber : OTSubscriber?
    var user: NSDictionary!
    var currentCall: NSDictionary!
    var resources: NSArray?
    var selectedRes: NSDictionary?
    var displayRescources: NSArray?
    var currentImageIndex = 0
    var callStartTime: NSDate?
    var sessionNumber: NSNumber?
    
    @IBAction func sendMessage(sender: UIButton) {
        
        var maybeError : OTError?
        session?.signalWithType("chat_text", string: self.chatMessage.text, connection: nil, error: &maybeError)
        self.activeChatView.text = (self.activeChatView.text + "me: " + self.chatMessage.text + "\n")
        self.chatMessage.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.smallChatView.hidden = true
        activeChatView = chatView
        // Step 1: As the view is loaded initialize a new instance of OTSession
        if (self.currentCall != nil){
            session = OTSession(apiKey: ApiKey, sessionId: self.currentCall["session"] as String, delegate: self)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        registerForKeyboardNotifications()
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "next:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "prev:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        if let dispRes = displayRescources?[0] as? NSDictionary{
            loadImage(dispRes["id"] as NSNumber)
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        let touch: UITouch = touches.anyObject() as UITouch
        ((touch.gestureRecognizers as NSArray)[0] as UIGestureRecognizer).cancelsTouchesInView = false
        let touchLocation = touch.locationInView(self.view) as CGPoint
        
        
        
        if let subscriberRect = self.subscriber?.view.frame {
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
            if let subscriber = self.subscriber?.view {
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
            self.subscriber?.view.frame = CGRect(x: screenSize.width-videoWidth, y: 0.0, width: videoWidth, height: videoHeight)
            self.activeChatView.hidden = true
            self.chatMessage.hidden = true
            self.sendButton.hidden = true
            println("landscape")
        }
        
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            self.presentationImg.frame.rectByUnion(CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: screenSize.height*0.6))
            let imageHeight = self.presentationImg.frame.size.height
            self.subscriber?.view.frame = CGRect(x: screenSize.width-videoWidth , y: imageHeight+10, width: videoWidth, height: videoHeight)
            println("portraight")
            self.activeChatView.hidden = false
            self.chatMessage.hidden = false
            self.sendButton.hidden = false
        }
        
    }
    
    @IBAction func endCall(sender: AnyObject) {
        self.navigationController?.navigationBarHidden = false
        doUnsubscribe()
        doUnpublish()
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
        doConnect()
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
            self.session?.signalWithType("load_res", string: result, connection: nil, error: &maybeError)
        })

    }
    
    

    func next(sender: UISwipeGestureRecognizer) {
        if (currentImageIndex+1 == self.displayRescources?.count){
            return
        }
        currentImageIndex++
        if let dispRes = displayRescources?[currentImageIndex] as? NSDictionary{
            if let imgFile = dispRes["id"] as? NSNumber{
                loadImage(imgFile)
                
            }
        }
    }
    func prev(sender: UISwipeGestureRecognizer) {
        if currentImageIndex <= 0{
            return
        }
        currentImageIndex--
        if let dispRes = displayRescources?[currentImageIndex] as? NSDictionary{
            if let imgFile = dispRes["id"] as? NSNumber{
                loadImage(imgFile)
            }
        }
    }
    
    
    // MARK: - OpenTok Methods
    
    /**
    * Asynchronously begins the session connect process. Some time later, we will
    * expect a delegate method to call us back with the results of this action.
    */
    func doConnect() {
        if let session = self.session {
            var maybeError : OTError?
            session.connectWithToken(self.currentCall["token"] as String, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
        }
    }
    
    /**
    * Sets up an instance of OTPublisher to use with this session. OTPubilsher
    * binds to the device camera and microphone, and will provide A/V streams
    * to the OpenTok session.
    */
    func doPublish() {
        publisher = OTPublisher(delegate: self)
        
        var maybeError : OTError?
        session?.publish(publisher, error: &maybeError)
        
        if let error = maybeError {
            showAlert(error.localizedDescription)
        }
        
        //view.addSubview(publisher!.view)
        //publisher!.view.frame = CGRect(x: 0.0, y: 40, width: videoWidth, height: videoHeight)
    }
    
    /**
    * Instantiates a subscriber for the given stream and asynchronously begins the
    * process to begin receiving A/V content for this stream. Unlike doPublish,
    * this method does not add the subscriber to the view hierarchy. Instead, we
    * add the subscriber only after it has connected and begins receiving data.
    */
    func doSubscribe(stream : OTStream) {
        if let session = self.session {
            subscriber = OTSubscriber(stream: stream, delegate: self)
            
            var maybeError : OTError?
            session.subscribe(subscriber, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
        }
    }
    
    /**
    * Cleans the subscriber from the view hierarchy, if any.
    */
    func doUnsubscribe() {
        if let subscriber = self.subscriber {
            var maybeError : OTError?
            session?.unsubscribe(subscriber, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
            
            subscriber.view.removeFromSuperview()
            self.subscriber = nil
        }
    }
    
    func doUnpublish() {
        if let publisher = self.publisher {
            var maybeError : OTError?
            session?.unpublish(publisher, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
            
            publisher.view.removeFromSuperview()
            self.publisher = nil
        }
    }
    
    // MARK: - OTSession delegate callbacks
    
    func sessionDidConnect(session: OTSession) {
        NSLog("sessionDidConnect (\(session.sessionId))")
        
        // Step 2: We have successfully connected, now instantiate a publisher and
        // begin pushing A/V streams into OpenTok.
        doPublish()
    }
    
    func sessionDidDisconnect(session : OTSession) {
        NSLog("Session disconnected (\( session.sessionId))")
    }
    
    func session(session: OTSession, streamCreated stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
        // have seen on the OpenTok session.
        if subscriber == nil && !SubscribeToSelf {
            doSubscribe(stream)
        }
    }
    
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        NSLog("session streamCreated (\(stream.streamId))")
        self.navigationController?.navigationBarHidden = false
        
        if subscriber?.stream.streamId == stream.streamId {
            doUnsubscribe()
        }
    }
    
    func session(session: OTSession, connectionCreated connection : OTConnection) {
        NSLog("session connectionCreated (\(connection.connectionId))")
    }
    
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        NSLog("session connectionDestroyed (\(connection.connectionId))")
    }
    
    func session(session: OTSession, didFailWithError error: OTError) {
        NSLog("session didFailWithError (%@)", error)
    }
    
    func session(session: OTSession!, receivedSignalType type: String!, fromConnection connection: OTConnection!, withString string: String!) {
        if connection.connectionId != self.session?.connection.connectionId {
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
        if let view = subscriber?.view {
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
        if subscriber == nil && SubscribeToSelf {
            doSubscribe(stream)
        }
    }
    
    func publisher(publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        NSLog("publisher streamDestroyed %@", stream)
        
        if subscriber?.stream.streamId == stream.streamId {
            doUnsubscribe()
        }
    }
    
    func publisher(publisher: OTPublisherKit, didFailWithError error: OTError) {
        NSLog("publisher didFailWithError %@", error)
    }
    
    // MARK: - Helpers
    
    func showAlert(message: String) {
        // show alertview on main UI
        dispatch_async(dispatch_get_main_queue()) {
            let al = UIAlertView(title: "OTError", message: message, delegate: nil, cancelButtonTitle: "OK")
        }
    }
    
    
}
