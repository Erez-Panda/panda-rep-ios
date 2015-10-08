//
//  LinearInterpView.swift
//  Panda4rep
//
//  Created by Erez Haim on 5/8/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

class LinearInterpView: UIView {
    
    var path : UIBezierPath?
    var enabled = false


    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        UIColor.blackColor().setStroke()
        path?.stroke()
        // Drawing code
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.multipleTouchEnabled = false
        self.backgroundColor = UIColor.clearColor()
        path = UIBezierPath()
        path?.lineWidth = 2.0
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        if (enabled){
            if let touch: UITouch = touches.first{
                //((touch.gestureRecognizers as NSArray)[0] as! UIGestureRecognizer).cancelsTouchesInView = false
                let touchLocation = touch.locationInView(self) as CGPoint
                path?.moveToPoint(touchLocation)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        print("CANCEL")
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        if (enabled){
            if let touch: UITouch = touches.first{
                let touchLocation = touch.locationInView(self) as CGPoint
                path?.addLineToPoint(touchLocation)
                self.setNeedsDisplay()
            }
        }
    }
    
    func cleanView(){
        self.path?.removeAllPoints()
        self.setNeedsDisplay()
    }
    

}
