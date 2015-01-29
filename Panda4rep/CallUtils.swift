//
//  CallUtils.swift
//  Panda4rep
//
//  Created by Erez on 1/8/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
let ApiKey = "45118952"

struct CallUtils{
    static var session : OTSession?
    static var publisher : OTPublisher?
    static var subscriber : OTSubscriber?
    static var token : String?
    static var stream : OTStream?
    static var sessionDelegate : OTSessionDelegate?
    static var subscriberDelegate : OTSubscriberKitDelegate?
    static var publisherDelegate : OTPublisherDelegate?
    
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
        var maybeError : OTError?
        session?.disconnect(&maybeError)
    }
    
    static func resumeCall(){
        if (session != nil) {
            self.doConnect()
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
    
    // MARK: - Helpers
    
    static func showAlert(message: String) {
        // show alertview on main UI
        dispatch_async(dispatch_get_main_queue()) {
            let al = UIAlertView(title: "OTError", message: message, delegate: nil, cancelButtonTitle: "OK")
        }
    }
    
    
}
