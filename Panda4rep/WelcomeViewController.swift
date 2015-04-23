//
//  WelcomeViewController.swift
//  Panda4rep
//
//  Created by Erez on 12/17/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIPageViewControllerDataSource{
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let credentials : AnyObject = defaultUser.objectForKey("credentials") {
            LoginUtils.login(credentials["username"]as! String, password: credentials["password"] as! String, sender: self, successSegue: "showMainFromWelcomeSegue", notApprovedSegue: "showNotApprovedFromWelcomeSegue", completion: {result -> Void in

            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageTitles = ["Panda – No. 1 drug reference app worldwide (your instant connection to pharmaceutical companies)", "Discover Hidden Features", "Bookmark Favorite Tip", "Free Regular Update"]
        self.pageImages = ["page1.png", "page2.png", "page3.png", "page4.png"]
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        var startingViewController = self.viewControllerAtIndex(0)
        var viewControllers = [startingViewController] as NSArray
        self.pageViewController.setViewControllers(viewControllers as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50)
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
        var loginButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        loginButton.frame = CGRectMake(20, self.view.frame.size.height-50, 130, 40)
        loginButton.setBackgroundImage(UIImage(named: "login.jpg"), forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "openLoginForm", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginButton)
        
        var signUpButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        signUpButton.frame = CGRectMake(170, self.view.frame.size.height-50, 130, 40)
        signUpButton.setBackgroundImage(UIImage(named: "join_now.jpg"), forState: UIControlState.Normal)
        signUpButton.addTarget(self, action: "openRegisterForm", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(signUpButton)
    }
    
    
    func openRegisterForm(){
        self.performSegueWithIdentifier("showRegisterSegue", sender: AnyObject?())
    }
    
    func openLoginForm(){
        self.performSegueWithIdentifier("showLoginSegue", sender: AnyObject?())
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController  viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).pageIndex as Int
        if (index == 0 || index == NSNotFound){
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
    }
    
    
    func pageViewController(pageViewController: UIPageViewController,  viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).pageIndex as Int
        if (index == NSNotFound){
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count) {
            return nil;
        }
        
        return self.viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> PageContentViewController{
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as!  PageContentViewController
        pageContentViewController.imageFile = self.pageImages[index] as! String
        pageContentViewController.titleText = self.pageTitles[index] as! String
        pageContentViewController.pageIndex = index;
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
