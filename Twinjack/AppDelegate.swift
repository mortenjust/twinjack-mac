//
//  AppDelegate.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SwifterMac
import Alamofire

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, LoginDelegate {

    @IBOutlet weak var window: NSWindow!
    var masterViewController : MasterViewController!
    var djViewController: DjViewController!
    var loginViewController: LoginViewController!

    var user:NSDictionary!
    var swifter = Swifter(consumerKey: "TuhRXTbnWzOHwjpLvEnQ0jFtH", consumerSecret: "sxvfBXkF0Hr3pSdDpOBLmV9HxvMtBqqY9xByBx0QJjVdWEPPCY")
    var social = Social()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        window.movableByWindowBackground = true
        window.delegate = self
        window.titleVisibility = NSWindowTitleVisibility.Hidden
        window.titlebarAppearsTransparent = true;
        window.styleMask |= NSFullSizeContentViewWindowMask;
        
        dispatchLogin()
    
        
        // twitter callback prep stuff
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: Selector("handleEvent:withReplyEvent:"), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        LSSetDefaultHandlerForURLScheme("swifter", NSBundle.mainBundle().bundleIdentifier! as NSString as CFString)
    }
    
    
    func dispatchLogin(){
        println("Chcking for token:")
        if social.fetchUserToken() != nil {
            self.swifter.client.credential = social.fetchUserToken()
            user = self.social.fetchUserQData()
            let tokenKey = self.swifter.client.credential?.accessToken?.key
            let tokenSecret = self.swifter.client.credential?.accessToken?.secret
            let pars = ["key": tokenKey!, "secret":tokenSecret!]
            let userId = user["userID"] as! String
            let screenName = user["screenName"] as! String
            println("welcome back")
            self.enterDjBooth()
        } else {
            println("who are you")
            showLoginView()
        }
}

    
    func showLoginView(){
        // change window size accordingly

        let f = window.frame
        let newFrame = CGRectMake(f.origin.x, f.origin.y, 270, 380)
        window.setFrame(newFrame, display:true, animate:true)
        
        loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginViewController.window = window
        loginViewController.swifter = swifter
        loginViewController.social = social
        loginViewController.delegate = self
        window.contentView.addSubview(loginViewController.view)
        loginViewController.view.frame = self.window.contentView.bounds
    }
    

    func loginSuccessful() { // LoginDelegate func
        dispatchLogin()
    }
    
    func enterDjBooth(){
        let f = window.frame
        let newFrame = CGRectMake(f.origin.x, f.origin.y, 226, 372)
        window.setFrame(newFrame, display:true, animate:true)
        self.djViewController = DjViewController(nibName: "DjViewController", bundle: nil)
        self.djViewController.window = window
        self.djViewController.swifter = swifter
        self.djViewController.dj = Dj(name: user["screenName"] as! String)
        self.window.contentView.addSubview(self.djViewController.view)
        self.djViewController.view.frame = self.window.contentView.bounds
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application

        if djViewController != nil {
            self.djViewController.pausedTrack()
        }

    }
    
    func handleEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        // twitter callback stuff
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        Swifter.handleOpenURL(NSURL(string: event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))!.stringValue!)!)

    }

}

