//
//  AppDelegate.swift
//  Uploader
//
//  Created by Łukasz Adamczak on 13.07.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Cocoa

private let serverURLKey = "serverURL"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, StatusItemViewDelegate {
    var statusItemView: StatusItemView!
    var uploader: Uploader!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItemView = StatusItemView()
        statusItemView.delegate = self
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.registerDefaults([
            serverURLKey: "http://localhost:8080/upload/"
        ])
        
        let url = userDefaults.stringForKey(serverURLKey)!
        uploader = Uploader(serverURL: url)
    }
    
    // MARK: - StatusItemViewDelegate
    
    func statusItemView(view: StatusItemView, didReceiveFileURL fileURL: NSURL) {
        uploader.uploadFile(fileURL, completionHandler: { result in
            switch result {
            case .Success(let link):
                let clipboard = NSPasteboard.generalPasteboard()
                clipboard.clearContents()
                clipboard.writeObjects([link])
                println("Successfully copied \(link)")
            case .Failure(let message):
                println(message)
            }
        })
    }

}

