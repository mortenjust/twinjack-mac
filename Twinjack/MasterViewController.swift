//
//  MasterViewController.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SwifterMac

class MasterViewController: NSViewController, NeedSocialDelegate {
    
    @IBOutlet weak var window: NSWindow!
    var liveData = LiveData()
    var dj : Dj!
    
    func needSocialDidAddService() { // delegate
        setup()
    }

    func setup(){
        self.view.wantsLayer = true
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.movableByWindowBackground = true
        self.view.window?.titleVisibility = NSWindowTitleVisibility.Hidden
        // dispatch
        
    }
    
    override func viewDidAppear() {
//    NSTimer.scheduledTimerWithTimeInterval(2.2, target: self, selector: "setup", userInfo: nil, repeats: false)
       setup()
    }
    
    
    func presentLogin(){
        
    }
    
    func presentDjWithName(djName:String){
        
        let dj = Dj(name: djName)
        var djViewController = DjViewController(nibName: "DjViewController", bundle: nil)
        var animator = ViewControllerAnimator()
        djViewController?.dj = dj
        djViewController?.liveData = liveData
        self.presentViewController(djViewController!, animator:animator)

    }

    override func awakeFromNib() {
        super.awakeFromNib()
     // setup()
    }
    
}
