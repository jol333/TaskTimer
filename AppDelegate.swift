// AppDelegate.swift
//
// Contains the `AppDelegate` class that sets up the main application menu
// and handles app lifecycle events and timer reset actions.

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: TimerWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Instantiate and display the floating timer window
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
        if let timerView = window?.contentView as? TimerView {
            timerView.reset()
        }
    }
}
