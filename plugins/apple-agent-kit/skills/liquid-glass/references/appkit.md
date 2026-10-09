# AppKit cheat-sheet

Confirmed APIs for AppKit on macOS 26. Sources and maintainer provenance live
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
container.subviews = [reply, forward, archive, delete]
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
| `.sidebar` | Legacy sidebar — **remove on macOS 26** so Liquid Glass picks up. |
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
sidebarItem.behavior = .sidebar   // Liquid Glass auto on macOS 26

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
- `NSItemBadge.count(_:)`, `.text(_:)`, `.indicator(...)`

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

- `NSWindow.beginSheet(_:completionHandler:)` — material `.sheet`, morphs in from presenting control on macOS 26.
- `NSPopover` — material `.popover`. Set `behavior = .transient` for hover-dismiss.
- `NSMenu` — material `.menu`. Redesigned single-column icon-led rows. Use SF Symbols.

## Scroll edge effects

Per-edge accessors on `NSScrollView`. Controls how scroll content
fades or hardens at edges that sit beneath floating chrome. Full
rules in `references/patterns/scroll-edge-effects.md`.

```swift
scrollView.topEdgeEffect.style    = .hard
scrollView.bottomEdgeEffect.style = .soft
scrollView.leftEdgeEffect.isHidden = true
```

- `.style`: `.soft` (default) or `.hard`.
- `.isHidden`: drop the effect on edges where no chrome actually sits.
- One style per edge. Never mix soft + hard on adjacent edges of the
  same scroll view.

## Source list sidebar

`NSOutlineView` in source-list style. On macOS 26, rows render directly on
the new glass — drop any legacy `.sidebar` vibrancy layer.

## Sample patterns

### Glass capsule pill of toolbar buttons

```swift
let pill = NSGlassEffectContainerView()
for symbol in ["arrowshape.turn.up.left", "arrowshape.turn.up.right", "archivebox", "trash"] {
    let b = NSButton(image: NSImage(systemSymbolName: symbol, accessibilityDescription: nil)!,
                     target: nil, action: nil)
    b.bezelStyle = .glass
    b.borderShape = .capsule
    pill.addSubview(b)
}
```

### Concentric corners

```swift
window.contentView?.wantsLayer = true
window.contentView?.layer?.cornerRadius = 28

let inner = NSGlassEffectView()
inner.cornerRadius = 20   // 28 − 8 inset
```

## Gaps (don't guess)

- The exact `NSToolbar` / `NSToolbarItem` API spelling for `ToolbarSpacer` equivalent (SwiftUI has it; AppKit equivalent not confirmed).
- The new `NSView.LayoutRegion` / `safeArea(cornerAdaptation:)` formal signature.
- `NSGlassEffectView` initializer variants beyond the bare constructor.
