//
//  TrainingViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/17/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class TrainingViewController: UITableViewController {
    
    var assignedTraining: NSArray?
    var selectedTraining: NSDictionary?
    var trainingResources: NSArray?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignedTraining!.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("trainingCell") as UITableViewCell
        let at = self.assignedTraining?[indexPath.row] as NSDictionary
        let t = at["training"] as NSDictionary
        let name = t["name"] as String
        cell.textLabel?.text = name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let at = self.assignedTraining?[indexPath.row] as NSDictionary
        self.selectedTraining = at["training"] as? NSDictionary
        ServerAPI.getTrainingResources(self.selectedTraining?["id"] as NSNumber, completion: { (result) -> Void in
            self.trainingResources = result
            dispatch_async(dispatch_get_main_queue()){
                self.performSegueWithIdentifier("trainingDetailSegue", sender: AnyObject?())
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "trainingDetailSegue"){
            var svc = segue.destinationViewController as TrainingDetailViewController
            svc.training = self.selectedTraining
            svc.resources = self.trainingResources
        }
    }
    
}
