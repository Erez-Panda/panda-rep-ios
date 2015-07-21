//
//  ViewUtils.swift
//  Panda4doctor
//
//  Created by Erez on 1/28/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

@objc protocol ViewDelegate{
    optional func beforeShowIncomingCall()
}


struct ViewUtils {
    
    static var profileImage: UIImage?
    static var globalLoader: UIActivityIndicatorView?
    //static var homeViewController: FeatureImageViewController?
    //static var upcomingViewController: UpcomingCallViewController?
    static var delegate:ViewDelegate?
    
    static func roundView(view: UIView, borderWidth: CGFloat, borderColor: UIColor){
        var frame =  view.frame;
        view.layer.cornerRadius = frame.size.height / 2
        view.clipsToBounds = true
        view.layer.borderWidth = borderWidth;
        view.layer.borderColor = borderColor.CGColor
    }
    
    static func borderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor, borderRadius: CGFloat){
        view.layer.borderWidth = borderWidth
        view.layer.cornerRadius = borderRadius
        view.clipsToBounds = true
        view.layer.borderColor = borderColor.CGColor
    }
    
    static func cornerRadius(view: UIView, corners: UIRectCorner ,cornerRadius: CGFloat){
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii:CGSizeMake(cornerRadius, cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.CGPath
        view.layer.mask = maskLayer
    }
    
    
    static func leftBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor, offset: CGFloat) -> CALayer {
        var leftBorder = CALayer()
        leftBorder.frame = CGRectMake(offset, 0.0 , borderWidth, view.frame.size.height);
        leftBorder.backgroundColor = borderColor.CGColor
        view.layer.addSublayer(leftBorder)
        return leftBorder
    }
    
    static func leftBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor) -> CALayer {
        return self.leftBorderView(view, borderWidth: borderWidth, borderColor: borderColor, offset: 0)
    }
    
    static func rightBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor) -> CALayer {
        var leftBorder = CALayer()
        leftBorder.frame = CGRectMake(view.frame.size.width-borderWidth, 0.0, borderWidth, view.frame.size.height);
        leftBorder.backgroundColor = borderColor.CGColor
        view.layer.addSublayer(leftBorder)
        return leftBorder
    }
    
    static func bottomBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor, offset: CGFloat) -> CALayer{
        var bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, view.frame.size.height + offset, view.frame.size.width, borderWidth)
        bottomBorder.backgroundColor = borderColor.CGColor
        view.layer.addSublayer(bottomBorder)
        return bottomBorder
    }
    
    static func topBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor, offset: CGFloat) -> CALayer{
        var topBorder = CALayer()
        topBorder.frame = CGRectMake(0.0, 0.0 + offset, view.frame.size.width, borderWidth)
        topBorder.backgroundColor = borderColor.CGColor
        view.layer.addSublayer(topBorder)
        return topBorder
    }
    
    static func addGradientLayer(view: UIView, topColor: UIColor, bottomColor: UIColor){
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = view.frame.size
        layer.frame.origin = CGPointMake(0.0,0.0)
        
        let color0 = UIColor(red:250.0/255, green:250.0/255, blue:250.0/255, alpha:0.5).CGColor
        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.1).CGColor
        let color2 = UIColor(red:150.0/255, green:150.0/255, blue: 150.0/255, alpha:0.1).CGColor
        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).CGColor
        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).CGColor
        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).CGColor
        let color6 = UIColor(red:150.0/255, green:150.0/255, blue:150.0/255, alpha:0.1).CGColor
        
        layer.colors = [topColor.CGColor,bottomColor.CGColor]
        view.layer.insertSublayer(layer, atIndex: 0)
    }
    
    static func addRoundBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor, boderSpacing: CGFloat) ->UIView{
        var roundView = UIView()
        roundView.frame = CGRectMake(view.frame.origin.x-boderSpacing,
                view.frame.origin.y-boderSpacing,
                view.frame.size.width+2*boderSpacing,
                view.frame.size.height+2*boderSpacing)
        roundView.center = view.center
        roundView.layer.borderWidth = borderWidth
        roundView.layer.cornerRadius = roundView.frame.size.height / 2
        roundView.layer.borderColor = borderColor.CGColor
        return roundView
    }
    
    static func slideViewOutVertical(view: UIView, animate: Bool = true, offset: CGFloat = 0){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        if (animate){
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                view.frame.origin.y = screenSize.height - offset
                
            })
        } else {
            view.frame.origin.y = screenSize.height - offset
        }
    }
    
    static func slideViewinVertical(view: UIView, animate: Bool = true, offset: CGFloat = 0){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        if (animate){
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                view.frame.origin.y = screenSize.height - view.frame.height - offset
                
            })
        } else {
            view.frame.origin.y = screenSize.height - view.frame.height - offset
        }
    }
    
    static func slideViewInFromLeft(view: UIView, animate: Bool = true, offset: CGFloat = 0){
        if (animate){
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                view.frame.origin.x = 0 + offset
            })
        } else {
            view.frame.origin.x = 0 + offset
        }
    }
    
    static func slideViewOutToLeft(view: UIView, animate: Bool = true, offset: CGFloat = 0){
        if (animate){
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                view.frame.origin.x = offset - view.frame.width
            })
        } else {
            view.frame.origin.x = offset - view.frame.width
        }
    }
    
    static func slideViewOutToRight(view: UIView, animate: Bool = true, offset: CGFloat = 0){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        if (animate){
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                view.frame.origin.x = screenSize.width - offset
            })
        } else {
            view.frame.origin.x = screenSize.width - offset
        }
    }
 
    static func slideInMenu (viewController: UIViewController){
        let menuView = viewController.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
        
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = viewController.view.bounds //view is self.view in a UIViewController
//        viewController.view.addSubview(blurEffectView)
        
        
//        let blurScrennshoot = getBlurEffect(viewController.view)
//        let blurView = UIImageView(image: blurScrennshoot)
//        blurView.frame = CGRectMake(0.0, 0.0, viewController.view.frame.width, viewController.view.frame.height)
//        viewController.view.addSubview(blurView)
        let grayView = UIView()
        grayView.frame = CGRectMake(0.0, 0.0, viewController.view.frame.width, viewController.view.frame.height)
        grayView.backgroundColor = UIColor.blackColor()
        grayView.alpha = 0.5
        
        
        menuView.previousViewController = viewController
        menuView.grayView = grayView
        menuView.view.frame.origin.x = -1 * menuView.view.frame.size.width
        let parent = viewController.parentViewController
        parent?.addChildViewController(menuView)
        parent?.view.addSubview(menuView.view)
        parent?.view.addSubview(grayView)
        parent?.view.bringSubviewToFront(menuView.view)
        menuView.view.alpha = 0.0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            menuView.view.frame.origin.x = 0
            menuView.view.alpha = 1
            
        })
    }
    

    
    static func getBlurEffect(view:UIView) -> UIImage{
        var snapshotView:UIView = view.snapshotViewAfterScreenUpdates(true)
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0.0)
        snapshotView.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        var imgaa :UIImage = UIGraphicsGetImageFromCurrentImageContext();
 
        var ciimage :CIImage = CIImage(image: imgaa)
        var filter : CIFilter = CIFilter(name:"CIGaussianBlur")
        filter.setDefaults()
        filter.setValue(ciimage, forKey: kCIInputImageKey)
        filter.setValue(5, forKey: kCIInputRadiusKey)
        var outputImage : CIImage = filter.outputImage;
        var finalImage :UIImage = UIImage(CIImage: outputImage)!
        return finalImage
        
    }
    
    static func getProfileImage(completion: (result: UIImage) -> Void) -> Void{
        if ((profileImage) != nil){
            completion(result: profileImage!)
        } else {
            let defaultUser = NSUserDefaults.standardUserDefaults()
            if let userProfile : AnyObject = defaultUser.objectForKey("userProfile") {
                if let imageFile = userProfile["image_file"] as? NSNumber{
                    getImageFile(imageFile, completion: { (result) -> Void in
                        self.profileImage = result
                        completion(result: result)
                    })
                }
            }
        }
    }
    
    static func getImageFile(id: NSNumber, completion: (result: UIImage) -> Void) -> Void{
        ServerAPI.getFileUrl(id, completion: { (result) -> Void in
            if let url = NSURL(string: result as String){
                if let data = NSData(contentsOfURL: url){
                    dispatch_async(dispatch_get_main_queue()){
                        var image = UIImage(data: data)
                        completion(result: image!)
                    }
                }
            }
        })
    }
