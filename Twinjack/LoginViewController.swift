//
//  LoginViewController.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/18/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SwifterMac

protocol LoginDelegate {
    func loginSuccessful()
}

class LoginViewController: NSViewController {

    var window : NSWindow!
    var swifter : Swifter!
    var social : Social!
    var delegate : LoginDelegate!
    
    @IBOutlet weak var twitterLoginButton: NSButton!
    
    func loginTwitter(){
        self.swifter.authorizeWithCallbackURL(NSURL(string: "twinjack://success")!, success: {
            credential, response in
            var tmp = self.swifter.client.credential?.accessToken
            self.social.saveUserToken(tmp!)
            println("welcome for the first time")
            
            self.delegate.loginSuccessful()
            },failure: {
                error in
                println("# login error")
                println(error)
            }
        )
    }
    
    
    func showLoader(){
        var scrimView = NSView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        scrimView.wantsLayer = true
        scrimView.layer?.backgroundColor = NSColor.whiteColor().CGColor
        scrimView.alphaValue = 0.8
        self.view.addSubview(scrimView)
        
        var loaderView = NSProgressIndicator(frame: CGRectMake((self.view.bounds.width/2)-15, (self.view.bounds.height/2)-15, 30, 30))
        loaderView.style = NSProgressIndicatorStyle.SpinningStyle
        loaderView.startAnimation(self)
        self.view.addSubview(loaderView)
    }
    
    @IBAction func twitterLogginPressed(sender: AnyObject) {
        loginTwitter()
        showLoader()
    }

    @IBAction func startAtLoginClicked(sender: AnyObject) {
        PreferencesWindowController().startAtLoginClicked(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
