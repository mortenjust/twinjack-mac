//
//  LiveData.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SwifterMac
import Alamofire

protocol LiveDataDelegate {
    func liveAudienceMemberDidArrive()
    func liveAudienceMemberDidLeave()
    func liveAudienceMemberDidLike()
}

class LiveData: NSObject {
    var socket : SocketIOClient!
    var delegate:LiveDataDelegate!
    
    override init(){
        super.init()
        
        println("instantiating socket")
        socket = SocketIOClient(socketURL: "https://twinjack.com")
        socket.connect()
        
        socket.on("connect", callback: { (data, ack) -> Void in
            println("socket connected")
            self.socket.emit("join", ["room":"mortenjust"])
            println("joined socket room")
            
            let ud = NSUserDefaults.standardUserDefaults()
            let key = ud.stringForKey("key")!
            let secret = ud.stringForKey("secret")!
            let authPars = ["key":key, "secret":secret]
            self.socket.emit("auth", authPars)
            
        })

    }
    
    
      func startLikesObserver(dj:Dj){

        // tbd
    }
    
    func startAudienceObserver(dj:Dj){
        println("starting listener count listener")
        socket.on("listener count") { (data, emitter) -> Void in
            let count = data?[0]["listeners"] as! Int
            println("listener count changed to \(count)")
            self.showNotification("Socket event: Listener count", moreInfo: "changed to: \(count)", sound: true)
        }
        
        socket.on("listener joined") { (data, ack) -> Void in
            self.delegate?.liveAudienceMemberDidArrive()
        }

        socket.on("listener left") { (data, ack) -> Void in
            self.delegate?.liveAudienceMemberDidLeave()
        }
        
    }
    
    func updateAppBadge(string:String){
        NSDockTile().showsApplicationBadge = true
        NSDockTile().badgeLabel = string

    }
    
    func hideAppBadge(){
        NSDockTile().showsApplicationBadge = false
    }
    
    
    func trackPaused(dj:Dj){
        socket.emit("paused")
    }
    
    func trackStarted(track:Track, dj:Dj){
        
        var pars = ["artist":track.artist!, "album":track.album!, "trackName":track.name!]
        
        println("Telling twinjack")
        socket.emit("new song", pars)
        
    }
    
    
    func updateProfileInfo(swifter:Swifter, dj:Dj){
//        swifter.getAccountVerifyCredentials(includeEntities: true, skipStatus: true, success: { (myInfo: Dictionary<String, JSONValue>?) -> Void in
//            
//            let profileImageUrl = myInfo!["profile_image_url"]!.string!
//            let location = myInfo!["location"]!.string!
//            let followers = myInfo!["followers_count"]!.integer!
//            let name = myInfo!["name"]!.string!
//            let utcOffset = myInfo!["utc_offset"]!.integer!
//            let timeZone = myInfo!["time_zone"]!.string!
//            
//
//            }) { (error) -> Void in
//                println("# error trying to update")
//                println(error)
//        }
    }
    
    func showNotification(title:String, moreInfo:String, sound:Bool=true) -> Void {
        var unc = NSUserNotificationCenter.defaultUserNotificationCenter()
//        unc.delegate=self
        
        var notification = NSUserNotification()
        notification.title = title
        notification.informativeText = moreInfo
        if sound == true {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        unc.deliverNotification(notification)

    }
    
    func authFirebase(){
        
    
    }
}
