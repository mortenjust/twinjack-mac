//
//  DjViewController.swift
//  Twinjack
//
//  Created by Morten Just Petersen on 4/16/15.
//  Copyright (c) 2015 Morten Just Petersen. All rights reserved.
//

import Cocoa
import SwifterMac

class DjViewController: NSViewController, LiveDataDelegate, TrackDelegate {
    var centerReceiver = NSDistributedNotificationCenter()
    var liveData : LiveData! 
    var swifter : Swifter!
    var audienceCount:Int = 0 {
        didSet {
            if audienceCount == 0 {
                listenersLabel.stringValue = ""
                likesLabel.stringValue = ""
            }
        }
    }
    var dj : Dj!
    
    @IBOutlet weak var blurV: NSVisualEffectView!
    
    @IBOutlet weak var artistLabel: NSTextField!
    @IBOutlet weak var trackLabel: NSTextField!
    @IBOutlet weak var urlField: NSTextField!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var tweetButton: NSButton!
    @IBOutlet weak var listenersLabel: NSTextField!
    @IBOutlet weak var likesLabel: NSTextField!
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var onAirLabel: NSTextField!
    
    @IBOutlet weak var userImage: NSImageView!
    @IBOutlet weak var likeImage: NSImageView!
    
    @IBOutlet weak var bottomAlbumImage: NSImageView!
    @IBOutlet weak var albumImage: NSImageView!
    @IBOutlet weak var lowerScrimView: NSImageView!
    
    var trackGotCheers = false
    

    
    override func awakeFromNib() {
//        playCheers()
        setup()
    }
    
    @IBAction func urlFieldAction(sender: NSTextField) {
    }

    @IBAction func tweetPressed(sender: AnyObject) {
    }
    
    @IBAction func copyPressed(sender: AnyObject) {
        var pb = NSPasteboard.generalPasteboard()
        pb.clearContents()
        pb.setString("http://\(urlField.stringValue)", forType: NSStringPboardType)
        println("copied")
    }
    
    func setup(){
        clearTrackData()
        startSpotifyObserver()
        populateUrlField()
        liveData.delegate = self
        startAudienceObserver()
        startLikesObserver()
        wakeSpotify()
        lowerScrimView.wantsLayer = true
        lowerScrimView.alphaValue = 0.8

    }
    
    func wakeSpotify(){
        let source = "tell application \"Spotify\"\nplaypause\nplaypause\nend tell"
        var script = NSAppleScript(source: source)
        script?.executeAndReturnError(nil)
    }

    override func viewWillAppear() {
    
    }
    
    func populateUrlField(){
        urlField.stringValue = "twinjack.com/\(dj.name)"
    }
    
    func startLikesObserver(){
        liveData.startLikesObserver(dj)
    }
    
    func startAudienceObserver(){
        liveData.startAudienceObserver(dj)
    }
    
    func pluralS(count:Int) -> String {
        if count == 1 { return "" } else {  return "s" }
    }
  
    func playCheers(){
        println("Cheers")
        trackGotCheers = true
        let cheersPath = NSBundle.mainBundle().pathForResource("cheers", ofType: "wav")
        var sound = NSSound(contentsOfFile: cheersPath!, byReference: false)
        sound?.play()
    }
    
    func checkForCheers(likes:Int, audienceCount:Int){
        if likes > (audienceCount/2) {
            self.playCheers()
        }
    }
    
    func liveAudienceMemberDidLike() {
        likesLabel.integerValue++
        checkForCheers(likesLabel.integerValue, audienceCount: audienceCount)
        liveData.showNotification("Someone likes this track!", moreInfo: "\(likesLabel.integerValue) total like\(pluralS(likesLabel.integerValue)) for this track")
    }

    func liveAudienceMemberDidArrive() {
        audienceCount++
        userImage.hidden = false
        listenersLabel.hidden = false
        listenersLabel.integerValue = audienceCount
        liveData.showNotification("A listener just joined", moreInfo: "You have \(audienceCount) listener\(pluralS(audienceCount))", sound: false)
        liveData.updateAppBadge("\(audienceCount)")
    }
    
    func liveAudienceMemberDidLeave() {
        audienceCount--
        listenersLabel.integerValue = audienceCount
        liveData.updateAppBadge("\(audienceCount)")
        if audienceCount == 0 {
//            listenersLabel.hidden = true
//            userImage.hidden = true
            liveData.updateAppBadge("")
            liveData.hideAppBadge()
        }
    }
    
    func startSpotifyObserver(){
        let spotifyObserver = self.centerReceiver.addObserverForName("com.spotify.client.PlaybackStateChanged", object: nil, queue: nil) { (note) -> Void in
            
            let info = note.userInfo!
            let state = info["Player State"] as! String
            
            switch state{
            case "Paused":
                self.pausedTrack()
            case "Playing":
                var track = Track(info: info)
                track.delegate = self
                self.startedTrack(track)
            default:
                println("Not playing or paused")
            }
        }
    }

    func pausedTrack(){
        println("Pause")
        clearTrackData()
        liveData.trackPaused(dj)
        albumImage.image = NSImage(named:"albumPlaceholder")
    }
    
    func trackAlbumImageDidChange(image: NSImage) {
//        http://www.objc.io/issue-14/appkit-for-uikit-developers.html
//        let oldImage = albumImage.image
//        let oldImageView = NSImageView()
//
//        oldImageView.image = oldImage
//        albumImage.frame.origin.x = 300
//        
//        view.addSubview(oldImageView)
//        
//        NSAnimationContext.runAnimationGroup({ (context) -> Void in
//                context.duration = 1
//                oldImage.frame.orgin.x = -300
//                albumImage.frame.orgin.x = 0
//            
//            //
//        }, completionHandler: { () -> Void in
//            //
//            oldImage.removeFromSuperiew()
//        })
        albumImage.image = image
        bottomAlbumImage.image = image
    }
    
    func startedTrack(track:Track){
        albumImage.image = NSImage(named:"noAlbum")
        trackGotCheers = false
        onAirLabel.stringValue = "Streaming from Spotify on"
        artistLabel.stringValue = track.artist!
        trackLabel.stringValue = track.name!
        likesLabel.integerValue = 0
        
        println("Play \(track.name!)")
        liveData.trackStarted(track,
                              dj:self.dj)
    }
    
    func clearTrackData(){
        artistLabel.stringValue = ""
        trackLabel.stringValue = ""
        
        albumImage.image = NSImage(named:"albumPlaceholder")
        bottomAlbumImage.image = albumImage.image
        
        onAirLabel.stringValue = "Press Play in Spotify"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
