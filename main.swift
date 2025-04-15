import Cocoa

class TimerWindow: NSWindow {
    private var timerView: TimerView
    
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
        
        // Position in the top-right corner of the screen
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            self.setFrameOrigin(NSPoint(
                x: screenRect.maxX - 140,
                y: screenRect.maxY - 70
            ))
        }
        
        // Set up content view
        self.contentView = timerView
    }
}

class TimerView: NSView {
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    private var isRunning = false
    private var timeLabel: NSTextField
    
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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