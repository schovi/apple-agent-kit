# Sidebar

The Mac app shell pillar. `NavigationSplitView` (SwiftUI) or `NSSplitViewController` (AppKit) gets you the geometry and the system material for free.

## Material role

`sidebar`. Use `NSSplitViewItem(sidebarWithViewController:)` with
`behavior = .sidebar` in AppKit. `NavigationSplitView` applies it in SwiftUI.

**Do not** add a legacy `.sidebar` material on macOS 26 and later — its presence blocks Liquid Glass auto-application. (Anti-pattern A11.)

## SwiftUI recipe

```swift
struct ContentView: View {
    @State private var selection: SectionID = .inbox

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("Foundations") {
                    ForEach(foundationItems) { item in
                        NavigationLink(value: item) {
                            Label(item.label, systemImage: item.symbol)
                        }
                        .badge(item.badge ?? 0)
                    }
                }
                Section("Components") {
                    ForEach(componentItems) { item in
                        NavigationLink(value: item) { Label(item.label, systemImage: item.symbol) }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Showcase")
            .frame(minWidth: 220, idealWidth: 260)
        } detail: {
            DetailView(selection: selection)
        }
    }
}

enum SectionID: Hashable {
    case inbox
}
```

`.listStyle(.sidebar)` is what makes the rows pick up the system sidebar treatment. Without it you get a flat plain list.

## AppKit recipe

```swift
let split = NSSplitViewController()
let sidebar = NSSplitViewItem(sidebarWithViewController: sidebarVC)
sidebar.behavior = .sidebar
sidebar.canCollapse = true
sidebar.minimumThickness = 220
sidebar.maximumThickness = 320
split.addSplitViewItem(sidebar)
```

The `behavior = .sidebar` setting triggers the system sidebar material on macOS 26 and later.

## Section structure

2–5 sections. More than five reads as a directory tree; fewer than two doesn't justify a sidebar at all.

```swift
Section("Foundations") { /* 3-5 items */ }
Section("Components")  { /* 3-5 items */ }
Section("Patterns")    { /* 2-4 items */ }
Section("Reference")   { /* 2-4 items */ }
```

## Geometry (when you must override)

- Width: `minWidth: 220, idealWidth: 260` for Mac; `idealWidth: 320` for iPad.
- Row height: system-driven. Don't fight it; if rows look too tall, the issue is usually a too-large `Label` icon.
- macOS 26 observed an 8 pt floating inset, drawn by the system. Never recreate it.
- macOS 27 sidebars are edge to edge. Icons are colored again and selected text is semibold.

## Inner anti-patterns

- **Glass-on-glass inside the sidebar.** The sidebar is already glass. Putting another `.glassEffect` on a row is A1. Solid rows only.
- **Form rows in the sidebar.** Inputs belong in the detail pane.
- **Custom selection background.** Let `List(selection:)` draw it. Custom rectangles break the focus ring and right-click highlight.
- **Outline group nested deeper than 3 visible levels.** Cap visible depth at 3 to keep the column scannable.

## Full-height sidebar window

Pair the sidebar with the full-size content view chrome:

```swift
@main struct ShowcaseApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .windowToolbarStyle(.unified(showsTitle: true))
            .windowStyle(.titleBar)
    }
}
```

The sidebar pulls up next to the traffic lights, the first row's center aligns to the traffic-light cluster, and the toolbar pill floats over the detail column. See `window-chrome.md` for the chrome geometry.

## iPadOS

The same `NavigationSplitView` powers iPad. Default sidebar width is 320; rotate the device and the system handles the column visibility (`.navigationSplitViewColumnVisibility`).

## Reduced transparency

System-handled. When `accessibilityReduceTransparency` is on, the sidebar collapses to an opaque tinted background. Do not hand-roll a fallback.

## Sources

Sources and maintainer provenance live in the apple-agent-kit repository's `docs/resources.md`.
