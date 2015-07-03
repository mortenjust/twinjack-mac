//
//  PreferencesWindowController.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 6/13/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import ServiceManagement


class PreferencesWindowController: NSWindowController {
    let launchDaemon: CFStringRef = "com.mortenjust.TwinjackHelper"
    
    @IBAction func startAtLoginClicked(sender: AnyObject) {
        println("pref for start clicke")
        let ud = NSUserDefaults.standardUserDefaults()
        let enabled:Boolean = Boolean(booleanLiteral: ud.boolForKey("startAtLogin"))

        let theBundleId = "com.mortenjust.TwinjackHelper"
        if SMLoginItemSetEnabled(theBundleId as CFString, enabled) != enabled as Boolean {
            println("Yeah, turned off")
        }
    }

    override func windowDidLoad() {
        
        super.windowDidLoad()
        window?.orderFrontRegardless()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}


extension Boolean : BooleanLiteralConvertible {
    public init(booleanLiteral value: Bool) {
        self = value ? 1 : 0
    }
}
extension Boolean : BooleanType {
    public var boolValue : Bool {
        return self != 0
    }
}


