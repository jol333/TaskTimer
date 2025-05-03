// AppDelegate.swift
//
// Contains the `AppDelegate` class that sets up the main application menu
// and handles app lifecycle events and timer reset actions.

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: TimerWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the timer window
        window = TimerWindow()
        window?.makeKeyAndOrderFront(nil)
        
        // Configure the app menu
        setupMenu()
        
        // Load saved timer states
        loadSavedTimerStates()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Save all timer states when app is about to terminate
        saveAllTimerStates()
    }
    
    // Save states of all timers
    private func saveAllTimerStates() {
        if let timerWindow = window {
            for timerView in timerWindow.timerViews {
                timerView.saveState()
            }
        }
    }
    
    // Load saved timer states and create timers for them
    private func loadSavedTimerStates() {
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        let timerKeys = allKeys.filter { $0.hasPrefix("timer_") }
        if timerKeys.count > 0 {
            let savedTimerOrder = defaults.array(forKey: "timerOrder") as? [String] ?? []
            // Remove all existing timer views (including the default one)
            if let timerWindow = window {
                while timerWindow.timerViews.count > 0 {
                    timerWindow.removeTimerView(at: 0)
                }
                // Add timer views for each saved timerId in order
                for timerId in savedTimerOrder {
                    timerWindow.addTimerView(timerId: timerId)
                }
                // Load state for each timer view
                for timerView in timerWindow.timerViews {
                    _ = timerView.loadState()
                }
                timerWindow.saveTimerOrder()
                
                // Resize the window to fit all loaded timers
                let timerCount = timerWindow.timerViews.count
                let baseHeight: CGFloat = 110 // Height for a single timer
                let additionalHeight: CGFloat = 80 // Height for each additional timer
                let newHeight = baseHeight + (additionalHeight * CGFloat(timerCount - 1))
                timerWindow.resizeWindow(height: newHeight)
            }
        }
    }

    private func setupMenu() {
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu

        // Application menu
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)

        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu

        appMenu.addItem(
            withTitle:
                "About \(Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "TaskTimer")",
            action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
            keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(
            withTitle: "Reset Timer",
            action: #selector(resetTimer),
            keyEquivalent: "r")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(
            withTitle: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q")
    }

    @objc private func resetTimer() {
        // Reset all timers in the window
        if let timerWindow = window {
            for timerView in timerWindow.timerViews {
                timerView.reset()
            }
        }
    }
    
    @objc func addNewTimer() {
        // Add a new timer view to the existing window
        window?.addTimerView()
        
        // Calculate the new height based on number of timer views
        if let timerWindow = window {
            let baseHeight: CGFloat = 110 // Height for a single timer
            let additionalHeight: CGFloat = 80 // Height for each additional timer
            let timerCount = timerWindow.timerViews.count
            
            // Calculate new height
            let newHeight = baseHeight + (additionalHeight * CGFloat(timerCount - 1))
            
            // Resize the window
            timerWindow.resizeWindow(height: newHeight)
        }
    }
}
