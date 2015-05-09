//
//  Util.swift
//  Swifter
//
//  Created by Morten Just Petersen on 5/1/15.
//  Copyright (c) 2015 Matt Donnelly. All rights reserved.
//

import Cocoa

class Util {

    
    func showWarning(title:String, body:String){
        var alert = NSAlert()
        alert.addButtonWithTitle("OK")
        alert.messageText = title
        alert.informativeText = body
        alert.alertStyle = NSAlertStyle.WarningAlertStyle
        alert.runModal()
    }
}
