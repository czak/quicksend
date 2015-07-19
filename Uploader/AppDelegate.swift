//
//  AppDelegate.swift
//  Uploader
//
//  Created by Łukasz Adamczak on 13.07.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, StatusItemViewDelegate {
    var statusItemView: StatusItemView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItemView = StatusItemView()
        statusItemView.delegate = self
    }
    
    // MARK: - StatusItemViewDelegate
    
    func statusItemView(view: StatusItemView, didReceiveFileURL fileURL: NSURL) {
        Uploader.uploadFile(fileURL, completionHandler: { result in
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

