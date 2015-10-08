//
//  VideoResourceViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 5/12/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class VideoResourceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var documents = []
    var parentVC : UIViewController?
    var videoDocuments : NSArray?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if videoDocuments != nil{
            documents = videoDocuments!
        }
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        // Do any additional setup after loading the view.
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
        let cell = tableView.dequeueReusableCellWithIdentifier("videoResCell")!
        if let document = documents[indexPath.row] as? NSDictionary{
            cell.textLabel?.text = document["name"] as? String
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let document = documents[indexPath.row] as? NSDictionary{
            if let vc = parentVC as? CallNewViewController {
                vc.showVideoItem(document["url"] as! String)
            }
        }
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    
    
    @IBAction func close(sender: UIButton) {
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
