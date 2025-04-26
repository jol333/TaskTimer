# Project Rules
---
alwaysApply: true
---

This is a macOS TaskTimer application written in Swift. Use these rules to navigate the codebase effectively:

- [main.swift](mdc:main.swift): The application entry point, initializes `NSApplication` and uses `AppDelegate`.
- [AppDelegate.swift](mdc:AppDelegate.swift): Configures the main menu, manages app lifecycle, and creates the floating `TimerWindow`.
- [TimerWindow.swift](mdc:TimerWindow.swift): Defines the floating, borderless window with auto-hide/expand behavior and hosts a `TimerView` as its content.
- [TimerView.swift](mdc:TimerView.swift): Implements the timer UI, including start/stop logic, elapsed time display, editable task name, context menu for reset/quit, and mouse tracking.
- [build.sh](mdc:build.sh): Shell script to build the TaskTimer.app bundle.
- [README.md](mdc:README.md): Project documentation and usage instructions.

## Navigation Tips

- To locate UI behavior for hover and expand, search in [TimerWindow.swift](mdc:TimerWindow.swift) for `onMouseEnter` and `onMouseExit`.
- Timer start/stop and reset logic lives in [TimerView.swift](mdc:TimerView.swift).
- To add support for multiple timers, consider extending `AppDelegate` to manage an array of `TimerWindow` instances or embedding multiple `TimerView` instances in a single window.
- Context menu customization for individual timers is handled via `rightMouseDown` in [TimerView.swift](mdc:TimerView.swift).

## Editing Guidance

- When modifying UI layout, update the frame sizes and subview setup in `TimerWindow.swift` and `TimerView.swift`.
- For build changes, adjust `build.sh` accordingly.
