//
//  AppDelegate.swift
//  Uploader
//
//  Created by Łukasz Adamczak on 13.07.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItemView: StatusItemView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItemView = StatusItemView()
    }

}

