//
//  AppDelegate.swift
//  TwinjackHelper
//
//  Created by Morten Just Petersen on 6/14/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
//        NSArray *pathComponents = [[[NSBundle mainBundle] bundlePath] pathComponents];
//        pathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 4)];
//        NSString *path = [NSString pathWithComponents:pathComponents];
//        [[NSWorkspace sharedWorkspace] launchApplication:path];
//        [NSApp terminate:nil];
        
        var pathComponents : NSArray = NSBundle.mainBundle().bundlePath.pathComponents
        pathComponents = pathComponents.subarrayWithRange(NSMakeRange(0, pathComponents.count - 4))
        var path : NSString = NSString.pathWithComponents(pathComponents as Array)
        println("launching \(path)")
        
//        var alert = NSAlert()
//        alert.messageText = "Launching \(path)"
//        alert.addButtonWithTitle("OK")
//        alert.runModal()
        
        NSWorkspace.sharedWorkspace().launchApplication(path as String)
        
        // TODO quit
    }

    @IBAction func copyWasSelected(sender: AnyObject) {
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

