//
//  ServerAPI.swift
//  Panda4doctor
//
//  Created by Erez on 11/30/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

var SERVER_URL = "http://livemed.co"
//var SERVER_URL = "http://127.0.0.1:8000"
//var SERVER_URL = "http://10.0.0.6:8000"
//var SERVER_URL = "http://172.22.22.117:8000"
//var SERVER_URL = "http://192.168.1.244:8000"

import AFNetworking

@objc protocol LoginDelegate{
    optional func loginComplete()
}

struct ServerAPI {
    
    static var token = ""
    static var delegate:LoginDelegate?
    enum RequestType{
        case POST
        case GET
        case DELETE
        case PATCH
        case PUT
    }
    
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
    
    static func getStringResult(result: AnyObject) ->NSString {
        if let data = result as? NSData{
            if let res = NSString(data: data, encoding: NSUTF8StringEncoding){
                return res.stringByReplacingOccurrencesOfString("\"", withString: "", options: nil, range: NSMakeRange(0,res.length))
            } else {
                return ""
            }
        }
        return ""
    }
    
    static func getBoolResult(result: AnyObject) ->Bool {
        if let res = result as? Bool {
            return res
        } else {
            return false
        }
    }
    
    static func login(email: String, password: String, completion: (result: Bool) -> Void) -> Void{
        let message = ["username":email,
            "password":password
        ]
        self.http("/api-token-auth/", message: message, method: .POST, completion: {result -> Void in
            if let res = result as? NSDictionary{
                if (nil != res["token"]){
                    self.token = res["token"] as! NSString as String
                    self.delegate?.loginComplete!()
                    completion(result: true)
                } else {
                    completion(result: false)
                }
            } else {
                completion(result: false)
            }
        })
    }
    
    
    static func getUser (completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/users/me/", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func loginout(completion: (result: Bool) -> Void) -> Void{
        completion(result: true) //fix after adding response to server
    }
    
