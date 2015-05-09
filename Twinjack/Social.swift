//
//  Social.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/16/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import Social
import Accounts
import SwifterMac

class Social {

    
    init(){

    }
    
    
    func authTwitterREMOVE(){ // TODO: handle retun
        let failureHandler: ((NSError) -> Void) = {
            error in
            
            println(error.localizedDescription)
        }
        
        let swifter = Swifter(consumerKey: "TuhRXTbnWzOHwjpLvEnQ0jFtH", consumerSecret: "sxvfBXkF0Hr3pSdDpOBLmV9HxvMtBqqY9xByBx0QJjVdWEPPCY")
        
        swifter.authorizeWithCallbackURL(NSURL(string: "twinjack://success")!, success: {
            accessToken, response in
            
            self.saveUserToken(accessToken!)
            
            println("Successfully authorized")
        
            }, failure: failureHandler)
    }
    
    // token helpers
    func saveUserToken(data: SwifterCredential.OAuthAccessToken) -> Bool {
        
        var userdata = NSUserDefaults.standardUserDefaults()
        userdata.setObject(data.key, forKey: "key")
        userdata.setObject(data.secret, forKey: "secret")
        userdata.setObject(data.screenName, forKey: "screenName")
        userdata.setObject(data.userID, forKey: "userID")
        userdata.setObject(data.verifier, forKey: "verifier")
        userdata.synchronize()
        return true
    }
    
    
    func fetchUserToken() -> SwifterCredential? {
        var userdata = NSUserDefaults.standardUserDefaults()
        
        if var tkey = userdata.objectForKey("key") as? String {
            if var tsecret = userdata.objectForKey("secret") as? String {
                var access = SwifterCredential.OAuthAccessToken(key: tkey , secret: tsecret)
                return SwifterCredential(accessToken: access)
            }
        }
        return nil
    }
    
    
    func fetchUserQData() -> NSDictionary {
        var userdata = NSUserDefaults.standardUserDefaults()
        var data: NSMutableDictionary = NSMutableDictionary()
        data["screenName"] = userdata.objectForKey("screenName") as! String?
        data["userID"] = userdata.objectForKey("userID") as! String?
        return data
    }
    
    
}

