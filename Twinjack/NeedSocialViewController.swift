//
//  NeedSocialViewController.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/16/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SwifterMac


protocol NeedSocialDelegate {
    func needSocialDidAddService()
}

class NeedSocialViewController: NSViewController {

    @IBOutlet weak var addTwitterButton: NSButton!

    var didPressButton = false
    var delegate : NeedSocialDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func openTwitterPrefs(){
// TODO: USe the scripting bridge
        
//        SystemPreferencesApplication *systemPreferences = [SBApplication applicationWithBundleIdentifier:@"com.apple.systempreferences"];
//        SystemPreferencesPane *pane = (SystemPreferencesPane *) [[systemPreferences panes] objectWithID:@"com.apple.preferences.internetaccounts"];
//        SystemPreferencesAnchor *anchor = (SystemPreferencesAnchor *) [[pane anchors] objectWithName:@"com.apple.twitter.iaplugin"];
//        [systemPreferences activate];
//        systemPreferences.currentPane = pane;
//        [anchor reveal]
        
//        
//        let scriptPath = NSBundle.mainBundle().pathForResource("openTwitterPrefs", ofType: "scpt")
//        let scriptUrl = NSURL(fileURLWithPath: scriptPath!)
//        var nsa = NSAppleScript(contentsOfURL: scriptUrl!, error: nil)
//        nsa!.executeAndReturnError(nil)
        
//        let settings = [
//            "client_id": "my_swift_app",
//            "client_secret": "C7447242-A0CF-47C5-BAC7-B38BA91970A9",
//            "authorize_uri": "https://authorize.smartplatforms.org/authorize",
//            "token_uri": "https://authorize.smartplatforms.org/token",
//            "scope": "profile email",
//            "redirect_uris": ["myapp://oauth/callback"],   // don't forget to register this scheme
//            ] as OAuth2JSON      // the "as" part may or may not be needed
//        
//        let oauth = OAuth2CodeGrant(settings: settings)
//        oauth.viewTitle = "My Service"      // optional
//        oauth.onAuthorize = { parameters in
//            println("Did authorize with parameters: \(parameters)")
//        }
//        oauth.onFailure = { error in        // `error` is nil on cancel
//            if nil != error {
//                println("Authorization went wrong: \(error!.localizedDescription)")
//            }
//        }
        
        
        
        
    }
    
    @IBAction func addTwitterPressed(sender: AnyObject) {
        if !didPressButton {
            openTwitterPrefs()
            
            addTwitterButton.title = "OK, I added it!"
            self.didPressButton = true
        } else {
            // go back to master
            delegate.needSocialDidAddService()
            self.dismissController(nil)
        }
    }
}
