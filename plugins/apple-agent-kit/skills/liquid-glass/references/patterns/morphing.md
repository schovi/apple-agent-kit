# Morphing

When a glass element appears, disappears, swaps shape, or moves between
two spots, it should *morph*.

## SwiftUI

```swift
@Namespace private var ns
@Binding var expanded: Bool

GlassEffectContainer(spacing: 24) {
    Button(expanded ? "Collapse" : "Expand") {
        withAnimation(.bouncy) { expanded.toggle() }
    }
    .buttonStyle(.glass)
    .buttonBorderShape(.capsule)
    .glassEffectID("toggle", in: ns)

    if expanded {
        Button { } label: { Image(systemName: "pencil") }
            .buttonStyle(.glass).buttonBorderShape(.capsule)
            .glassEffectID("edit", in: ns)
        Button { } label: { Image(systemName: "trash") }
            .buttonStyle(.glass).buttonBorderShape(.capsule)
            .glassEffectID("delete", in: ns)
    }
}
```

For a macOS sheet or popover, use its standard transition. For glass
participants that need to morph, keep them in one `GlassEffectContainer`.

For longer-lived shared identity across containers, use
`.glassEffectUnion(id:namespace:)`:

```swift
sidebarChip.glassEffectUnion(id: "selected", namespace: ns)
detailChip.glassEffectUnion(id: "selected", namespace: ns)
```

## AppKit

Morph between `NSGlassEffectView` instances inside a shared
`NSGlassEffectContainerView`. The container handles the shared sampling
pass; animate the swap with `NSAnimationContext`:

```swift
NSAnimationContext.runAnimationGroup { context in
    context.duration = 0.24
    context.timingFunction = CAMediaTimingFunction(name: .default)
    oldGlass.animator().alphaValue = 0
    newGlass.animator().alphaValue = 1
}
```

The container interpolates the *shape* across the swap; you control the
visibility of each participant.

## Requirements

All four must hold for the morph to actually run:

1. **Same `GlassEffectContainer`.** Cross-container morphs do not exist.
2. **Same `@Namespace`**, with per-identity `glassEffectID(_:in:)`
   values.
3. **Animated state change.** Wrap the toggle in `withAnimation(...)`
   (SwiftUI) or `NSAnimationContext.runAnimationGroup(...)` (AppKit).
   Without an animated transaction the views just pop.
4. **`spacing:` covers the gap.** Tighter spacing means participants
   must be physically closer before the morph kicks in.

## Geometry

- Container `spacing:` is the **merge threshold**, not a margin. Pick
  it so the **resting state** is what you want:
  - **Fully merged pill** (toolbar grouping): `spacing:` ≥ HStack gap.
    Standard toolbar pill uses `GlassEffectContainer(spacing: 4)` with
    `HStack(spacing: 4)`.
  - **Cleanly separated capsules** (expanded action row): container
    `spacing:` **smaller** than HStack gap. E.g.
    `GlassEffectContainer(spacing: 4)` with `HStack(spacing: 16)`.
    Morph identity still works because the items share the container
    and namespace.
  - Never pick a middle value (container `24` with HStack gap `8`).
    That renders the awkward half-merged blob state at rest — correct
    *during* the animation, wrong as a resting visual.
- Duration: `base` (240 ms) with `spring` easing for expansion, `fast`
  (160 ms) standard easing for swap.
- Reduced Motion automatically collapses to a cross-fade. Do not
  override.

## Forbidden

- Different `GlassEffectContainer`s for morph participants.
- Mixing Regular and Clear glass in one morph (A7).
- Animating `offset` or `position` to fake a morph — the glass itself
  must be the moving thing.
- Continuous loops on glass surfaces — glass at rest is cheap, glass
  mid-morph is GPU-heavy.

## Caveats

- The morph reads the *resolved* shape at each end. If start is
  `Capsule()` and end is `RoundedRectangle(cornerRadius: 12)`, the
  curve interpolates — both shapes should be intentional, not arbitrary
  defaults.
- macOS 26 toolbars morph internally when an item's prominence changes
  (e.g. `.glassProminent` toggled on). You rarely need to wire
  morphing inside the toolbar yourself.
- `.navigationTransition(.zoom(sourceID:in:))` is unavailable on macOS.
  Use a standard sheet or popover transition, or morph glass in one container.
