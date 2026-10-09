# Window chrome

The rules that separate "credible Mac app" from "Electron with blur." The system draws most of the chrome; your job is to opt in and not fight it.

## Outer radius and padding

The system owns the window corner radius, and it changes between releases: macOS 26 rounded windows to about 28 pt, and macOS 27 uses a tighter radius on every window. **Never hard-code it.**

- SwiftUI: derive inner corners with `ConcentricRectangle()` and `.containerShape(...)`, so they follow whatever the window uses.
- AppKit on macOS 27+: override `viewDidChangeEffectiveCornerRadii()` and apply the view's `effectiveCornerRadii` to your layer. `NSView.cornerConfiguration` is read-only for custom views. On macOS 26, use manual radii and treat 28 pt as an observation, not a contract.
- Sidebars: on macOS 26 the system draws the sidebar as an inset floating panel (about 8 pt from the window edge). On macOS 27 sidebars run edge to edge. In both cases `NavigationSplitView` / `NSSplitViewController` with `.sidebar` behavior draws it. Never build the inset yourself.

## Titlebar heights

Observed on macOS 26. The system sets these; use them only to size custom content that must line up with the titlebar, and re-check on each release.

| Variant | Height |
|---|---|
| Unified with toolbar (default) | 52 |
| Standalone (no toolbar) | 28 |
| Tabbed | 76 |

## Full-size content view + transparent titlebar

The modern Mac app look. Pulls content under the titlebar, sidebar up next to the traffic lights.

```swift
// SwiftUI
@main struct NotesApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .windowToolbarStyle(.unified(showsTitle: true))
            .windowStyle(.titleBar)
    }
}
```

```swift
// AppKit (in NSWindowController / awakeFromNib)
window.titlebarAppearsTransparent = true
window.styleMask.insert(.fullSizeContentView)
window.toolbarStyle = .unified
```

`unified(showsTitle: true)` keeps the title visible; pass `false` to hide it (rare — title is the most reliable way users tell windows apart).

## Traffic lights

Observed on macOS 26: 12 × 12 each, 8 px gap, cluster starts 14 px from the window's left edge, vertically centered on the first sidebar row.

Do **not** reposition them. The system draws them; align your sidebar to them, not the other way around. In SwiftUI / AppKit on macOS 26 the system positions them automatically when `fullSizeContentView` is set and the sidebar uses `NavigationSplitView` / `NSSplitViewController` with `.sidebar` behavior.

## Toolbar items inside the chrome

See `tokens.md` for material role, `references/swiftui.md` for the full toolbar API set. Three rules to keep:

1. **One `.toolbar` per view.** Two `.toolbar` modifiers in different ancestors silently drop the second (A13). Compose all items in one place.
2. **`ToolbarSpacer(.fixed)` vs `.flexible`.** `.fixed` keeps the items in one shared glass capsule with a fixed gap; `.flexible` splits the capsule into two visually separate groups.
3. **`.sharedBackgroundVisibility(.hidden)`** on a prominent action opts it out of the shared background so its tint reads cleanly. Use on `.glassProminent` items that want their own color.

## Subtitle

```swift
SomeContentView()
    .navigationTitle("Inbox")
    .navigationSubtitle("142 unread")
```

Smaller-weight string after the title. A custom subtitle view (`ToolbarItem(placement: .largeSubtitle)`) is iOS and iPadOS only; on macOS use `.navigationSubtitle(_:)`.

## What to refuse

- "Make the window borderless / no titlebar." Hides system affordances. Users navigate by traffic lights.
- "Custom traffic lights." Apple positions them; do not redraw.
- "Different outer radius." The window radius belongs to the system and changes between releases. Hard-coding any number (16, 20, 28) breaks concentricity on the next macOS.
- "Two toolbars." A13. Compose one.

## AppKit-specific

- Set `window.minSize = NSSize(width: 720, height: 480)` (narrow shell) or 920 / 1180 with sidebar / inspector.
- For breadcrumb in titlebar: `NSTitlebarAccessoryViewController(layoutAttribute: .top)`.

## Sources

Sources and maintainer provenance live in the apple-agent-kit repository's `docs/resources.md`.
