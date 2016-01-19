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
class AppDelegate: NSObject, NSApplicationDelegate, StatusItemViewDelegate, NSUserNotificationCenterDelegate {
    var statusItemView: StatusItemView!
    var uploader = Uploader()
    
    lazy var preferencesWindowController: PreferencesWindowController = {
        return PreferencesWindowController()
    }()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItemView = StatusItemView()
        statusItemView.delegate = self
        
        // Domyślny region dla preferencesów
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.registerDefaults([
            "awsRegion": "us-east-1"
        ])
        
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
    
    func uploadFile(fileURL: NSURL) {
        uploader.uploadFile(fileURL, completionHandler: { result in
            switch result {
            case .Success(let url):
                let clipboard = NSPasteboard.generalPasteboard()
                clipboard.clearContents()
                clipboard.writeObjects([url.absoluteString])

                // Notify the user
                let notification = NSUserNotification()
                notification.title = "Upload successful!"
                notification.informativeText = url.lastPathComponent!
                NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
                
            case .Failure(let message):
                let alert = NSAlert()
                alert.messageText = "Unable to upload file"
                alert.informativeText = message
                alert.addButtonWithTitle("OK")
                alert.runModal()
                
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
    
    // MARK: - NSUserNotificationCenterDelegate

    // Always present notifications, even if app is key
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}

