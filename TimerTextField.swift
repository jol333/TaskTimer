// TimerTextField.swift
//
// A custom NSTextField subclass that displays the timer value
// with a pointing hand cursor when hovered.

import Cocoa

class TimerTextField: NSTextField {
    override func resetCursorRects() {
        // Clear existing cursor rects
        discardCursorRects()
        
        // Add pointing hand cursor for the entire text field area
        addCursorRect(bounds, cursor: .pointingHand)
    }
}