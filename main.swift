// main.swift
//
// Entry point for the TaskTimer application.
// Initializes NSApplication, assigns the AppDelegate, and starts the main run loop.

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
