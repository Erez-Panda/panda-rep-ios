//
//  CallUtils.swift
//  Panda4doctor
//
//  Created by Erez on 1/8/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
let ApiKey = "45145512"

@objc protocol CallDelegate{
    optional func remoteSideConnected()
}


struct CallUtils{
    static var session : OTSession?
    static var publisher : OTPublisher?
    static var screenPublisher : OTPublisher?
    static var subscriber : OTSubscriber?
    static var screenSubscriber : OTSubscriber?
    static var token : String?
    static var stream : OTStream?
    static var sessionDelegate : OTSessionDelegate?
    static var subscriberDelegate : OTSubscriberKitDelegate?
    static var publisherDelegate : OTPublisherDelegate?
    static var delegate:CallDelegate?
    static var remoteSideConnect = false
    static var callViewController: UIViewController?
    static var incomingViewController : UIViewController?
//    static var upcomingViewController : UpcomingCallViewController?
    static var rootViewController: UIViewController?
    static var fakeStream: OTStream?
    static var isFakeCall = false
    static var currentCall: NSDictionary?
    
    static func startArchive(){
        if let id = self.currentCall?["id"] as? NSNumber{
            let data = ["call": id] as Dictionary<String, AnyObject>
            ServerAPI.startCallArchive(data, completion: { (result) -> Void in
                
            })
        }
    }
    
    static func stopArchive(){
        if let id = self.currentCall?["id"] as? NSNumber{
            let data = ["call": id] as Dictionary<String, AnyObject>
            ServerAPI.stopCallArchive(data, completion: { (result) -> Void in
                
            })
        }
    }
    
    static func fakeCall (){
        isFakeCall = true
//        ViewUtils.showIncomingCall()
    }
    
    static func isRemoteSideConnected() -> Bool{
        return remoteSideConnect
    }
    
    static func remoteSideConnected(){
        remoteSideConnect = true
        self.delegate?.remoteSideConnected!()
    }
    static func getCallViewController() -> CallNewViewController?{
        return callViewController as? CallNewViewController
    }
    static func connectToCurrentCallSession(delegateViewController: UIViewController, completion: (result: NSDictionary) -> Void) -> Void{
        callViewController = delegateViewController
        ServerAPI.getCurrentCall( {result -> Void in
            self.currentCall = result
            // Step 1: As the view is loaded initialize a new instance of OTSession
            if let call = self.currentCall?["session"] as? String{
                CallUtils.initCall(call, token: self.currentCall?["token"] as! String, delegate: delegateViewController)
                completion(result: self.currentCall!)
            } else{
                completion(result: [:])
            }
        })
    }
    
    static func connectToCallSessionById(id:String, delegateViewController: UIViewController, completion: (result: NSDictionary) -> Void) -> Void{
        callViewController = delegateViewController
        ServerAPI.getCallById( id, completion: {result -> Void in
            self.currentCall = result
            // Step 1: As the view is loaded initialize a new instance of OTSession
            if let call = self.currentCall?["session"] as? String{
                CallUtils.initCall(call, token: self.currentCall?["token"] as! String, delegate: delegateViewController)
                completion(result: self.currentCall!)
            } else{
                completion(result: [:])
            }
        })
    }
    
    static func initCall(sessionId: String, token: String, delegate: AnyObject){
        self.token = token
        self.sessionDelegate = delegate as? OTSessionDelegate
        self.subscriberDelegate = delegate as? OTSubscriberKitDelegate
        self.publisherDelegate = delegate as? OTPublisherDelegate
        session = OTSession(apiKey: ApiKey, sessionId: sessionId, delegate: sessionDelegate)
        self.doConnect()
        
    }
    
    static func pauseCall(){
        doUnsubscribe()
        doUnpublish()
        doScreenUnpublish()
        var maybeError : OTError?
        session?.disconnect(&maybeError)
        session = nil
        token = nil
        stream = nil
        sessionDelegate = nil
        subscriberDelegate = nil
        publisherDelegate = nil
        remoteSideConnect = false
    }
    
    static func resumeCall(){
        if (session != nil) {
            self.doConnect()
            self.doPublish()
        }
    }
    
    static func stopCall(){
        self.pauseCall()
    }
    
    // MARK: - OpenTok Methods
    
    /**
    * Asynchronously begins the session connect process. Some time later, we will
    * expect a delegate method to call us back with the results of this action.
    */
    static func doConnect() {
        if let session = self.session {
            var maybeError : OTError?
            session.connectWithToken(self.token, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            } else {
                screenPublisher = OTPublisher(delegate: self.publisherDelegate, name: "", audioTrack: false, videoTrack: true)
                screenPublisher?.videoType = OTPublisherKitVideoType.Screen
                screenPublisher?.audioFallbackEnabled = false
                //screenPublisher?.videoCapture.releaseCapture()
            }
        }
    }
    
    /**
    * Sets up an instance of OTPublisher to use with this session. OTPubilsher
    * binds to the device camera and microphone, and will provide A/V streams
    * to the OpenTok session.
    */
    static func doPublish() {
        publisher = OTPublisher(delegate: self.publisherDelegate)
        publisher?.publishVideo = false
        var maybeError : OTError?
        session?.publish(publisher, error: &maybeError)
        
        if let error = maybeError {
            showAlert(error.localizedDescription)
        }

    }
    
    static func doScreenPublish(view: UIView) {

        screenPublisher?.videoCapture = TBScreenCapture(view: view)
        //screenPublisher?.publishVideo = true
        var maybeError : OTError?
        session?.publish(screenPublisher, error: &maybeError)
        
        
        if let error = maybeError {
            showAlert(error.localizedDescription)
        }
        
    }
    
    static func doScreenSubscribe(stream : OTStream) {
        if let session = self.session {
            screenSubscriber = OTSubscriber(stream: stream, delegate: self.subscriberDelegate)
            var maybeError : OTError?
            session.subscribe(screenSubscriber, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
        }
    }
    static func doScreenUnsubscribe() {
        if let screenSubscriber = self.screenSubscriber {
            var maybeError : OTError?
            session?.unsubscribe(screenSubscriber, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
            
            screenSubscriber.view.removeFromSuperview()
            self.screenSubscriber = nil
        }
    }
    
    /**
    * Instantiates a subscriber for the given stream and asynchronously begins the
    * process to begin receiving A/V content for this stream. Unlike doPublish,
    * this method does not add the subscriber to the view hierarchy. Instead, we
    * add the subscriber only after it has connected and begins receiving data.
    */
    static func doSubscribe(stream : OTStream) {
        if let session = self.session {
            subscriber = OTSubscriber(stream: stream, delegate: self.subscriberDelegate)
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
    static func doUnsubscribe() {
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
    
    static func doUnpublish() {
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
    
    static func doScreenUnpublish() {
        if let screenPublisher = self.screenPublisher {
            var maybeError : OTError?
            session?.unpublish(screenPublisher, error: &maybeError)
            if let error = maybeError {
                showAlert(error.localizedDescription)
            }
            
            //screenPublisher.view.removeFromSuperview()
            self.screenPublisher = nil
        }
    }
    
    // MARK: - Helpers
    
    static func showAlert(message: String) {
        // show alertview on main UI
        dispatch_async(dispatch_get_main_queue()) {
            let al = UIAlertView(title: "OTError", message: message, delegate: nil, cancelButtonTitle: "OK")
        }
    }
    
    
}