/*
    static func slideInCallAlert(viewController: UIViewController, call: NSDictionary){
        upcomingViewController = viewController.storyboard?.instantiateViewControllerWithIdentifier("upcomingCall") as? UpcomingCallViewController
        upcomingViewController!.call = call
        upcomingViewController!.previousViewController = viewController
        upcomingViewController!.view.frame.origin.y = -1 * upcomingViewController!.view.frame.size.height
        if let parent = viewController.parentViewController {
            parent.addChildViewController(upcomingViewController!)
            parent.view.addSubview(upcomingViewController!.view)
            parent.view.bringSubviewToFront(upcomingViewController!.view)
        } else {
            viewController.addChildViewController(upcomingViewController!)
            viewController.view.addSubview(upcomingViewController!.view)
            viewController.view.bringSubviewToFront(upcomingViewController!.view)
        }
        upcomingViewController!.view.alpha = 0.0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.upcomingViewController!.view.frame.origin.y = 0
            self.upcomingViewController!.view.alpha = 1
            
        })
    }

    
    static func showIncomingCall(){
        if (CallUtils.incomingViewController != nil){
            return
        }
        self.delegate?.beforeShowIncomingCall?()
        let rvc = getTopViewController()
        CallUtils.rootViewController = rvc
        let incomingCall = rvc?.storyboard?.instantiateViewControllerWithIdentifier("IncomingCall") as! IncomingCallViewController
        rvc?.presentViewController(incomingCall, animated: true, completion: nil)
        
    }
*/
    static func getTopViewController() -> UIViewController?{
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController{
            while ((topController.presentedViewController) != nil) {
                topController = topController.presentedViewController!
            }
            return topController
        }
        return nil
    }
    
    static func setBackButton(vc: UIViewController){
        if (vc.navigationItem.leftBarButtonItem?.tag == 10){
            return
        }
        var backBtn   = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        backBtn.frame = CGRectMake(0, 0, 18, 16);
        backBtn.setBackgroundImage(UIImage(named: "back_btn"), forState: UIControlState.Normal)
        backBtn.addTarget(vc, action: "back", forControlEvents: UIControlEvents.TouchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        backButton.tag = 10
        vc.navigationItem.leftBarButtonItem = backButton
    }
    
    static func setMenuButton (vc: UIViewController){
        if (vc.navigationItem.rightBarButtonItem?.tag == 10){
            return
        }
        var menuBtn   = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        menuBtn.frame = CGRectMake(0, 0, 20, 15);
        menuBtn.setBackgroundImage(UIImage(named: "menu_btn"), forState: UIControlState.Normal)
        menuBtn.addTarget(vc, action: "menu", forControlEvents: UIControlEvents.TouchUpInside)
        let menuButton = UIBarButtonItem(customView: menuBtn)
        menuButton.tag = 10
        vc.navigationItem.rightBarButtonItem = menuButton
    }
    static func getAttrText(string:String, color: UIColor, size: CGFloat) -> NSMutableAttributedString{
        return getAttrText(string, color: color, size: size, fontName: "OpenSans")
    }
    
    static func getAttrText(string:String, color: UIColor, size: CGFloat, fontName:String) -> NSMutableAttributedString{
        return getAttrText(string, color: color, size: size, fontName: fontName, addShadow: false)
    }
    
    static func getAttrText(string:String, color: UIColor, size: CGFloat, fontName:String, addShadow: Bool) -> NSMutableAttributedString{
        var str = NSMutableAttributedString(string: string)
        str.addAttribute(NSForegroundColorAttributeName,
            value: color,
            range: NSMakeRange(0,count(string)))
        str.addAttributes([NSFontAttributeName:UIFont(name: fontName, size: size )!], range:  NSMakeRange(0,count(string)) )
        if (addShadow){
            var shadow = NSShadow()
            shadow.shadowBlurRadius = 5;
            shadow.shadowColor = UIColor.whiteColor()
            shadow.shadowOffset = CGSizeMake(0, 0)
            str.addAttributes([NSShadowAttributeName:shadow], range:  NSMakeRange(0,count(string)))
        }
        return str
    }
    
    static func addCenterAttr (attrText: NSMutableAttributedString) -> NSMutableAttributedString{
        let p: NSMutableParagraphStyle = NSMutableParagraphStyle()
        p.alignment = NSTextAlignment.Center
        attrText.addAttribute(NSParagraphStyleAttributeName, value: p, range: NSMakeRange(0,count(attrText.string)))
        return attrText
    }
    
    static func addSizeConstaints (view: UIView, width: CGFloat?, height: CGFloat?) -> [NSLayoutConstraint]{
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        var widthConstraint:NSLayoutConstraint = NSLayoutConstraint()
        var hightConstraint:NSLayoutConstraint = NSLayoutConstraint()
        if let w = width {
            widthConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: w)
            view.addConstraint(widthConstraint)
        }
        if let h = height {
            hightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: h)
            view.addConstraint(hightConstraint)
        }
        return [widthConstraint, hightConstraint]
    }
    static func addConstraintsToSuper(view: UIView, superView: UIView, top: CGFloat?, left: CGFloat?, bottom: CGFloat?, right: CGFloat?){
        
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        if let t = top {
            let topConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: t)
            superView.addConstraint(topConstraint)
        }
        if let l = left {
            let leftConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: l)
            superView.addConstraint(leftConstraint)
        }
        if let b = bottom {
            let bottomConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: b)
            superView.addConstraint(bottomConstraint)
        }

        if let r = right {
            let rightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: superView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: r)
            superView.addConstraint(rightConstraint)
        }
        
    }
    
    static func showSimpleError(message: String){
        var alert = UIAlertView()
        alert.title = "Error"
        alert.message = message
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    static func addDoneToolBarToKeyboard(textView: UITextView, vc: UIViewController){
        var doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.Default
        doneToolbar.items = [UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: vc, action: "doneButtonClickedDismissKeyboard")]
        doneToolbar.sizeToFit()
        textView.inputAccessoryView = doneToolbar;
    }
    
    static func startGlobalLoader(){
        globalLoader = UIActivityIndicatorView()
        globalLoader!.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        if let topView = getTopViewController()?.view{
            topView.addSubview(globalLoader!)
            globalLoader!.startAnimating()
            topView.bringSubviewToFront(globalLoader!)
            globalLoader!.setTranslatesAutoresizingMaskIntoConstraints(false)
            let canterXConstraint = NSLayoutConstraint(item: globalLoader!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: topView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
                topView.addConstraint(canterXConstraint)
            let canterYConstraint = NSLayoutConstraint(item: globalLoader!, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: topView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            topView.addConstraint(canterYConstraint)
            
        }
        
        
    }
    
    static func stopGlobalLoader(){
        dispatch_async(dispatch_get_main_queue()){
            globalLoader?.removeFromSuperview()
        }
    }
}

extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext() as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
