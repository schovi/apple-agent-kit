# Native tokens

These geometry tokens apply to native code. Material numerics do not — macOS 26 renders Liquid Glass in real time and Apple
publishes no portable blur / saturation / opacity values.

## Radii (points)

| Token | Value |
|---|---|
| `sm` | 12 |
| `md` | 16 |
| `lg` | 24 |
| `xl` | 28 |
| `capsule` | `height / 2` |

In SwiftUI: `RoundedRectangle(cornerRadius: ..., style: .continuous)`.
Use `ConcentricRectangle()` for children so corner curvatures stay parallel.

## Spacing (points)

| Token | Value | Use |
|---|---|---|
| `controlGap` | 8 | between controls inside one group |
| `groupGap` | 12 | between sibling groups inside a panel |
| `panelGap` | 16 | between panels |
| `screenMarginCompact` | 16 | edge inset on dense layouts |
| `screenMarginRegular` | 24 | edge inset on normal layouts |
| `sectionGap` | 32 | between top-level sections |

## Motion

| Token | Duration | Easing |
|---|---|---|
| `instant` | 80 ms | standard |
| `fast` | 160 ms | standard |
| `base` | 240 ms | standard |
| `slow` | 360 ms | standard |
| `sheet` | 420 ms | spring |

Easings:

- `standard`     — `cubic-bezier(0.2, 0, 0, 1)`
- `decelerate`   — `cubic-bezier(0, 0, 0, 1)`
- `accelerate`   — `cubic-bezier(0.3, 0, 1, 1)`
- `spring`       — `cubic-bezier(0.5, 1.6, 0.4, 0.85)` (SwiftUI: `.spring(response: 0.42, dampingFraction: 0.65)`)

## Typography

Use the SF system font (`Font.system(...)` / `NSFont.systemFont(ofSize:)`).
Eleven steps from caption2 to largeTitle.

| Token | Size / Line | Weight |
|---|---|---|
| `caption2` | 11 / 13 | 400 |
| `caption1` | 12 / 16 | 400 |
| `footnote` | 13 / 18 | 400 |
| `subheadline` | 15 / 20 | 400 |
| `callout` | 16 / 21 | 400 |
| `body` | 17 / 22 | 400 |
| `headline` | 17 / 22 | 600 |
| `title3` | 20 / 25 | 600 |
| `title2` | 22 / 28 | 700 |
| `title1` | 28 / 34 | 700 |
| `largeTitle` | 34 / 41 | 700 |

## Material — do not invent numerics

Apple does not publish blur / saturation / opacity numerics for Liquid Glass.
For native code, use the variant API and let the system render — never reach
for `CIFilter` to "hand-tune" the look.

- SwiftUI: `Glass.regular`, `Glass.clear`, `.glass.tint(_:).interactive()`.
- AppKit: `NSGlassEffectView`, optional `tintColor`; or use the right `NSVisualEffectMaterial` (`.popover`, `.menu`, `.sheet`, etc.).

## Material roles — pick by where the surface lives

Each role names a surface by where it sits. The role chooses the right Apple API and decides whether
the surface counts against the B1 live-blur budget.

| Role | SwiftUI | AppKit (`NSVisualEffectView.Material`) | macOS 26 Glass | Counts vs B1 |
|---|---|---|---|---|
| `sidebar` | `Glass.regular` (auto on `NavigationSplitView` sidebar) | `.sidebar` | regular | yes |
| `toolbar` | `Glass.regular` (auto on `.toolbar { ... }`) | `.titlebar` / `NSToolbar` unified | regular | yes |
| `menu` | system-applied via `Menu` / `.contextMenu` | `.menu` | regular | yes |
| `popover` | system-applied via `.popover(isPresented:arrowEdge:)` | `.popover` | regular | yes |
| `hud` | `Glass.regular` inside `.overlay(alignment:)` (often in `GlassEffectContainer`) | `.hudWindow` | regular | yes |
| `sheet` | system-applied via `.sheet { ... .presentationDetents([...]) }` | `NSWindow` sheet (`.sheet`) | regular | yes |
| `header` | `.background(.regularMaterial)` on sticky headers | `.headerView` | regular | yes |
| `windowBackground` | `Color(nsColor: .windowBackgroundColor)` | `.windowBackground` or solid | n/a | no (solid tint) |
| `content` | `Color(nsColor: .controlBackgroundColor)` | solid `NSColor` | n/a | no (solid) |

Rule of thumb for amateurs: don't ask "should this be `.thin` or `.thick`?" —
ask "what does this surface *do*?" Pick the role first; the material follows.

Wrong:

```swift
Rectangle().fill(.ultraThinMaterial)  // why this thickness?
```

Right:

```swift
// A sidebar column. The sidebar role auto-applies the system material.
NavigationSplitView {
    sidebarContent
} detail: {
    detailContent
}
```

```swift
// A floating HUD over media. Role: hud.
mediaCanvas
    .overlay(alignment: .bottom) {
        GlassEffectContainer {
            HStack { /* HUD controls */ }
                .padding(6)
                .glassEffect(.regular, in: .capsule)
        }
        .padding(16)
    }
```
