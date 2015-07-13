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
    @IBOutlet weak var menu: NSMenu!
    
    var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let bar = NSStatusBar.systemStatusBar()
        
        let item = bar.statusItemWithLength(26)
        item.image = NSImage(named: "StatusIcon")!
        item.alternateImage = NSImage(named: "StatusIconWhite")!
        item.menu = menu
        statusItem = item
    }

}

