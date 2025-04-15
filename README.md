# TaskTimer

A simple macOS timer that stays on top of all windows, including fullscreen applications.

## Features

- Always-on-top timer display
- Visible even in fullscreen apps
- Click to start/pause the timer
- Transparent background with rounded corners

## Requirements

- macOS 10.14 or later
- Xcode Command Line Tools installed

## Building and Running

1. Make the build script executable:
   ```bash
   chmod +x build.sh
   ```

2. Run the build script:
   ```bash
   ./build.sh
   ```

3. Launch the application:
   ```bash
   open TaskTimer.app
   ```

## Usage

- **Click** on the timer to start or pause it
- The timer will display in the format: HH:MM:SS
- The timer stays on top of all windows, including fullscreen applications

## How It Works

This app uses AppKit (Cocoa) to create a floating panel window with a high window level. It's configured to appear in all spaces and with fullscreen apps thanks to the `canJoinAllSpaces` and `fullScreenAuxiliary` collection behaviors. 