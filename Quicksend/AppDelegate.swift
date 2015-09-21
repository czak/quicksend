//
//  AppDelegate.swift
//  Quicksend
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
    
    lazy var preferencesWindowController: PreferencesWindowController = {
        return PreferencesWindowController()
    }()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItemView = StatusItemView()
        statusItemView.delegate = self
        
        // Register user defaults
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.registerDefaults([
            serverURLKey: "http://localhost:8080/upload/"
        ])

        let url = userDefaults.stringForKey(serverURLKey)!
        uploader = Uploader(serverURL: url)
    }
    
    func uploadFile(fileURL: NSURL) {
        uploader.uploadFile(fileURL, completionHandler: { result in
            switch result {
            case .Success(let link):
                let clipboard = NSPasteboard.generalPasteboard()
                clipboard.clearContents()
                clipboard.writeObjects([link])
                
                // Notify the user
                let notification = NSUserNotification()
                notification.title = "Successfully uploaded"
                notification.subtitle = link
                NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
                
            case .Failure(let message):
                print(message)
            }
        })
    }
    
    // MARK: - Actions
    
    @IBAction func showPreferences(sender: AnyObject?) {
        preferencesWindowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    // MARK: - StatusItemViewDelegate
    
    func statusItemView(view: StatusItemView, didReceiveFileURL fileURL: NSURL) {
        uploadFile(fileURL)
    }
}

