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
        
        //({reconnection: true, reconnectionDelay: 5000});
        socket = SocketIOClient(socketURL: "https://twinjack.com", opts: ["reconnection":true, "reconnectionDelay":5000])
        
        socket.connect()
        
        socket.on("connect", callback: { (data, ack) -> Void in
            println("socket connected")
            println("joined socket room")
            
            let ud = NSUserDefaults.standardUserDefaults()
            let key = ud.stringForKey("key")!
            let secret = ud.stringForKey("secret")!
            let authPars = ["key":key, "secret":secret]
            self.socket.emit("auth", authPars)
            let screenName = ud.stringForKey("screenName")!
            self.socket.emit("join", ["room":screenName])
        })
        
        socket.on("disconnect", callback: { (data, ack) -> Void in
            println("## Socket disconnected.")
            println(data)
            println("Reconnecting")
            self.socket.reconnect()
        })
        
        socket.onAny { (socketEvent) -> Void in
            print("[\(socketEvent.event)]")
        }
        
        socket.on("error", callback: { (data, ack) -> Void in
            println("socket error")
            println(data)
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
        socket.emit("pause song")
    }
    
    func trackStarted(track:Track, dj:Dj){
        var pars = ["artist":track.artist!, "album":track.album!, "trackName":track.name!]
        println("Telling twinjack")
        socket.emit("new song", pars)
    }
    
    func showNotification(title:String, moreInfo:String, sound:Bool=true) -> Void {
        var unc = NSUserNotificationCenter.defaultUserNotificationCenter()
        var notification = NSUserNotification()
        notification.title = title
        notification.informativeText = moreInfo
        if sound == true {
            notification.soundName = NSUserNotificationDefaultSoundName
        }
        unc.deliverNotification(notification)
    }
}
