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

    
    var user:NSDictionary!
    var swifter = Swifter(consumerKey: "TuhRXTbnWzOHwjpLvEnQ0jFtH", consumerSecret: "sxvfBXkF0Hr3pSdDpOBLmV9HxvMtBqqY9xByBx0QJjVdWEPPCY")
    var social = Social()

    @IBOutlet weak var statusItemMenu: NSMenu!
    
    var statusItem : NSStatusItem!

    @IBAction func showWasSelected(sender: AnyObject) {
//        window.orderFront(self)
        window.orderFront(self)
        window.makeKeyWindow()
        window.orderFrontRegardless()
    }
    
    @IBAction func quitWasSelected(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        statusItem.menu = statusItemMenu
        statusItem.image = NSImage(named: "twinjackstatus")
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
        
        showWasSelected(self)
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
    
    func applicationIsInStartUpItems() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        var itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
                ).takeRetainedValue() as LSSharedFileListRef?
            if loginItemsRef != nil {
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                println("There are \(loginItems.count) login items")
                let lastItemRef: LSSharedFileListItemRef = loginItems.lastObject as! LSSharedFileListItemRef
                for var i = 0; i < loginItems.count; ++i {
                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as! LSSharedFileListItemRef
                    if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                        if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {
                            println("URL Ref: \(urlRef.lastPathComponent)")
                            if urlRef.isEqual(appUrl) {
                                return (currentItemRef, lastItemRef)
                            }
                        }
                    } else {
                        println("Unknown login application")
                    }
                }
                //The application was not found in the startup list
                return (nil, lastItemRef)
            }
        }
        return (nil, nil)
    }
    
    func toggleLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        let shouldBeToggled = (itemReferences.existingReference == nil)
        let loginItemsRef = LSSharedFileListCreate(
            nil,
            kLSSharedFileListSessionLoginItems.takeRetainedValue(),
            nil
            ).takeRetainedValue() as LSSharedFileListRef?
        if loginItemsRef != nil {
            if shouldBeToggled {
                if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                    LSSharedFileListInsertItemURL(
                        loginItemsRef,
                        itemReferences.lastReference,
                        nil,
                        nil,
                        appUrl,
                        nil,
                        nil
                    )
                    println("Application was added to login items")
                }
            } else {
                if let itemRef = itemReferences.existingReference {
                    LSSharedFileListItemRemove(loginItemsRef,itemRef);
                    println("Application was removed from login items")
                }
            }
        }
    }

}

