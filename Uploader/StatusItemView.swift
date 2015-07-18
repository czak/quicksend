//
//  StatusItemView.swift
//  Uploader
//
//  Created by Łukasz Adamczak on 14.07.2015.
//  Copyright © 2015 Łukasz Adamczak. All rights reserved.
//

import Cocoa
import Alamofire

private let StatusItemWidth: CGFloat = 26
private let StatusItemImageNormal = NSImage(named: "StatusIcon")!
private let StatusItemImageHighlighted = NSImage(named: "StatusIconWhite")!

class StatusItemView: NSView, NSMenuDelegate {
    let statusItem: NSStatusItem

    var highlighted: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    var highlightForDragging: Bool = false {
        didSet {
            needsDisplay = true
        }
    }
    
    init() {
        // Instantiate the NSStatusItem
        let bar = NSStatusBar.systemStatusBar()
        statusItem = bar.statusItemWithLength(StatusItemWidth)
        
        super.init(frame: NSRect(x: 0, y: 0, width: statusItem.length, height: bar.thickness))
        
        statusItem.view = self

        setupMenu()
        
        registerForDraggedTypes([NSURLPboardType])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMenu() {
        menu = NSMenu()
        menu!.delegate = self
        menu!.addItemWithTitle("Quit", action: "terminate:", keyEquivalent: "")
    }
    
    // MARK: - NSDraggingDestination
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        if sender.draggingSource() === self {
            return .None
        }
        highlightForDragging = true
        return sender.draggingSourceOperationMask()
    }

    override func draggingExited(sender: NSDraggingInfo?) {
        highlightForDragging = false
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        // Read file URL from the dragging pasteboard
        let pasteboard = sender.draggingPasteboard()
        let fileURL = NSURL(fromPasteboard: pasteboard)!

        // Upload to server
        Alamofire.upload(
            .POST,
            URLString: "http://localhost:8080/upload/",
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: fileURL, name: "image")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { request, response, JSON, error in
                        if let dict = JSON as? NSDictionary, link = dict["link"] as? String {
                            let clipboard = NSPasteboard.generalPasteboard()
                            clipboard.clearContents()
                            clipboard.writeObjects([link])
                            println("Successfully copied \(link)")
                        }
                        else {
                            println("No link in \(JSON)")
                        }
                    }
                case .Failure(let encodingError):
                    println(encodingError)
                }
            }
        )
        
        return true
    }
    
    override func concludeDragOperation(sender: NSDraggingInfo?) {
        highlightForDragging = false
    }
    
    // MARK: - NSMenuDelegate
    
    func menuWillOpen(menu: NSMenu) {
        highlighted = true
    }
    
    func menuDidClose(menu: NSMenu) {
        highlighted = false
    }
    
    // MARK: - NSResponder
    
    override func mouseDown(theEvent: NSEvent) {
        statusItem.popUpStatusItemMenu(menu!)
    }
    
    // MARK: - Drawing

    override func drawRect(dirtyRect: NSRect) {
        if highlightForDragging {
            NSColor.redColor().set()
            NSBezierPath(rect: bounds).fill()
        }
        else {
            statusItem.drawStatusBarBackgroundInRect(bounds, withHighlight: highlighted)
        }
        
        let image = highlighted ? StatusItemImageHighlighted : StatusItemImageNormal
        
        // Center the image within view
        let x = (bounds.width - image.size.width) / 2
        let y = (bounds.height - image.size.height) / 2
        let offset = NSPoint(x: x, y: y)
        
        image.drawAtPoint(offset, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1)
    }
}
