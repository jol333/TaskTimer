// CursorButton.swift
//
// A custom NSButton subclass that automatically shows a pointing hand cursor
// when the mouse hovers over it.

import Cocoa

class CursorButton: NSButton {
    private var trackingArea: NSTrackingArea?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        // Remove existing tracking area if any
        if let existingTrackingArea = trackingArea {
            removeTrackingArea(existingTrackingArea)
        }
        
        // Create a new tracking area
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        trackingArea = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        NSCursor.pointingHand.set()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.arrow.set()
    }
}