# Project Rules
---
alwaysApply: true
---

This is a macOS TaskTimer application written in Swift. Use these rules to navigate the codebase effectively:

- @main.swift: The application entry point, initializes `NSApplication` and uses `AppDelegate`.
- @AppDelegate.swift: Configures the main menu, manages app lifecycle, and creates the floating `TimerWindow`.
- @TimerWindow.swift: Defines the floating, borderless window with auto-hide/expand behavior and hosts a `TimerView` as its content.
- @TimerView.swift: Implements the timer UI, including start/stop logic, elapsed time display, editable task name, context menu for reset/quit, and mouse tracking.
- @CursorButton.swift: Custom button implementation with cursor handling.
- @TimerTextField.swift: Custom text field implementation for the timer application.
- @build.sh: Shell script to build the TaskTimer.app bundle.
- @README.md: Project documentation and usage instructions.

## Navigation Tips

- To locate UI behavior for hover and expand, search in @TimerWindow.swift for `onMouseEnter` and `onMouseExit`.
- Timer start/stop and reset logic lives in @TimerView.swift methods `toggleTimer()`, `startTimer()`, `stopTimer()`, and `reset()`.
- Multiple timer support is implemented in @TimerWindow.swift with methods `addTimerView()` and `removeTimerView()`.
- Context menu customization for individual timers is handled via `rightMouseDown` in @TimerView.swift.
- Timer state persistence uses `saveState()` and `saveTimerOrder()` methods to store data in UserDefaults.

## Editing Guidance

- When modifying UI layout, update the frame sizes and subview setup in `TimerWindow.swift` and `TimerView.swift`.
- For build changes, adjust `build.sh` accordingly.
- To modify the window appearance or behavior, focus on `TimerWindow.swift` methods such as `showExpanded()` and `hideCompact()`.
- Task timers are managed as individual `TimerView` instances within the `TimerWindow`.