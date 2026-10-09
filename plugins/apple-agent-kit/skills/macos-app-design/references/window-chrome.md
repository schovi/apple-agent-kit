# Window chrome

The numeric rules that separate "credible Mac app" from "Electron with blur." Most are system-driven on macOS 26, but you have to opt into them; defaults are conservative.

## Outer radius and padding

- Window outer corner radius: **28**. The system rounds the window mask; you don't pick a radius unless you draw your own border. Concentric inner shapes resolve from `Tokens.Radius.xl`.
- Padding between window outer edge and sidebar / content: **8** (`Tokens.Spacing.controlGap`).
- Sidebar outer radius: `28 − 8 = 20`. Use `ConcentricRectangle()` in the sidebar's `.containerShape`.

## Titlebar heights

| Variant | Height |
|---|---|
| Unified with toolbar (default) | 52 |
| Standalone (no toolbar) | 28 |
| Tabbed | 76 |

## Full-size content view + transparent titlebar

The modern Mac app look. Pulls content under the titlebar, sidebar up next to the traffic lights.

```swift
// SwiftUI
@main struct App: App {
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

12 × 12 each, 8 px gap, cluster starts 14 px from window left edge. Vertical center = first sidebar row center.

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

Smaller-weight string after the title. For a custom subtitle view, use `ToolbarItem(placement: .largeSubtitle)` — that placement renders the supplied view in the secondary title slot.

## What to refuse

- "Make the window borderless / no titlebar." Hides system affordances. Users navigate by traffic lights.
- "Custom traffic lights." Apple positions them; do not redraw.
- "Different outer radius." 28 is the macOS 26 window corner. Picking 16 or 20 reads as iOS sheet.
- "Two toolbars." A13. Compose one.

## AppKit-specific

- Set `window.minSize = NSSize(width: 720, height: 480)` (narrow shell) or 920 / 1180 with sidebar / inspector.
- For breadcrumb in titlebar: `NSTitlebarAccessoryViewController(layoutAttribute: .top)`.

## Sources

Sources and maintainer provenance live in the apple-agent-kit repository's `docs/resources.md`.
