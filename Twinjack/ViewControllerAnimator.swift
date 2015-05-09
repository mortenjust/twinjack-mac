//
//  ViewControllerAnimator.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/16/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

class ViewControllerAnimator: NSObject, NSViewControllerPresentationAnimator {
    
    func animatePresentationOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
        
        let bottomVC = fromViewController
        let topVC = viewController
        
        // make sure the view has a CA layer for smooth animation
        topVC.view.wantsLayer = true
        
        // set redraw policy
        topVC.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay
        
        // start out invisible
        topVC.view.alphaValue = 0
        
        // add view of presented viewcontroller
        bottomVC.view.addSubview(topVC.view)
        
        // adjust size
        topVC.view.frame = bottomVC.view.frame
        
        
        // Do some CoreAnimation stuff to present view
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            
            // fade duration
            context.duration = 2
            // animate to alpha 1
            topVC.view.animator().alphaValue = 1
            
            }, completionHandler: nil)
        
    }
    
    func animateDismissalOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
        
        let bottomVC = fromViewController
        let topVC = viewController
        
        // make sure the view has a CA layer for smooth animation
        topVC.view.wantsLayer = true
        
        // set redraw policy
        topVC.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay
        
        // Do some CoreAnimation stuff to present view
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            
            // fade duration
            context.duration = 2
            // animate view to alpha 0
            
            println("this is the animator removing the old view")
            
//            topVC.view.animator().frame.size = CGSize(width: 0, height: 0)
            topVC.view.animator().alphaValue = 0
            topVC.view.animator().hidden = true
            
            }, completionHandler: {
                
                // remove view
                topVC.view.removeFromSuperview()
        })
        
    }
}