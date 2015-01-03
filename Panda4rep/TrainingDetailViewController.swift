//
//  TrainingDetailViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/19/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class TrainingDetailViewController: UITableViewController {
    
    var training: NSDictionary?
    var resources: NSArray?
    var resourceFile: NSNumber?
    var resourceId: NSNumber?
    
    
    func startTest(sender: UIButton!) {
        let resource = self.resources?[sender.tag] as NSDictionary
        self.resourceId = resource["id"] as? NSNumber
        self.performSegueWithIdentifier("showTestSegue", sender: AnyObject?())
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resources!.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TrainingCellView {
        let cell = tableView.dequeueReusableCellWithIdentifier("resourceCell") as TrainingCellView
        let resource = self.resources?[indexPath.row] as NSDictionary
        let name = resource["name"] as String
        cell.startTestButton.tag = indexPath.row
        cell.startTestButton.addTarget(self, action: "startTest:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.textLabel?.text = name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let resource = self.resources?[indexPath.row] as NSDictionary
        self.resourceFile = resource["file"] as? NSNumber
        self.performSegueWithIdentifier("showResSegue", sender: AnyObject?())
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showResSegue"){
            var svc = segue.destinationViewController as WebResourceViewController
            svc.resourceFile = self.resourceFile
        } else if (segue.identifier == "showTestSegue"){
            var svc = segue.destinationViewController as TestViewController
            svc.resourceId = self.resourceId
        }
    }
    
    
    
}