//
//  DropboxListViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 5/8/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
//import Dropbox_iOS_SDK

class DropboxListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate {
    
    var documents = []
    var parentVC : UIViewController?
    var restClient:DBRestClient?
    
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if DBSession.sharedSession().isLinked() {
            self.restClient = DBRestClient(session: DBSession.sharedSession())
            self.restClient?.delegate = self
            self.restClient?.loadMetadata("/")
        }
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero

        // Do any additional setup after loading the view.
    }

    @IBAction func connectToDropbox(sender: UIButton) {
        if !DBSession.sharedSession().isLinked() {
            DBSession.sharedSession().linkFromController(self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dropboxCell")!
        if let document = documents[indexPath.row] as? DBMetadata{
            cell.textLabel?.text = document.filename
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let document = documents[indexPath.row] as? DBMetadata{
            self.restClient?.loadStreamableURLForFile(document.path)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    
    
    @IBAction func close(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    
    func restClient(client: DBRestClient!, loadedMetadata metadata: DBMetadata!) {
        if (metadata.isDirectory){
            self.documents = metadata.contents
            tableView.reloadData()
        }
    }
    
    func restClient(client: DBRestClient!, loadMetadataFailedWithError error: NSError!) {
        print("ERROR")
    }
    
    func restClient(restClient: DBRestClient!, loadedSharableLink link: String!, forFile path: String!) {
        print(link)
    }
    
    func restClient(restClient: DBRestClient!, loadSharableLinkFailedWithError error: NSError!) {
        print("ERROR --> SharableLink")
    }
    
    func restClient(restClient: DBRestClient!, loadedStreamableURL url: NSURL!, forFile path: String!) {
        if let vc = parentVC as? CallNewViewController {
            vc.showDropboxItem(url)
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
