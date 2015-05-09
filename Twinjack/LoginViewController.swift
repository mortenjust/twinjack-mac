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
    
    
    @IBAction func twitterLogginPressed(sender: AnyObject) {
        
        loginTwitter()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
