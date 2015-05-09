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
        socket.on("connect", callback: { (data, ack) -> Void in
            println("socket connected")
            self.socket.emit("join", ["room":"mortenjust"])
            println("joined socket room")
        })

    }
    
    
      func startLikesObserver(dj:Dj){
//        var djRef = Firebase(url:"https://streamjockey.firebaseio.com/channels/\(dj.name)/nowPlaying/likes")
//        djRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) -> Void in
//            self.delegate?.liveAudienceMemberDidLike()
//        })
    }
    
    func startAudienceObserver(dj:Dj){
//        var djRef = Firebase(url:"https://streamjockey.firebaseio.com/channels/\(dj.name)/listeners/")
//        djRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) -> Void in
//            self.delegate?.liveAudienceMemberDidArrive()
//        })
//        djRef.observeEventType(FEventType.ChildRemoved, withBlock: { (snapshot) -> Void in
//            self.delegate?.liveAudienceMemberDidLeave()
//        })
        
        println("starting listener count listener")
        socket.on("listener count") { (array, emitter) -> Void in
            println("listener count changed")
            println(array)
            self.delegate?.liveAudienceMemberDidArrive()
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
//        var djRef = Firebase(url:"https://streamjockey.firebaseio.com/channels/\(dj.name)")
//        let data = ["isLive":false, "nowPlaying":""]
//        djRef.updateChildValues(data)
        


    }
    
    func trackStarted(track:Track, dj:Dj){
        var pars = ["key": "7173-cjFFSmO7rYTkQ4PobXtKuPilgzH6p6zJ6LfCaGYv1UYMA", "secret":"ncv5pxYAXmmd5hRIwPjNqugJ8BBDWD45SxxsY6VbR5adm", "artist":track.artist!, "album":track.album!, "trackName":track.name!]

        println("Telling twinjack")
        Alamofire.request(Alamofire.Method.POST, "https://twinjack.com/new-song", parameters: pars).responseString { (res, urlres, string, error) -> Void in
            
            if string != nil {
                println("Twinjack says: '\(string!)' ")
                }

            if error != nil {
                println("Twinjack error: '\(error)' ")
            }
        }


        
//
//        var djRef = Firebase(url:"https://streamjockey.firebaseio.com/channels/\(dj.name)")
//
//        let data = ["isLive" : true, "nowPlaying" : ["artist":track.artist!,
//            "trackName":track.name!,
//            "album":track.album!,
//            "duration":track.duration!,
//            "popularity":track.popularity!,
//            "position":track.position!,
//            "uri":track.uri!,
//            "timePressedPlay":NSDate.timeIntervalSinceReferenceDate()]]
//        
//        djRef.updateChildValues(data)
    }
    
    
    func updateProfileInfo(swifter:Swifter, dj:Dj){
        swifter.getAccountVerifyCredentials(includeEntities: true, skipStatus: true, success: { (myInfo: Dictionary<String, JSONValue>?) -> Void in
            
            let profileImageUrl = myInfo!["profile_image_url"]!.string!
            let location = myInfo!["location"]!.string!
            let followers = myInfo!["followers_count"]!.integer!
            let name = myInfo!["name"]!.string!
            let utcOffset = myInfo!["utc_offset"]!.integer!
            let timeZone = myInfo!["time_zone"]!.string!
            
//            var djRef = Firebase(url:"https://streamjockey.firebaseio.com/djs/\(dj.name)/")
//            let data:NSDictionary = [
//                "uid":dj.name,
//                "profile":[
//                    "profileImageUrl":profileImageUrl,
//                    "location":location,
//                    "followers":followers,
//                    "name":name,
//                    "utcOffset":utcOffset,
//                    "timeZone":timeZone]]
//            djRef.setValue(data)
            
            }) { (error) -> Void in
                println("# error trying to update")
                println(error)
        }
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
