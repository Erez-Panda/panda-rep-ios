//
//  ColoredTabBarController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/9/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class ColoredTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBar.barTintColor = UIColor.whiteColor()
        //self.tabBar.tintColor = ColorUtils.buttonColor()
        //self.tabBar.backgroundImage = UIImage(named: "zone-video-selected")
        //self.tabBar.backgroundColor = ColorUtils.buttonColor()
        for item in self.tabBar.items as! [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor.lightGrayColor()).imageWithRenderingMode(.AlwaysOriginal)
                item.selectedImage = image.imageWithColor(ColorUtils.buttonColor()).imageWithRenderingMode(.AlwaysOriginal)
                
            }
            
        }
        self.title = "My Zone"
        ViewUtils.setBackButton(self)
        ViewUtils.setMenuButton(self)
        
        

        // Do any additional setup after loading the view.
    }
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func menu(){
        //ViewUtils.slideInMenu(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
*/
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
