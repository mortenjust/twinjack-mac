//
//  AppDelegate.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SwifterMac

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, LoginDelegate {

    @IBOutlet weak var window: NSWindow!
//    var masterViewController : MasterViewController! // looks like we're not using this
    var djViewController: DjViewController!
    var loginViewController: LoginViewController!
    var preferencesWindowController: PreferencesWindowController!
    
    @IBOutlet weak var listenerCountLabel: NSMenuItem!
    
    var user:NSDictionary!
    var swifter = Swifter(consumerKey: "TuhRXTbnWzOHwjpLvEnQ0jFtH", consumerSecret: "sxvfBXkF0Hr3pSdDpOBLmV9HxvMtBqqY9xByBx0QJjVdWEPPCY")
    var social = Social()

    
    @IBOutlet weak var statusItemMenu: NSMenu!
    var statusItem : NSStatusItem!
    @IBOutlet weak var listenerCount: NSMenuItem!

    @IBAction func showWasSelected(sender: AnyObject) {
//        window.orderFront(self)
        window.orderFront(self)
        window.makeKeyWindow()
        window.orderFrontRegardless()
    }
    
    
    
    
    @IBAction func preferencesWasSelected(sender: AnyObject) {
        preferencesWindowController = PreferencesWindowController(windowNibName: "PreferencesWindowController")
        preferencesWindowController.showWindow(sender)

    }
    
    
    
    
    
    @IBAction func quitWasSelected(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        statusItem.menu = statusItemMenu
        statusItem.image = NSImage(named: "twinjackstatus")
        statusItem.alternateImage = NSImage(named: "twinjackstatus-alternate")
        statusItem.action = Selector("showWasSelected:")
        
        window.movableByWindowBackground = true
        window.delegate = self
        window.titleVisibility = NSWindowTitleVisibility.Hidden
        window.titlebarAppearsTransparent = true;
        window.styleMask |= NSFullSizeContentViewWindowMask;
        
        dispatchLogin()

        // twitter callback prep stuff
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: Selector("handleEvent:withReplyEvent:"), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        LSSetDefaultHandlerForURLScheme("swifter", NSBundle.mainBundle().bundleIdentifier! as NSString as CFString)
        
        checkForPreferences()
        checkIfFirstRun()
        showWasSelected(self)
        
        startAudienceObserver()
    }
    
    func startAudienceObserver(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audienceCountChanged:", name: "audienceEvent", object: nil)
    }

    func audienceCountChanged(notification:NSNotification){
        let u = notification.userInfo as! Dictionary<String,String>
        
        if let audienceCount = u["audienceCount"] {
            println("now \(audienceCount)")
            let listeners : String = audienceCount == "1" ? "listener" : "listeners"
            listenerCountLabel.title = "\(audienceCount) \(listeners)"
            
            if audienceCount == "0" {
                self.statusItem.image = NSImage(named: "twinjackstatus")
            } else {
                self.statusItem.image = NSImage(named: "twinjackstatus-listeners")
                }
            }
    }
    
    func checkIfFirstRun(){
        var ud = NSUserDefaults.standardUserDefaults()
        var notFirstTime = ud.boolForKey("notFirstTime")
        if !notFirstTime {
            preferencesWasSelected(self)
            ud.setBool(true, forKey: "notFirstTime")
        }
    }
    
    func checkForPreferences(){
        var ud = NSUserDefaults.standardUserDefaults()

        var startAtLogin = true
        if ud.objectForKey("startAtLogin") == nil {
            println("that was not set")
            ud.setBool(true, forKey: "startAtLogin")
            preferencesWindowController.startAtLoginClicked(self)
        } else {
            startAtLogin = ud.boolForKey("startAtLogin")
            println("startup at login is \(startAtLogin)")
        }
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
        let liveData = LiveData()
        self.djViewController = DjViewController(nibName: "DjViewController", bundle: nil)
        self.djViewController.liveData = liveData
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
    
//    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
//        return false
//    }
    
    func handleEvent(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        // twitter callback stuff
        
        window.makeKeyAndOrderFront(window)
        Swifter.handleOpenURL(NSURL(string: event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))!.stringValue!)!)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    
    
    @IBAction func copyWasSelected(sender: AnyObject) {
        djViewController.copyPressed(self)
    }
    

}

