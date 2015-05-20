//
//  LiveData.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SwifterMac


protocol LiveDataDelegate {
    func liveAudienceMemberDidArrive(audienceCount: Int)
    func liveAudienceMemberDidLeave(audienceCount: Int)
    func liveAudienceMemberDidLike(likeCount: Int)
}

class LiveData: NSObject {
    var socket : SocketIOClient!
    var delegate:LiveDataDelegate!
    
    override init(){
        super.init()
        
        //({reconnection: true, reconnectionDelay: 5000});
        socket = SocketIOClient(socketURL: "https://twinjack.azurewebsites.net", opts: ["reconnection":true, "reconnectionDelay":10])
        socket.reconnects = true
        socket.reconnectWait = 10
        
        println("Connecting to socket room...")
        socket.connect()
        
        socket.on("connect", callback: { (data, ack) -> Void in
            println("...socket room connected")
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
//            self.socket.reconnect()
        })
        
        socket.onAny { (socketEvent) -> Void in
            print("[\(socketEvent.event)]")
        }
        
        socket.on("error", callback: { (data, ack) -> Void in
            println("socket error")
            println(data)
        })
        
        socket.on("reconnectAttempt", callback: { (data, ack) -> Void in
            self.socket.connect()
        })
    }
    
    
      func startLikesObserver(dj:Dj){
        // tbd
//        socket.on('new like with count')
        socket.on("new like with count", callback: { (data, ack) -> Void in
            let likes = data?[0] as! Int
            self.delegate?.liveAudienceMemberDidLike(likes)
        })
    }
    
    func startAudienceObserver(dj:Dj){
        println("starting listener count listener")
        socket.on("listener count") { (data, emitter) -> Void in
            let count = data?[0]["listeners"] as! Int
            println("listener count changed to \(count)")
           // self.showNotification("Socket event: Listener count", moreInfo: "changed to: \(count)", sound: true)
        }
        
        socket.on("listener joined") { (data, ack) -> Void in
            let audienceCount = data?[0]["listeners"] as! Int
            self.delegate?.liveAudienceMemberDidArrive(audienceCount)
        }

        socket.on("listener left") { (data, ack) -> Void in
            let audienceCount = data?[0]["listeners"] as! Int
            self.delegate?.liveAudienceMemberDidLeave(audienceCount)
        }
    }
    
    func updateAppBadge(string:String){
        NSDockTile().showsApplicationBadge = true
        NSDockTile().badgeLabel = string

    }
    
    func disconnectSocket(){
        socket.disconnect(fast: true)
    }
    
    func hideAppBadge(){
        NSDockTile().showsApplicationBadge = false
    }
    
    func trackPaused(dj:Dj){
        socket.emit("pause song")
    }
    
    func trackStarted(track:Track, dj:Dj){
        var pars = ["artist":track.artist!, "album":track.album!, "trackName":track.name!, "position":track.position!]
        println("Emitting new song, position: \(track.position!)")
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
