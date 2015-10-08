//
//  WebResourceViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/19/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class WebResourceViewController: UIViewController {
    
    
    var resourceFile : NSNumber?
    
    @IBOutlet weak var webView: UIWebView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ServerAPI.getFileUrl(self.resourceFile!, completion: { (result) -> Void in
            self.showRemotePDF(result as String)
        })
        
    }
    
    func showRemotePDF(fileUrl: String){
        let url = NSURL(string: fileUrl)
        let requestObj = NSURLRequest(URL: url!)
        self.webView.loadRequest(requestObj)
    }
}
