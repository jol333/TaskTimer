import Cocoa

class TimerWindow: NSWindow {
    private var timerView: TimerView
    private var expandedFrame: NSRect?
    private var compactFrame: NSRect?
    private var expanded = true
    private var hideTimer: Timer?
    
    init() {
        // Create a window that's small, borderless, and stays on top
        timerView = TimerView(frame: NSRect(x: 0, y: 0, width: 120, height: 50))
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 50),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        // Configure window to be transparent, always on top, and non-activating
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.level = .statusBar // Ensures it stays above most windows, including fullscreen
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary] // Visible in all spaces and fullscreen
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
        
        // Calculate frames for expanded and compact states
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            
            // Expanded frame (normal position when visible)
            expandedFrame = NSRect(
                x: screenRect.maxX - 140,
                y: screenRect.maxY - 70,
                width: 120,
                height: 50
            )
            
            // Compact frame (tiny area in the top-right corner when "hidden")
            compactFrame = NSRect(
                x: screenRect.maxX - 5,
                y: screenRect.maxY - 5,
                width: 5,
                height: 5
            )
            
            // Set initial position
            self.setFrame(expandedFrame!, display: true)
        }
        
        // Set up content view
        self.contentView = timerView
        
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
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().setFrame(expandedFrame, display: true)
            self.animator().alphaValue = 1.0
        }, completionHandler: {
            self.expanded = true
        })
    }
    
    func hideCompact() {
        guard expanded, let compactFrame = compactFrame else { return }
        
        // Animate to compact state
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().setFrame(compactFrame, display: true)
            self.animator().alphaValue = 0.2 // Keep slightly visible to detect hover
        }, completionHandler: {
            self.expanded = false
        })
    }
    
    override func mouseDown(with event: NSEvent) {
        if !expanded {
            showExpanded()
        } else {
            timerView.toggleTimer()
        }
        super.mouseDown(with: event)
    }
}

class TimerView: NSView {
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var isRunning = false
    private var timeLabel: NSTextField
    private var trackingArea: NSTrackingArea?
    
    var onMouseEnter: (() -> Void)?
    var onMouseExit: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        // Create the time display label
        timeLabel = NSTextField(frame: NSRect(x: 0, y: 0, width: frameRect.width, height: frameRect.height))
        timeLabel.isEditable = false
        timeLabel.isBordered = false
        timeLabel.backgroundColor = .clear
        timeLabel.textColor = .white
        timeLabel.alignment = .center
        timeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 24, weight: .regular)
        timeLabel.stringValue = "00:00:00"
        
        super.init(frame: frameRect)
        
        // Add the label to the view
        addSubview(timeLabel)
        
        // Add a background with rounded corners
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        layer?.cornerRadius = 10
        
        // Setup tracking area
        updateTrackingAreas()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        // Remove any existing tracking area
        if let trackingArea = self.trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        
        // Add a new tracking area covering the entire view
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
        trackingArea = NSTrackingArea(
            rect: self.bounds,
            options: options,
            owner: self,
            userInfo: nil
        )
        
        self.addTrackingArea(trackingArea!)
    }
    
    // Handle mouse tracking events
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        onMouseEnter?()
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        onMouseExit?()
    }
    
    // Override to accept first responder status
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    // Handle mouse down events directly
    override func mouseDown(with event: NSEvent) {
        toggleTimer()
        super.mouseDown(with: event)
    }
    
    func toggleTimer() {
        if isRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            isRunning = true
            
            // Add timer to run loop to ensure it works when the app is not the active application
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    @objc func updateTimer() {
        elapsedTime += 0.1
        updateDisplay()
    }
    
    func updateDisplay() {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        timeLabel.stringValue = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func reset() {
        stopTimer()
        elapsedTime = 0
        updateDisplay()
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        
        // Update the label frame to match the new size
        timeLabel.frame = self.bounds
        
        // Update tracking area
        updateTrackingAreas()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: TimerWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create and show window
        window = TimerWindow()
        window?.makeKeyAndOrderFront(nil)
        
        // Setup application menu
        setupMenu()
    }
    
    func setupMenu() {
        let mainMenu = NSMenu()
        app.mainMenu = mainMenu
        
        // Application menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        appMenu.addItem(withTitle: "About \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "TaskTimer")", 
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), 
                        keyEquivalent: "")
        
        appMenu.addItem(NSMenuItem.separator())
        
        appMenu.addItem(withTitle: "Quit", 
                        action: #selector(NSApplication.terminate(_:)), 
                        keyEquivalent: "q")
    }
}

// Create and run the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run() 