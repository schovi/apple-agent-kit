# Menu bar extra (status item)

Persistent app surface anchored to the system menu bar. The chrome is
system-owned (Regular glass automatically); custom material on top is
F5 (glass-on-glass). The kit covers this pattern because a Mac craft
kit without menu-bar guidance is incomplete.

## SwiftUI recipe

```swift
@main
struct ClipboardApp: App {
    var body: some Scene {
        MenuBarExtra("Clipboard", systemImage: "doc.on.clipboard") {
            ClipboardPanel()
        }
        .menuBarExtraStyle(.window)        // .window for rich UI, .menu for a list
    }
}
```

Style choice:

- `.menuBarExtraStyle(.menu)` — native pull-down. Keyboard-driven,
  free accessibility, lightweight. Pick this for "a list of actions."
- `.menuBarExtraStyle(.window)` — popover panel hosting arbitrary
  SwiftUI. Pick this for rich UI (live data, search, multi-section).

Both styles are allowed in one app via separate `MenuBarExtra`
scenes.

## AppKit recipe

```swift
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
statusItem.button?.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
statusItem.button?.image?.isTemplate = true                    // mandatory — see anti-patterns
statusItem.button?.action = #selector(togglePanel(_:))
statusItem.button?.target = self
```

For a popover panel, attach `NSPopover` to the button's view:

```swift
let popover = NSPopover()
popover.contentSize = NSSize(width: 360, height: 420)
popover.behavior = .transient
popover.contentViewController = NSHostingController(rootView: ClipboardPanel())
popover.show(relativeTo: statusItem.button!.bounds,
             of: statusItem.button!,
             preferredEdge: .minY)
```

## Geometry (when you must override)

- Status icon: 16 pt template image; let the system color it.
- Popover width: 320–400 (sweet spot). Above 480 max-height users
  expect a full window — open one instead.
- Don't pin a status-item width; the system spaces it.

## Anti-patterns

- **`isTemplate = false` on the status icon** — the icon clashes
  with neighboring items in light / dark / accent tinting modes.
- **Custom glass under the popover** — F5; the system already
  provides Regular glass.
- **Animated status icon** — no spinners, no per-frame redraw. State
  changes belong in notifications or Dock badges. (A24-adjacent — the
  menu bar is not a place for kinetic effects.)
- **Hover popover** — macOS menu-bar items respond to click, not
  hover. Hover triggers conflict with Bartender-style hide tools.
- **Menu-bar-only critical actions** — every core feature must also
  be reachable via window, keyboard, or URL scheme.

## Keyboard

- `.menu` style: each item can carry `.keyboardShortcut(...)`.
- `.window` style: no global focus until clicked. To make the panel
  globally reachable, register a system-wide hotkey
  ([`KeyboardShortcuts` package](https://github.com/sindresorhus/KeyboardShortcuts)
  or `Carbon.RegisterEventHotKey`) and call `openWindow` /
  `NSPopover.show` programmatically.

## Accessibility

- The status item's `button.accessibilityLabel` is set by
  `MenuBarExtra("Label", ...)` — the SwiftUI title doubles as the
  accessibility label. AppKit code MUST set
  `button?.setAccessibilityLabel("...")` (`HIG — accessibility`).
- Don't mark the status item as `accessibilityElementsHidden = true`
  — it's reachable via VoiceOver's menu-bar navigation.

## Sources

Sources and maintainer provenance live in the apple-agent-kit repository's `docs/resources.md`.
