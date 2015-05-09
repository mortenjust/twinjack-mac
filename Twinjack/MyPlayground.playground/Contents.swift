//: Playground - noun: a place where people can play

import Cocoa


class T {

    var uri : String? {
        didSet {
            println("WAS")
        }
    }
    
    
    init(){
        uri = "hej"
    }
}


var t = T()

