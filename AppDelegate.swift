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
    
    @objc func removeTimer(_ sender: NSButton) {
        guard let timerWindow = window else { return }
        
        // Find the timer view associated with this button
        let buttonPosition = sender.frame.origin.y
        let timerIndex = Int((buttonPosition - 85) / 80) + 1
        
        // Make sure the index is valid
        if timerIndex >= 0 && timerIndex < timerWindow.timerViews.count {
            // Remove the timer view and its remove button
            timerWindow.removeTimerView(at: timerIndex)
            
            // Calculate the new height based on remaining timer views
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
