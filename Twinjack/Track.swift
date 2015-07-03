//
//  Track.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/15/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//
//[Player State: Playing, Name: Courage, Track ID: spotify:track:1GbeXiLxO6oRxoItWT3R0S, Disc Number: 1, Has Artwork: 1, Play Count: 2, Popularity: 55, Album: Courage, Duration: 286, Artist: Villagers, Album Artist: Villagers, Playback Position: 46985, Track Number: 1]

import Cocoa
import Alamofire
import SwifterMac
import SwiftyJay

protocol TrackDelegate {
    func trackAlbumImageDidChange(image:NSImage)
}

enum MusicPlayer { case Spotify, Itunes }

class Track: NSObject {
    var name:String?
    var albumImage:NSImage?
    var duration:Int?
    var delegate:TrackDelegate!
    var playCount:Int?
    var album:String?
    var artist:String?
    var position:Int?
    var popularity:Int?
    var uri:String?
    var player: MusicPlayer?
    
    
    func getAlbumImageForSearchTerm(term:String, callback:(image:NSImage)->Void){
        let urlEncodedTerm = term.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
        var url = "https://itunes.apple.com/search?term=\(urlEncodedTerm!)"
//        var url = "https://itunes.apple.com/search?term=Commas%20Future"
        
        
        Alamofire.request(.GET, url, parameters: nil).response {(req, res, json, error) in
            if error != nil {
                println("##### Trying to get album image from itunes, but got this error")
                println(error?.debugDescription)
            }
            var subJson = SwiftyJay.JSON(data:json! as! NSData)
            
            if var albumImageUrl = subJson["results"][0]["artworkUrl100"].string {
                
                let biggerAlbumUrl = albumImageUrl.stringByReplacingOccurrencesOfString("100x100", withString: "500x500")
                
                println(biggerAlbumUrl)
                
                Alamofire.request(.GET, biggerAlbumUrl, parameters:nil).response { (req, res, data, error) in
                    if let albumImage = NSImage(data: data! as! NSData) {
                        // Mark:Callback
                        callback(image: albumImage)
                    }
                }
            }
        } // afire
    }
    
    func getAlbumImageForUri(uri:String, callback:(image:NSImage)->Void){
        //https://api.spotify.com/v1/tracks/7BI3sWF1edzH4iyK0xbZ7l
        // spotify:track:4MKnxBEr4kpeSw7jX48I3M
        var trackId = self.uri?.stringByReplacingOccurrencesOfString("spotify:track:", withString: "")
        var url = "https://api.spotify.com/v1/tracks/\(trackId!)"
        
        Alamofire.request(.GET, url, parameters: nil).response { (req, res, json, error) in
            if error != nil {
                println("##### Trying to get album image from spotify, but got this error")
                println(error?.debugDescription)            
            }
            var subJson = SwiftyJay.JSON(data:json! as! NSData)
            if var albumImageUrl = subJson["album"]["images"][0]["url"].string {
                Alamofire.request(.GET, albumImageUrl, parameters:nil).response { (req, res, data, error) in
                    if let albumImage = NSImage(data: data! as! NSData) {
                    // Mark:Callback
                        callback(image: albumImage)
                        }
                }
            }
        } // alamo
    }
    
    init(spotifyInfo info:[NSObject : AnyObject]){
        super.init()
        
        player = .Spotify
        name = info["Name"] as? String
        popularity = info["Popularity"] as? Int
        album = info["Album"] as? String
        artist = info["Artist"] as? String
        position = info["Playback Position"] as? Int
        duration = info["Duration"] as? Int
        popularity = info["Popularity"] as? Int
        uri = info["Track ID"] as? String
        self.getAlbumImageForUri(uri!, callback: { (image) -> Void in
            self.delegate!.trackAlbumImageDidChange(image)
        })
    }
    
    init(iTunesInfo info:[NSObject : AnyObject]){
        super.init()
        player = .Itunes
        name = info["Name"] as? String
        let isBeats = NSString(string: name!).containsString("Beats")
        
        if isBeats {
            println("Can't handle Beats yet")
        } else {
            album = info["Album"] as? String
            artist = info["Artist"] as? String
            position = 0
            self.getAlbumImageForSearchTerm("\(name!) \(artist!)", callback: { (image) -> Void in
                self.delegate!.trackAlbumImageDidChange(image)
            })
        }
    }
    
}
