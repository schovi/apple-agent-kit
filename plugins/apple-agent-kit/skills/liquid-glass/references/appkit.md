# AppKit cheat-sheet

Confirmed APIs for AppKit on macOS 26 and later. Sources and maintainer provenance live
in the apple-agent-kit repository's `docs/resources.md` (§ B–D). Do not invent API names.

## Glass material

- `NSGlassEffectView` — single glass surface. Configurable `cornerRadius`, `tintColor`, `contentView`.
- `NSGlassEffectContainerView` — groups multiple glass elements so they share sampling and merge during animation.
- `NSBackgroundExtensionView` — mirrors / blurs content underneath floating sidebars and inspectors.

```objc
// AppKit (Swift)
let glass = NSGlassEffectView()
glass.cornerRadius = 28
glass.tintColor = .controlAccentColor
glass.contentView = MyContentView()
```

### `contentView` is the only safe place

Only the `contentView` of `NSGlassEffectView` is guaranteed to be
inside the glass effect. Arbitrary `addSubview(_:)` calls onto the
glass view itself may not z-order consistently with the glass layer
— put content into `contentView`, not directly on the glass view.

```swift
// ✅ Correct
glass.contentView = MyContentView()

// ❌ Risky — z-order not guaranteed
glass.addSubview(myLabel)
```

For multiple grouped glass capsules in a toolbar:

```swift
let container = NSGlassEffectContainerView()
let content = NSView()
content.addSubview(reply)
content.addSubview(forward)
content.addSubview(archive)
content.addSubview(delete)
container.contentView = content
// container.spacing defaults to 0 — suitable for batch sampling
// without merging. Raise it only when close siblings should fuse.
```

## Visual effect materials (semantic)

`NSVisualEffectView.Material` is unchanged from 10.14 — semantic role
names. macOS 26 layers Liquid Glass on top of these where it applies.

| Material | Use |
|---|---|
| `.titlebar` | Title bar background. |
| `.menu` | Menu surface. |
| `.popover` | Popover surface. |
| `.sidebar` | Legacy sidebar — **remove on macOS 26 and later** so Liquid Glass picks up. |
| `.headerView` | Section headers. |
| `.sheet` | Sheet background. |
| `.windowBackground` | Window background. |
| `.hudWindow` | HUD overlay. |
| `.fullScreenUI` | Full-screen UI controls. |
| `.toolTip` | Tooltip surface. |
| `.contentBackground` | Content area background. |
| `.underWindowBackground` | Behind the window. |
| `.underPageBackground` | Behind the page. |
| `.selection` | Selection highlight. |

## Window chrome

```swift
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 1180, height: 760),
    styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
    backing: .buffered, defer: false
)
window.titlebarAppearsTransparent = true
window.toolbarStyle = .unified
window.toolbar = makeToolbar()
```

The new `NSView.LayoutRegion` and `safeArea(cornerAdaptation:)` API helps
content avoid the rounder window corners introduced in macOS 26.

## Three-column layout

```swift
let splitVC = NSSplitViewController()

let sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarVC)
sidebarItem.behavior = .sidebar   // Liquid Glass auto on macOS 26 and later

let contentItem = NSSplitViewItem(viewController: contentVC)
contentItem.automaticallyAdjustsSafeAreaInsets = true

let inspectorItem = NSSplitViewItem(inspectorWithViewController: inspectorVC)
inspectorItem.behavior = .inspector

splitVC.splitViewItems = [sidebarItem, contentItem, inspectorItem]
```

New split-item accessory APIs:

- `addTopAlignedAccessoryViewController(_:)`
- `addBottomAlignedAccessoryViewController(_:)`

Both get the scroll-edge effect automatically.

## Toolbar

```swift
extension NSToolbar.Identifier {
    static let mainToolbar = Self("com.example.main-toolbar")
}

let toolbar = NSToolbar(identifier: .mainToolbar)
toolbar.displayMode = .iconOnly
toolbar.allowsUserCustomization = true
toolbar.delegate = self
```

Buttons in adjacent toolbar items auto-group on one shared glass element.
Non-interactive items should set:

```swift
item.isBordered = false
```

New (macOS 26):

- `NSToolbarItem.style = .prominent`
- `NSToolbarItem.backgroundTintColor = ...`
- `NSItemBadge.count(_:)`, `.text(_:)`, `.indicator`

## Push button (glass)

```swift
let button = NSButton(title: "Continue", target: nil, action: nil)
button.bezelStyle = .glass
button.borderShape = .capsule
button.tintProminence = .primary    // .primary | .secondary | .none | .automatic
```

`prefersCompactControlSizeMetrics` reverts to denser sizing for legacy contexts.

## Slider with neutral value

```swift
let slider = NSSlider()
slider.neutralValue = 0.5
slider.tintProminence = .primary
```

## Sheets / popovers / menus

- `NSWindow.beginSheet(_:completionHandler:)` — material `.sheet`, morphs in from presenting control on macOS 26 and later.
- `NSPopover` — material `.popover`. Set `behavior = .transient` for hover-dismiss.
- `NSMenu` — material `.menu`. Use images only where they carry meaning.
  On macOS 27, set `item.preferredImageVisibility = .visible` to opt in.

## Scroll edge effects

Set the preference on the titlebar or split-view accessory that overlaps
the scrolling content. Full rules live in `references/patterns/scroll-edge-effects.md`.

```swift
if #available(macOS 26.1, *) {
    titlebarAccessory.preferredScrollEdgeEffectStyle = .automatic
}
```

- `.automatic` is the default. Choose `.soft` or `.hard` only when the
  accessory needs it.
- AppKit resolves `.automatic` to `.hard` when free-floating title text
  overlaps the content.
- Apply one effect per accessory. Do not mix explicit styles on one view.

## Source list sidebar

`NSOutlineView` in source-list style. On macOS 26 and later, rows render directly on
the new glass — drop any legacy `.sidebar` vibrancy layer.

## Sample patterns

### Glass capsule pill of toolbar buttons

```swift
let pill = NSGlassEffectContainerView()
let content = NSView()
pill.contentView = content
for symbol in ["arrowshape.turn.up.left", "arrowshape.turn.up.right", "archivebox", "trash"] {
    let b = NSButton(image: NSImage(systemSymbolName: symbol, accessibilityDescription: nil)!,
                     target: nil, action: nil)
    b.bezelStyle = .glass
    b.borderShape = .capsule
    content.addSubview(b)
}
```

### Concentric corners

```swift
if #available(macOS 27, *) {
    let radii = window.contentView?.effectiveCornerRadii
    // Override viewDidChangeEffectiveCornerRadii() to apply radii in custom drawing.
    _ = radii
} else {
    // macOS 26's 28 pt window radius was observed, not a portable token.
    let inner = NSGlassEffectView()
    inner.cornerRadius = 20
}
```

## macOS 27 changes

- `NSGlassEffectView.effectIsInteractive` adds click feedback. Use it sparingly.
- `NSView.effectiveCornerRadii` and `viewDidChangeEffectiveCornerRadii()` expose resolved corners.
- `NSView.cornerConfiguration` is read-only. The SDK has no public setter for arbitrary views.
- `NSMenuItem.preferredImageVisibility = .visible` opts an image into macOS 27 menus.
- System glass adapts to the user’s appearance setting. The SDK has no public reader for it.
