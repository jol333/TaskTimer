// TimerView.swift
//
// Contains the `TimerView` class responsible for:
// - Displaying elapsed time with a monospaced digit label
// - Editable task label for naming the current task
// - Mouse tracking to expand or hide the parent `TimerWindow`
// - Click handling to start/stop the timer
// - Right-click context menu for reset and quit actions

import Cocoa

class TimerView: NSView, NSTextFieldDelegate {
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var isRunning = false
    private var timeLabel: TimerTextField
    private var taskLabel: TimerTextField
    private var trackingArea: NSTrackingArea?
    
    // Unique identifier for this timer view
    var timerId: String
    
    // Single initializer that handles both cases
    init(frame frameRect: NSRect, timerId: String? = nil) {
        // Use provided ID or generate a new one
        self.timerId = timerId ?? UUID().uuidString
        
        // Create the task label (editable)
        taskLabel = TimerTextField(
            frame: NSRect(
                x: 5,
                y: frameRect.height - 30,
                width: frameRect.width - 10,
                height: 25))
        taskLabel.isEditable = true
        taskLabel.isBordered = false
        taskLabel.backgroundColor = .clear
        taskLabel.textColor = .white
        taskLabel.alignment = .left
        taskLabel.font = NSFont.systemFont(ofSize: 14)
        taskLabel.stringValue = "Task name"
        taskLabel.placeholderString = "Enter task name"
        taskLabel.focusRingType = .none

        // Create the time display label with pointing hand cursor
        timeLabel = TimerTextField(
            frame: NSRect(
                x: 0, y: 5,
                width: frameRect.width,
                height: 40))
        timeLabel.isEditable = false
        timeLabel.isBordered = false
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = .white
        timeLabel.alignment = .center
        timeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 24, weight: .regular)
        timeLabel.stringValue = "00:00:00"

        super.init(frame: frameRect)

        // Wire up text field delegate
        taskLabel.delegate = self

        // Add subviews
        addSubview(taskLabel)
        addSubview(timeLabel)

        // Rounded background
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        layer?.cornerRadius = 10

        // Enable mouse tracking
        updateTrackingAreas()
    }

    var onMouseEnter: (() -> Void)?
    var onMouseExit: (() -> Void)?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        // Remove old tracking area if exists
        if let oldArea = trackingArea {
            removeTrackingArea(oldArea)
        }

        // Create a new tracking area covering the view
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: options,
            owner: self,
            userInfo: nil)
        addTrackingArea(trackingArea!)
    }

    // Mouse enter/exit forwarders
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        onMouseEnter?()
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        onMouseExit?()
    }

    // Accept focus for keyboard events
    override var acceptsFirstResponder: Bool {
        return true
    }

    // Click handling: either start/stop timer or edit task label
    override func mouseDown(with event: NSEvent) {
        let pt = convert(event.locationInWindow, from: nil)
        if taskLabel.frame.contains(pt) {
            window?.makeFirstResponder(taskLabel)
        } else {
            toggleTimer()
        }
    }

    func toggleTimer() {
        if isRunning { stopTimer() } else { startTimer() }
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true)
        isRunning = true
        RunLoop.current.add(timer!, forMode: .common)
        
        // Save state when timer is started
        saveState()
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        // Save state when timer is stopped
        saveState()
    }

    @objc private func updateTimer() {
        elapsedTime += 0.1
        updateDisplay()
        
        // Save state periodically (every 5 seconds) to handle force quits
        if Int(elapsedTime * 10) % 50 == 0 { // Every 5 seconds (50 * 0.1s)
            saveState()
        }
    }

    private func updateDisplay() {
        let hrs = Int(elapsedTime) / 3600
        let mins = (Int(elapsedTime) % 3600) / 60
        let secs = Int(elapsedTime) % 60
        timeLabel.stringValue = String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }

    @objc func reset() {
        stopTimer()
        elapsedTime = 0
        updateDisplay()
        
        // Save state when timer is reset
        saveState()
    }

    // Context menu for reset/quit
    override func rightMouseDown(with event: NSEvent) {
        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(
                title: "Reset Timer",
                action: #selector(reset),
                keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"))
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
    
    // MARK: - Persistence Methods
    
    // Save timer state to UserDefaults
    func saveState() {
        let defaults = UserDefaults.standard
        
        // Create a dictionary to store timer state
        let timerState: [String: Any] = [
            "elapsedTime": elapsedTime,
            "isRunning": isRunning,
            "taskName": taskLabel.stringValue
        ]
        
        // Save the timer state using its unique ID
        defaults.set(timerState, forKey: "timer_\(timerId)")
        
        // Save immediately to handle force quits
        defaults.synchronize()
    }
    
    // Load timer state from UserDefaults
    func loadState() -> Bool {
        let defaults = UserDefaults.standard
        
        // Try to retrieve the timer state using its unique ID
        if let timerState = defaults.dictionary(forKey: "timer_\(timerId)") {
            // Restore elapsed time
            if let savedTime = timerState["elapsedTime"] as? TimeInterval {
                elapsedTime = savedTime
                updateDisplay()
            }
            
            // Restore task name
            if let taskName = timerState["taskName"] as? String {
                taskLabel.stringValue = taskName
            }
            
            // Restore running state if it was running
            if let wasRunning = timerState["isRunning"] as? Bool, wasRunning {
                startTimer()
            }
            
            return true
        }
        
        return false
    }
    
    // Pause hide when editing, resume after
    func controlTextDidBeginEditing(_ obj: Notification) {
        (window as? TimerWindow)?.cancelHideTimer()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        // Save state when task name is edited
        saveState()
        (window as? TimerWindow)?.scheduleHideTimer()
    }

    // Handle Enter to finish editing
    func control(
        _ control: NSControl,
        textView: NSTextView,
        doCommandBy commandSelector: Selector
    ) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            window?.makeFirstResponder(self)
            return true
        }
        return false
    }
}
