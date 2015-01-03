//
//  ProfileViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/17/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: NSDictionary!
    var userKeys = ["first_name", "last_name", "email"]

    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet var profileTable: UITableView!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userKeys.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell") as UITableViewCell
        let key = self.userKeys[indexPath.row] as String
        cell.detailTextLabel?.text = self.user[key] as? String
        cell.textLabel?.text = key
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileTable.dataSource = self
        self.profileTable.delegate = self
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let userProfile : AnyObject = defaultUser.objectForKey("userProfile") {
            if let imageFile = userProfile["image_file"] as? NSNumber{
                loadImage(imageFile)
            }
        }

        
    }
    
    func loadImage(imageFile: NSNumber){
        ServerAPI.getFileUrl(imageFile, completion: { (result) -> Void in
            let url = NSURL(string: result)
            if let data = NSData(contentsOfURL: url!){
                dispatch_async(dispatch_get_main_queue()){
                    self.profileImage.image = UIImage(data: data)
                }
            }
        })
        
    }
}
