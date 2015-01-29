//
//  ServerAPI.swift
//  Panda4doctor
//
//  Created by Erez on 11/30/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

var SERVER_URL = "http://panda-med.com"
//var SERVER_URL = "http://192.168.10.71:8000"

@objc protocol LoginDelegate{
    optional func loginComplete()
}

struct ServerAPI {
    
    static var token = ""
    static var delegate:LoginDelegate?
    
    static func getArrayResult(result: AnyObject) ->NSArray {
        if let res = result as? NSArray {
            return res
        } else {
            return []
        }
    }
    
    static func getDictionaryResult(result: AnyObject) ->NSDictionary {
        if let res = result as? NSDictionary {
            return res
        } else {
            return [:]
        }
    }
    
    
    static func login(email: String, password: String, completion: (result: Bool) -> Void) -> Void{
        let message = ["username":email,
            "password":password
        ]
        self.post("/api-token-auth/", message: message, completion: {result -> Void in
            let res = result as NSDictionary
            if (nil != res["token"]){
                self.token = res["token"] as NSString
                self.delegate?.loginComplete!()
                completion(result: true)
            } else {
                completion(result: false)
            }
        })
    }
    
    
    static func getUser (completion: (result: NSDictionary) -> Void) -> Void{
        self.get("/users/me/", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func loginout(completion: (result: Bool) -> Void) -> Void{
        completion(result: true) //fix after adding response to server
    }
    static func registerUser (userData: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.post("/users/", message: userData, completion: {result -> Void in
            completion(result: true)
        })
        
    }
    
    static func getProducts (completion: (result: NSArray) -> Void) -> Void{
        self.get("/products/", completion: {result -> Void in
            completion(result:self.getArrayResult(result))
        })
    }
    
    static func newCallRequest (callData: Dictionary<String, String>, completion: (result: Bool) -> Void) -> Void{
        self.post("/calls/requests/", message: callData, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func getCurrentCall (completion: (result: NSDictionary) -> Void) -> Void{
        self.get("/calls/user/current/", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func sendDeviceToken (token: String){
        let data = ["registration_id": token] as Dictionary<String, String>
        self.post("/users/device-token/", message: data, completion: {result -> Void in
            //
        })
    }
    
    static func acceptCallOffer(offerId: NSNumber, completion: (result: Bool) -> Void) -> Void{
        let data = ["offer_id": offerId] as Dictionary<String, AnyObject>
        self.post("/calls/user/offer/accept/", message: data, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func getAssignedTraining(completion: (result: NSArray) -> Void) -> Void{
        self.get("/training/assigned/", completion: { (result) -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getTrainingResources (trainingId: NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.get("/resources/training/?training_id=\(trainingId)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getResourceDisplay(resourceId: NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.get("/resources/display/?resource=\(resourceId)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getResourceById(resourceIds: NSArray, completion: (result: NSArray) -> Void) -> Void{
        let data = ["id_list": resourceIds] as Dictionary<String, AnyObject>
        var err: NSError?
        if let json = NSJSONSerialization.dataWithJSONObject(data, options: nil, error: &err){
            let jsonStr = NSString(data: json, encoding: NSUTF8StringEncoding)!
            let url = "/resources/id/?data=\(jsonStr)"
            self.get(url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, completion: {result -> Void in
                completion(result: self.getArrayResult(result))
            })
        }
    }
    
    static func getFileUrl(file: NSNumber, completion: (result: NSString) -> Void) -> Void{
        self.get("/resources/files/?file=\(file)", isJson: false, completion: {result -> Void in
            completion(result: result as NSString)
        })
    }
    
    static func getUserCallOffers(completion: (result: NSArray) -> Void) -> Void{
        self.get("/calls/user/offers/", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getResourceTest (resource: NSNumber, completion: (result: NSDictionary) -> Void) -> Void{
        self.get("/tests/resource/?resource=\(resource)", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getTestQuestions(test: NSNumber,completion: (result: NSArray) -> Void) -> Void{
        self.get("/tests/test/questions/?test=\(test)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getQuestionAnswers(question: NSNumber,completion: (result: NSArray) -> Void) -> Void{
        self.get("/tests/question/answers/?question=\(question)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func answerTest(answer: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.post("/tests/test/answer/", message: answer, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func getLatestPostCall(product: NSNumber,completion: (result: NSDictionary) -> Void) -> Void{
        self.get("/calls/post_calls/latest/?product_id=\(product)", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func newPostCall(data: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.post("/calls/post_calls/", message: data, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func post(url: String, message: Dictionary<String, AnyObject>, completion: (result: AnyObject) -> Void) -> Void{
        var request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL + url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(message, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if (self.token != ""){
            request.addValue("Token", forHTTPHeaderField: "WWW-Authenticate")
            request.addValue("Token \(self.token)", forHTTPHeaderField: "Authorization")
        }
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err)
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON: AnyObject = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    //                    var success = parseJSON["firstName"] as? String
                    //                    println("Succes: \(success)")
                    completion(result: json!)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
        
    }
    
    static func get(url: String, completion: (result: AnyObject) -> Void) -> Void{
        get(url, isJson: true, completion: {result -> Void in
            completion(result: result as AnyObject)
        })
    }
    static func get(url: String, isJson: Bool, completion: (result: AnyObject) -> Void) -> Void{
        var request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL + url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        var err: NSError?
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if (self.token != ""){
            request.addValue("Token", forHTTPHeaderField: "WWW-Authenticate")
            request.addValue("Token \(self.token)", forHTTPHeaderField: "Authorization")
        }
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData: NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
    
            println("Body: \(strData)")

            if (!isJson) {
                let str = strData.stringByReplacingOccurrencesOfString("\"", withString: "")
                completion(result: str)
                return
            }
            if strData.length == 0 {
                completion(result: false)
                return
            }
            var err: NSError?
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err)
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON: AnyObject = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    //                    var success = parseJSON["firstName"] as? String
                    //                    println("Succes: \(success)")
                    completion(result: json!)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()
        
    }
    
}