    static func isEmailAvailable (email: String, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/users/email_available/?email=\(email)", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    static func registerUser (userData: Dictionary<String, AnyObject>, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/users/", message: userData, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func updateUser (userData: Dictionary<String, AnyObject>, id: NSNumber, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/users/\(id)/", message: userData, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getProducts (completion: (result: NSArray) -> Void) -> Void{
        self.http("/products/", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getCallOpenings (product: NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/scheduler/call_openings/?product=\(product)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func newCall (callData: Dictionary<String, AnyObject>, fromSlot: NSNumber, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/new/?from_slot=\(fromSlot)", message: callData, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func newGuestCall (callData: Dictionary<String, AnyObject>, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/new/?guest_call=\(true)", message: callData, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func newCall (callData: Dictionary<String, AnyObject>, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/new/", message: callData, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func newCallRequest (callData: Dictionary<String, AnyObject>, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/requests/", message: callData, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getCurrentCall (completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/user/current/", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getCallById (id: String, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/\(id)/", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getUserCalls (completion: (result: NSArray) -> Void) -> Void {
        self.http("/calls/user/", completion: { (result) -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getUserLetters (completion: (result: NSArray) -> Void) -> Void {
        self.http("/products/user/medical_letter_requests/", completion: { (result) -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getOpenLetterRequests (completion: (result: NSArray) -> Void) -> Void {
        self.http("/products/user/open_medical_letter_requests/", completion: { (result) -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func sendDeviceToken (token: String){
        let data = ["registration_id": token] as Dictionary<String, String>
        self.http("/users/device-token/", message: data, method: .POST, completion: {result -> Void in
        })
        
    }
    
    static func newPostCall(data: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.http("/calls/post_calls/", message: data, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func getProductArticles(product:NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/products/articles/?product=\(product)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getProductPromotionalMaterials(product:NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/products/promotional_materials/?product=\(product)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getFileUrl(file: NSNumber, completion: (result: NSString) -> Void) -> Void{
        self.http("/resources/files/?file=\(file)", isJSONRequest: false, completion: {result -> Void in
            completion(result: self.getStringResult(result))
        })
    }
    
    static func newMedicalLetterRequest(request: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.http("/products/medical_letter_requests/", message: request, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func newSampleRequest(request: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.http("/products/sample_requests/", message: request, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func getProductSampleTypes(product:NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/products/sample_types/?product=\(product)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getDictionary(type: String, completion: (result: NSArray) -> Void) -> Void{
        self.http("/dictionary/\(type)/", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getAllDrugs(completion: (result: NSArray) -> Void) -> Void{
        self.http("/drugs/", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getTherapyArea(completion: (result: NSArray) -> Void) -> Void{
        self.http("/drugs/therapy_areas/", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getSubTherapyArea(therapyArea: NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/drugs/sub_therapy_areas/?therapy_area=\(therapyArea)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getSubTherapyAreaDrugs(subTherapyArea: NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/drugs/sub_therapy_drugs/?sub_therapy_area=\(subTherapyArea)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getSubTherapyAreaProduct(subTherapyArea: NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/drugs/sub_therapy_products/?sub_therapy_area=\(subTherapyArea)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func setUserEmailNotifications(request: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.http("/users/doctors/email_settings/", message: request, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func resetUserPassword(request: Dictionary<String, AnyObject>, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/users/reset_password/", message: request, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func sendSupportEmail(request: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.http("/users/support_email/", message: request, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func acceptCallOffer(offerId: NSNumber, completion: (result: NSDictionary) -> Void) -> Void{
        let data = ["offer_id": offerId] as Dictionary<String, AnyObject>
        self.http("/calls/user/offer/accept/", message: data, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getAssignedTraining(completion: (result: NSArray) -> Void) -> Void{
        self.http("/training/assigned/", completion: { (result) -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getAssignedProducts(completion: (result: NSArray) -> Void) -> Void{
        self.http("/products/assigned/", completion: { (result) -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getTrainingResources (trainingId: NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/resources/training/?training_id=\(trainingId)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    static func getUserCallOffers(completion: (result: NSArray) -> Void) -> Void{
        self.http("/calls/user/offers/", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getResourceTest (resource: NSNumber, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/tests/resource/?resource=\(resource)", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getTestQuestions(test: NSNumber,completion: (result: NSArray) -> Void) -> Void{
        self.http("/tests/test/questions/?test=\(test)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getQuestionAnswers(question: NSNumber,completion: (result: NSArray) -> Void) -> Void{
        self.http("/tests/question/answers/?question=\(question)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func answerTest(answer: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.http("/tests/test/answer/", message: answer, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func getResourceDisplay(resourceId: NSNumber, completion: (result: NSArray) -> Void) -> Void{
        self.http("/resources/display/?resource=\(resourceId)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getLatestPostCall(product: NSNumber, callee: NSNumber ,completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/post_calls/latest/?product_id=\(product)&callee=\(callee)", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getResourceById(resourceIds: NSArray, completion: (result: NSArray) -> Void) -> Void{
        let data = ["id_list": resourceIds] as Dictionary<String, AnyObject>
        var err: NSError?
        if let json = NSJSONSerialization.dataWithJSONObject(data, options: nil, error: &err){
            let jsonStr = NSString(data: json, encoding: NSUTF8StringEncoding)!
            let url = "/resources/id/?data=\(jsonStr)"
            self.http(url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!, completion: {result -> Void in
                completion(result: self.getArrayResult(result))
            })
        }
    }
    
    static func getRepDoctors(completion: (result: NSArray) -> Void) -> Void{
        self.http("/users/rep_doctors/", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getUserCallsInTimeFrame(start: NSDate, end: NSDate, completion: (result: NSArray) -> Void) -> Void{
        var startStr = TimeUtils.dateToServerString(start)
        startStr = startStr.stringByAddingPercentEscapesUsingEncoding(NSStringEncoding())!
        var endStr = TimeUtils.dateToServerString(end)
        endStr = endStr.stringByAddingPercentEscapesUsingEncoding(NSStringEncoding())!
        self.http("/calls/user/in_time_frame/?start=\(startStr)&end=\(endStr)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getUserPostCallsInTimeFrame(start: NSDate, end: NSDate, completion: (result: NSArray) -> Void) -> Void{
        var startStr = TimeUtils.dateToServerString(start)
        startStr = startStr.stringByAddingPercentEscapesUsingEncoding(NSStringEncoding())!
        var endStr = TimeUtils.dateToServerString(end)
        endStr = endStr.stringByAddingPercentEscapesUsingEncoding(NSStringEncoding())!
        self.http("/calls/user/post_calls/in_time_frame/?start=\(startStr)&end=\(endStr)", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func getUserRetentionRate(completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/user/retention_rate/", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getPostCall(call: NSNumber, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/calls/post_calls/?call=\(call)", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    

    static func sendFollowupEmail(data: Dictionary<String, AnyObject>, completion: (result: Bool) -> Void) -> Void{
        self.http("/calls/post_calls/send_followup_email/", message: data, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func newContact(data: Dictionary<String, AnyObject>, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/contacts/", message: data, method: .POST, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    static func updateContact(data: Dictionary<String, AnyObject>, id: NSNumber,completion: (result: Bool) -> Void) -> Void{
        self.http("/contacts/\(id)/", message: data, method: .PUT, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func deleteContact(id: NSNumber,completion: (result: Bool) -> Void) -> Void{
        self.http("/contacts/\(id)/", message: [:], method: .DELETE, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func getContacts(completion: (result: NSArray) -> Void) -> Void{
        self.http("/contacts/", completion: {result -> Void in
            completion(result: self.getArrayResult(result))
        })
    }
    
    static func startCallArchive(data: Dictionary<String, AnyObject>,completion: (result: Bool) -> Void) -> Void{
        self.http("/calls/archive/start/", message: data, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func stopCallArchive(data: Dictionary<String, AnyObject>,completion: (result: Bool) -> Void) -> Void{
        self.http("/calls/archive/stop/", message: data, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func sendCallingNotification(data: Dictionary<String, AnyObject>,completion: (result: Bool) -> Void) -> Void{
        self.http("/calls/send_calling_notification/", message: data, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func sendMedicalInquiryResponse(data: Dictionary<String, AnyObject>,completion: (result: Bool) -> Void) -> Void{
        self.http("/products/medical_letter_responses/", message: data, method: .POST, completion: {result -> Void in
            completion(result: true)
        })
    }
    
    static func getMedicalInquiry(id: NSNumber, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/products/medical_letter_requests/\(id)/", completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func respondtoMedicalInquiry(id: NSNumber, data: Dictionary<String, AnyObject>, completion: (result: NSDictionary) -> Void) -> Void{
        self.http("/products/medical_letter_requests/\(id)/", message: data, method: .PATCH, completion: {result -> Void in
            completion(result: self.getDictionaryResult(result))
        })
    }
    
    static func getAFManager(isJSONRequest: Bool) -> AFHTTPRequestOperationManager{
        let manager = AFHTTPRequestOperationManager()
        if (isJSONRequest){
            manager.requestSerializer = AFJSONRequestSerializer()
            manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
            manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        } else {
            manager.responseSerializer = AFHTTPResponseSerializer()
        }
        if (self.token != ""){
            manager.requestSerializer.setValue("Token", forHTTPHeaderField: "WWW-Authenticate")
            manager.requestSerializer.setValue("Token \(self.token)", forHTTPHeaderField: "Authorization")
        }
        return manager
    }
    
    static func getResponseHandler(completion: (result: AnyObject) -> Void) -> (operation: AFHTTPRequestOperation!,responseObject: AnyObject!) -> Void{
        return {(operation: AFHTTPRequestOperation!,responseObject: AnyObject?) in
            if responseObject != nil{
                completion(result: responseObject!)
            } else {
                completion(result: false)
            }
        }
    }
    
    static func getErrorHandler(completion: (result: AnyObject) -> Void) -> (operation: AFHTTPRequestOperation!,error: NSError!) -> Void{
        return {(operation: AFHTTPRequestOperation!,error: NSError!) in
            completion(result: false)
            println("Error: " + error.localizedDescription)
        }
    }
    
    
    static func http(url: String, message: Dictionary<String, AnyObject>? = nil, isJSONRequest: Bool = true, method: RequestType = .GET, completion: (result: AnyObject) -> Void) -> Void{
        if (!NetworkUtils.checkConnection()){
            completion(result: false)
            return
        }
        let manager = getAFManager(isJSONRequest)
        switch method{
        case .POST:
            manager.POST(SERVER_URL + url, parameters: message, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        case .GET:
            manager.GET(SERVER_URL + url, parameters: message, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        case .PATCH:
            manager.PATCH(SERVER_URL + url, parameters: message, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        case .PUT:
            manager.PUT(SERVER_URL + url, parameters: message, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        case .DELETE:
            manager.DELETE(SERVER_URL + url, parameters: message, success: getResponseHandler(completion),failure: getErrorHandler(completion))
            break
        default:
            break
        }
    }

    static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    static func uploadFile(data: NSData, filename:String, completion: (result: AnyObject) -> Void) -> Void{
        if (!NetworkUtils.checkConnection()){
            completion(result: false)
            return
        }
        var request = NSMutableURLRequest(URL: NSURL(string: SERVER_URL + "/resources/upload/")!)
        var session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "PUT"
        let boundary = generateBoundaryString()
        var err: NSError?
                request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        let mimetype = "image/jpeg"
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(data)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        request.HTTPBody = body


        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            //println("Response: \(response)")
            if (response == nil || (response as! NSHTTPURLResponse).statusCode > 299){
                completion(result: [:])
                return
            }
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            //println("Body: \(strData)")
            var err: NSError?
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err)
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                //println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                //println("Error could not parse JSON: '\(jsonStr)'")
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
                    //println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        task.resume()

    }
    
    static func downloadFile(url: String, completion: (result: AnyObject) -> Void) -> Void{
        var session = NSURLSession.sharedSession()

        var task = session.downloadTaskWithURL(NSURL(string: url)!, completionHandler: { (nsUrl, response, error) -> Void in
            //println(response.suggestedFilename)
            NSFileManager.defaultManager().moveItemAtPath(nsUrl.path!, toPath:response.suggestedFilename!, error:nil);
            completion(result: NSURL(fileURLWithPath: response.suggestedFilename!)!)
            
        })
        task.resume()
    }
    
    
}

extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// :param: string       The string to be added to the `NSMutableData`.
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
