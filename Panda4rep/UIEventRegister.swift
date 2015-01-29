//
//  UIEventRegister.swift
//  Panda4rep
//
//  Created by Erez on 1/4/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

struct UIEventRegister {
    
    static func gestureRecognizer(sender: UIViewController, rightAction: Selector, leftAction: Selector, upAction: Selector, downAction: Selector) -> Void{
        if rightAction != "" {
            var swipeRight = UISwipeGestureRecognizer(target: sender, action: rightAction)
            swipeRight.direction = UISwipeGestureRecognizerDirection.Right
            sender.view.addGestureRecognizer(swipeRight)
        }
        if leftAction != "" {
            var swipeLeft = UISwipeGestureRecognizer(target: sender, action: leftAction)
            swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
            sender.view.addGestureRecognizer(swipeLeft)
        }
        if upAction != "" {
            var swipeUp = UISwipeGestureRecognizer(target: sender, action: upAction)
            swipeUp.direction = UISwipeGestureRecognizerDirection.Up
            sender.view.addGestureRecognizer(swipeUp)
        }
        if downAction != "" {
            var swipeDown = UISwipeGestureRecognizer(target: sender, action: downAction)
            swipeDown.direction = UISwipeGestureRecognizerDirection.Down
            sender.view.addGestureRecognizer(swipeDown)
        }

    }
}

