//
//  PreferencesWindowController.swift
//  Quicksend
//
//  Created by Łukasz Adamczak on 21.09.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    var regions = [
        [ "title": "US Standard (N. Virginia)", "key": "us-east-1" ],
        [ "title": "US West (Oregon)",          "key": "us-west-2" ],
        [ "title": "US West (N. California)",   "key": "us-west-1" ],
        [ "title": "EU (Ireland)",              "key": "eu-west-1" ],
        [ "title": "EU (Frankfurt)",            "key": "eu-central-1" ],
        [ "title": "Asia Pacific (Singapore)",  "key": "ap-southeast-1" ],
        [ "title": "Asia Pacific (Sydney)",     "key": "ap-southeast-2" ],
        [ "title": "Asia Pacific (Tokyo)",      "key": "ap-northeast-1" ],
        [ "title": "South America (Sao Paulo)", "key": "sa-east-1" ]
    ]
    
    override var windowNibName: String {
        return "PreferencesWindowController"
    }
    
    func windowWillClose(notification: NSNotification) {
        window!.endEditingFor(nil)
    }
    
}
