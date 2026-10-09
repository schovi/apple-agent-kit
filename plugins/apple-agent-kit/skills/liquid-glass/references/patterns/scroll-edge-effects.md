# Scroll edge effects

How scrolling content fades / hardens beneath floating chrome
(toolbar, sidebar, inspector). Available on macOS 26 and later.

Use the system treatment.

## SwiftUI

```swift
ScrollView { ... }
    .scrollEdgeEffectStyle(.hard, for: .top)
```

- Styles: `.automatic` (default), `.soft`, `.hard`.
- Edges: `.top`, `.bottom`, `.leading`, `.trailing`, `.all`.

Common cases:

- **Default scroll content under a unified toolbar** — no manual call;
  `.automatic` is the default and preferred.
- **Pinned-header `List` under a toolbar** — `.hard` for the top edge.
- **TextEditor inside an inspector pane** — `.hard` for the top edge.

## AppKit

```swift
if #available(macOS 26.1, *) {
    titlebarAccessory.preferredScrollEdgeEffectStyle = .automatic
}
```

Set `preferredScrollEdgeEffectStyle` on an `NSTitlebarAccessoryViewController`
or `NSSplitViewItemAccessoryViewController`. `.automatic` is the default.
On macOS 27, it resolves to `.hard` when free-floating title text overlaps content.

## Rules

- **One effect per view.** Prefer `.automatic`.
- **Never mix explicit soft + hard styles on one view.** The visual language
  reads as one boundary character.
- **Only where it does work.** Edge effects are not decoration. Apply
  one only where a floating chrome element actually overlaps that edge.

## Forbidden

- A custom gradient mask on the scroll content to fake an edge effect.
  The system effect is sampled, not blended.
- Adding `.hard` to a sidebar list to "feel more macOS". Sidebars
  already get the correct treatment from `NavigationSplitView` /
  `NSSplitViewItem.behavior = .sidebar`.
- Hiding the system edge effect to reintroduce a legacy
  `.headerView` backdrop. The new treatment replaces the legacy one.

## Caveats

- Reduced Transparency collapses `.automatic` or `.soft` to a thin solid line and
  `.hard` to a divider. Do not branch on
  `accessibilityReduceTransparency` to draw your own — the system
  already inserts one.
- `.backgroundExtensionEffect` on the underlying content interacts
  with the edge effect. Place `.backgroundExtensionEffect` on the
  hero / media view, never on the chrome.
- Inspector and sidebar columns of `NavigationSplitView` apply hard
  edges to their toolbars automatically. Adding
  `.scrollEdgeEffectStyle(.hard, for: .top)` inside the column is
  redundant.
