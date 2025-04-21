// TimerWindow.swift
//
// Contains the `TimerWindow` class responsible for creating and managing
// the floating, borderless window that auto-hides and expands on hover.

import Cocoa

class TimerWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    private var timerView: TimerView
    private var expandedFrame: NSRect?
    private var compactFrame: NSRect?
    var expanded = true
    private var hideTimer: Timer?

    init() {
        // Create a window that's small, borderless, and stays on top
        timerView = TimerView(frame: NSRect(x: 0, y: 0, width: 120, height: 80))

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 80),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        // Configure window to be transparent, always on top, and non-activating
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        level = .screenSaver  // Ensures it stays above all windows, including fullscreen
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]  // Visible in all spaces and fullscreen
        acceptsMouseMovedEvents = true

        // Calculate frames for expanded and compact states
        if let screen = NSScreen.main {
            let screenRect = screen.frame  // Use frame instead of visibleFrame to include menu bar area

            // Expanded frame (normal position when visible)
            expandedFrame = NSRect(
                x: screenRect.maxX - 130,
                y: screenRect.maxY - 120,
                width: 120,
                height: 80
            )

            // Compact frame (larger area in the top-right corner when "hidden")
            compactFrame = NSRect(
                x: screenRect.maxX - 20,
                y: screenRect.maxY - 20,
                width: 20,
                height: 20
            )

            // Set initial position
            setFrame(expandedFrame!, display: true)
        }

        // Set up content view
        contentView = timerView

        // Create timer view with mouse tracking
        timerView.onMouseEnter = { [weak self] in
            self?.cancelHideTimer()
            self?.showExpanded()
        }

        timerView.onMouseExit = { [weak self] in
            self?.scheduleHideTimer()
        }

        // Schedule initial hide after 2 seconds
        scheduleHideTimer()
    }

    func scheduleHideTimer() {
        // Cancel existing timer if any
        cancelHideTimer()

        // Create new timer to hide the window after 2 seconds
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.hideTimer = nil
            self?.hideCompact()
        }
    }

    func cancelHideTimer() {
        hideTimer?.invalidate()
        hideTimer = nil
    }

    func showExpanded() {
        guard !expanded, let expandedFrame = expandedFrame else { return }

        // Animate to expanded state
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                animator().setFrame(expandedFrame, display: true)
                animator().alphaValue = 1.0
            },
            completionHandler: {
                self.expanded = true
            })
    }

    func hideCompact() {
        guard expanded, let compactFrame = compactFrame else { return }

        // Animate to compact state
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                animator().setFrame(compactFrame, display: true)
                animator().alphaValue = 0.1  // Completely invisible hover area
            },
            completionHandler: {
                self.expanded = false
            })
    }
}
