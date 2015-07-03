//: Playground - noun: a place where people can play

import Cocoa

let leg = false

let enabl = leg == true ? 1 : 0

let audienceCount = "1"

let listeners : String = audienceCount == "1" ? "listener" : "listeners"

var name = "Beats 1"
var display = "Artist Name - Track Name"

NSString(string: name).containsString("Beats")
var artist = display.componentsSeparatedByString(" - ")[0]
var track = display.componentsSeparatedByString(" - ")[1]