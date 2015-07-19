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
    let query = NSMetadataQuery()
    
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
        
        // Metadata query for new screenshots
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "queryUpdated:", name: NSMetadataQueryDidUpdateNotification, object: query)
        
        query.predicate = NSPredicate(format: "kMDItemIsScreenCapture = 1")
        query.sortDescriptors = [NSSortDescriptor(key: "kMDItemFSCreationDate", ascending: false)]
        query.startQuery()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        query.stopQuery()
    }
    
    func uploadFile(fileURL: NSURL) {
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
    
    // MARK: - StatusItemViewDelegate
    
    func statusItemView(view: StatusItemView, didReceiveFileURL fileURL: NSURL) {
        uploadFile(fileURL)
    }

    // MARK: - NSMetadataQuery notification
    
    func queryUpdated(notification: NSNotification) {
        println("Query updated: \(query.resultCount) screenshots found")
        
        if let item = query.resultAtIndex(0) as? NSMetadataItem {
            if let path = item.valueForAttribute("kMDItemPath") as? String,
                let fileURL = NSURL(fileURLWithPath: path) {
                uploadFile(fileURL)
            }
            else {
                println("Unable to parse URL from \(item.attributes)")
            }
        }
        else {
            println("No item in query")
        }
    }
    
}

