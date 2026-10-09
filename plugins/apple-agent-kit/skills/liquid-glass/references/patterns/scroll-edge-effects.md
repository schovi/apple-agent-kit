# Scroll edge effects

How scrolling content fades / hardens beneath floating chrome
(toolbar, sidebar, inspector). New on macOS 26.

Use the system treatment.

## SwiftUI

```swift
ScrollView { ... }
    .scrollEdgeEffectStyle(.hard, for: .top)
```

- Styles: `.soft` (default), `.hard`.
- Edges: `.top`, `.bottom`, `.leading`, `.trailing`, `.all`.

Common cases:

- **Default scroll content under a unified toolbar** — no manual call;
  `.soft` is the default and works.
- **Pinned-header `List` under a toolbar** — `.hard` for the top edge.
- **TextEditor inside an inspector pane** — `.hard` for the top edge.

## AppKit

```swift
scrollView.topEdgeEffect.style    = .hard
scrollView.bottomEdgeEffect.style = .soft
scrollView.leftEdgeEffect.isHidden = true
```

Per-edge accessors on `NSScrollView`. Each carries:

- `.style` — `.soft` (default) or `.hard`.
- `.isHidden` — drop the effect on edges where no chrome sits.

## Rules

- **One style per edge.** Never stack two on the same edge.
- **Never mix soft + hard on adjacent edges of one scroll view.** The
  visual language reads as one boundary character — pick one.
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

- Reduced Transparency collapses `.soft` to a thin solid line and
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
