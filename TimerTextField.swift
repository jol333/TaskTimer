// TimerTextField.swift
//
// A custom NSTextField subclass that displays the timer value
// with a pointing hand cursor when hovered and supports system shortcuts.

import Cocoa

class TimerTextField: NSTextField {
    override func resetCursorRects() {
        // Clear existing cursor rects
        discardCursorRects()
        
        // Add pointing hand cursor for the entire text field area
        addCursorRect(bounds, cursor: .pointingHand)
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers {
            case "a":
                if let editor = currentEditor() {
                    editor.selectAll(nil)
                    return true
                }
            default:
                break
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}