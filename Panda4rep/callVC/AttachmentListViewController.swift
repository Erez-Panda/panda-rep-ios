//
//  AttachmentListViewController.swift
//  Panda4rep
//
//  Created by Erez Haim on 5/6/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class AttachmentListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum AttachmentType : Int {
        case HowItWorks
        case Press
        case Videos
        case Articles
    }
    
    var postCallVC : PostCallNewViewController?
    var productId : NSNumber?
    
    var articles: NSArray = []
    var videos: NSArray = []
    var press: NSArray = []
    var howItWorks: NSArray = []
    
    @IBOutlet weak var tableView: UITableView!
    
    func splitPromosToTypes(promos: NSArray){
        for promo in promos {
            if let type = promo["type"] as? String {
                if type == "video" {
                    videos = videos.arrayByAddingObject(promo)
                } else if type == "press" {
                    press = press.arrayByAddingObject(promo)
                } else if type == "how_it_works" {
                    howItWorks = howItWorks.arrayByAddingObject(promo)
                }
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        
        // Do any additional setup after loading the view.
        if productId != nil {
            //activity.startAnimating()
            ServerAPI.getProductPromotionalMaterials(productId!, completion: { (result) -> Void in
                if result.count > 0{
                    self.splitPromosToTypes(result)
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.tableView.reloadData()
                    //self.activity.stopAnimating()
                }
            })
            //activity.startAnimating()
            ServerAPI.getProductArticles(productId!, completion: { (result) -> Void in
                self.articles = result
                dispatch_async(dispatch_get_main_queue()){
                    self.tableView.reloadData()
                    //self.activity.stopAnimating()
                }
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AttachmentType(rawValue: section)!{
            case .HowItWorks:
                return self.howItWorks.count
            case .Press:
                return self.press.count
            case .Videos:
                return self.videos.count
            case .Articles:
                return self.articles.count
        }
        
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resourceCell")!
        var currntArr: NSArray
        switch AttachmentType(rawValue: indexPath.section)!{
            case .HowItWorks:
                currntArr = self.howItWorks
            case .Press:
                currntArr = self.press
            case .Videos:
                currntArr = self.videos
            case .Articles:
                currntArr = self.articles
        }
        if let attachment = currntArr[indexPath.row] as? NSDictionary{
            cell.textLabel?.text = attachment["name"] as? String
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var currntArr: NSArray
        switch AttachmentType(rawValue: indexPath.section)!{
            case .HowItWorks:
                currntArr = self.howItWorks
            case .Press:
                currntArr = self.press
            case .Videos:
                currntArr = self.videos
            case .Articles:
                currntArr = self.articles
        }
        postCallVC?.addAttachment(currntArr[indexPath.row] as! NSDictionary)
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch AttachmentType(rawValue: section)!{
        case .HowItWorks:
            return " How It Works?"
        case .Press:
            return " Press"
        case .Videos:
            return " Videos"
        case .Articles:
            return " Articles"
        }
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView.numberOfRowsInSection(section) == 0 {
            return UIView()
        } else {
            return tableView.headerViewForSection(section)
        }
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
