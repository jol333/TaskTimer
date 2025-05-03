// TimerWindow.swift
//
// Contains the `TimerWindow` class responsible for creating and managing
// the floating, borderless window that auto-hides and expands on hover.
// Now supports multiple timers with an add button.

import Cocoa

// Import custom button class for cursor handling

class TimerWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }

    private var containerView: NSView
    var timerViews: [TimerView] = []
    private var addButton: NSButton?
    private var removeButtons: [NSButton] = []
    private var expandedFrame: NSRect?
    private var compactFrame: NSRect?
    var expanded = true
    private var hideTimer: Timer?

    init() {
        // Create a container view to hold the timer views and add button
        containerView = NSView(frame: NSRect(x: 0, y: 0, width: 120, height: 110))
        
        // Create the first timer view
        let firstTimerView = TimerView(frame: NSRect(x: 0, y: 30, width: 120, height: 80))
        timerViews.append(firstTimerView)

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 110),
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
            let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight ?? 50 // fallback to 50 if not available

            // Expanded frame (normal position when visible)
            expandedFrame = NSRect(
                x: screenRect.maxX - 130,
                y: screenRect.maxY - menuBarHeight - 110, // always below menu bar
                width: 120,
                height: 110
            )

            // Compact frame (hover hotspot at absolute top-right corner, above menu bar)
            compactFrame = NSRect(
                x: screenRect.maxX - 20,
                y: screenRect.maxY - 20,
                width: 20,
                height: 20
            )

            // Set initial position
            setFrame(expandedFrame!, display: true)
        }

        // Set up container view
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Add first timer view to container
        containerView.addSubview(firstTimerView)
        
        // Create and add a remove button for the first timer
        let removeButton = createRemoveButton(yPosition: 86)
        containerView.addSubview(removeButton)
        removeButtons.append(removeButton)
        
        // Create and add the "Add Timer" button
        let addButton = CursorButton(frame: NSRect(x: 0, y: 0, width: 120, height: 24))
        addButton.title = "+ Add Timer"
        addButton.bezelStyle = .inline
        addButton.isBordered = false
        addButton.font = NSFont.systemFont(ofSize: 12)
        addButton.contentTintColor = .white
        addButton.wantsLayer = true
        addButton.layer?.backgroundColor = NSColor.darkGray.withAlphaComponent(0.5).cgColor
        addButton.layer?.cornerRadius = 4
        addButton.target = NSApp.delegate
        addButton.action = #selector(AppDelegate.addNewTimer)
        
        containerView.addSubview(addButton)
        self.addButton = addButton
        
        // Set container as content view
        contentView = containerView

        // Set up mouse tracking for the first timer view and add button
        firstTimerView.onMouseEnter = { [weak self] in
            self?.cancelHideTimer()
            self?.showExpanded()
        }

        firstTimerView.onMouseExit = { [weak self] in
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

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        
        // For the window itself (buttons handle their own cursor)
        cancelHideTimer()
        showExpanded()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        
        // For the window itself (buttons handle their own cursor)
        scheduleHideTimer()
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
    
    // Method to resize the window when timers are added or removed
    func resizeWindow(height: CGFloat) {
        guard let screen = NSScreen.main else { return }
        let menuBarHeight = NSApplication.shared.mainMenu?.menuBarHeight ?? 50
        let newFrame = NSRect(
            x: screen.frame.maxX - 130,
            y: screen.frame.maxY - menuBarHeight - height,
            width: 120,
            height: height
        )
        self.expandedFrame = newFrame
        if expanded {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.01
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animator().setFrame(newFrame, display: true)
            })
        }
    }
    
    // Add a new timer view to this window
    func addTimerView(timerId: String? = nil) {
        // Calculate position for the new timer view with 2px gap
        let yPosition = 30 + (timerViews.count * (80 + 2)) // Add 2px gap between timers
        // Create and add a new timer view
        let newTimerView = TimerView(frame: NSRect(x: 0, y: yPosition, width: 120, height: 80), timerId: timerId)
        containerView.addSubview(newTimerView)
        timerViews.append(newTimerView)
        // Set up mouse tracking for the new timer view
        newTimerView.onMouseEnter = { [weak self] in
            self?.cancelHideTimer()
            self?.showExpanded()
        }
        newTimerView.onMouseExit = { [weak self] in
            self?.scheduleHideTimer()
        }
        // Create and add a remove button for this timer
        let removeButton = createRemoveButton(yPosition: CGFloat(yPosition) + 55)
        containerView.addSubview(removeButton)
        removeButtons.append(removeButton)
        // Reposition the add button to the bottom
        if let addButton = self.addButton {
            addButton.frame.origin.y = 0
        }
        // Save the timer order
        saveTimerOrder()
    }
    
    // Remove a timer view at the specified index
    func removeTimerView(at index: Int) {
        guard index >= 0 && index < timerViews.count else { return }
        
        // Get the timer view to remove
        let timerView = timerViews[index]
        
        // Remove the timer state from UserDefaults
        let timerId = timerView.timerId
        UserDefaults.standard.removeObject(forKey: "timer_\(timerId)")
        
        // Remove the timer view from the container and array
        timerView.removeFromSuperview()
        timerViews.remove(at: index)
        
        // Remove the associated remove button
        if index < removeButtons.count {
            let removeButton = removeButtons[index]
            
            // Remove tracking areas from the remove button
            for trackingArea in removeButton.trackingAreas {
                removeButton.removeTrackingArea(trackingArea)
            }
            
            removeButton.removeFromSuperview()
            removeButtons.remove(at: index)
        }
        
        // Reposition remaining timer views and buttons
        for i in 0..<timerViews.count {
            let yPosition = 30 + (i * (80 + 2)) // Add 2px gap between timers
            timerViews[i].frame.origin.y = CGFloat(yPosition)
            
            if i < removeButtons.count {
                removeButtons[i].frame.origin.y = CGFloat(yPosition + 55)
                // Update the tag to match the new index
                removeButtons[i].tag = i
            }
        }
        
        // Reposition the add button to the bottom
        if let addButton = self.addButton {
            addButton.frame.origin.y = 0
        }
        
        // Save the updated timer order
        saveTimerOrder()
    }
    
    // Create a remove button for a timer
    func createRemoveButton(yPosition: CGFloat) -> NSButton {
        let removeButton = CursorButton(frame: NSRect(x: 90, y: yPosition, width: 25, height: 20))
        removeButton.title = "✕"
        removeButton.bezelStyle = .inline
        removeButton.isBordered = false
        removeButton.font = NSFont.systemFont(ofSize: 10)
        removeButton.contentTintColor = .white
        removeButton.wantsLayer = true
        removeButton.layer?.backgroundColor = NSColor.darkGray.withAlphaComponent(0.5).cgColor
        removeButton.layer?.cornerRadius = 4
        removeButton.target = self  // Change target to self instead of AppDelegate
        removeButton.action = #selector(removeButtonClicked(_:))  // Change action to local method
        removeButton.tag = removeButtons.count  // Set tag to identify which timer this button belongs to
        
        return removeButton
    }
    
    @objc private func removeButtonClicked(_ sender: NSButton) {
        removeTimerView(at: sender.tag)
        
        // Update the window height
        let newHeight = CGFloat(30 + (timerViews.count * (80 + 2)) + 24)  // Base height + (timer count * (timer height + gap)) + add button height
        resizeWindow(height: newHeight)
    }
    
    // Called when window is about to close
    override func close() {
        // Remove tracking areas to prevent memory leaks
        // Remove tracking areas from the add button
        if let addButton = self.addButton {
            for trackingArea in addButton.trackingAreas {
                addButton.removeTrackingArea(trackingArea)
            }
        }
        
        // Remove tracking areas from all remove buttons
        for button in removeButtons {
            for trackingArea in button.trackingAreas {
                button.removeTrackingArea(trackingArea)
            }
        }
        
        super.close()
    }
    
    // MARK: - Timer Persistence
    
    // Save the order of timer IDs to UserDefaults
    func saveTimerOrder() {
        let timerIds = timerViews.map { $0.timerId }
        UserDefaults.standard.set(timerIds, forKey: "timerOrder")
        UserDefaults.standard.synchronize()
    }

    // Restore all timers from UserDefaults and layout them properly
    func restoreTimers() {
        // Remove all current timer views and remove buttons from container
        for view in timerViews { view.removeFromSuperview() }
        for button in removeButtons { button.removeFromSuperview() }
        timerViews.removeAll()
        removeButtons.removeAll()
        
        // Get saved timer order
        let timerIds = UserDefaults.standard.array(forKey: "timerOrder") as? [String] ?? []
        
        // For each timerId, create a TimerView and add to container
        for (i, timerId) in timerIds.enumerated() {
            let yPosition = 30 + (i * (80 + 2))
            let timerView = TimerView(frame: NSRect(x: 0, y: yPosition, width: 120, height: 80), timerId: timerId)
            containerView.addSubview(timerView)
            timerViews.append(timerView)
            // Set up mouse tracking
            timerView.onMouseEnter = { [weak self] in self?.cancelHideTimer(); self?.showExpanded() }
            timerView.onMouseExit = { [weak self] in self?.scheduleHideTimer() }
            // Add remove button
            let removeButton = createRemoveButton(yPosition: CGFloat(yPosition) + 55)
            containerView.addSubview(removeButton)
            removeButtons.append(removeButton)
        }
        // Reposition add button to bottom
        if let addButton = self.addButton {
            let addButtonY = timerViews.count > 0 ? CGFloat(30 + (timerViews.count * (80 + 2))) : 0
            addButton.frame.origin.y = addButtonY
        }
        // Resize window to fit all timers and add button
        let newHeight = CGFloat(30 + (timerViews.count * (80 + 2)) + 24)
        resizeWindow(height: newHeight)
    }
}
