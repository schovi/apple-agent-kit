---
name: liquid-glass
description: Build authentic macOS 26 (Tahoe) Liquid Glass surfaces in SwiftUI or AppKit. Use when the user asks to add Liquid Glass to a Mac app or write AppKit using NSGlassEffectView / NSGlassEffectContainerView. Material-focused — for HIG conformance, menu bar, multi-window, keyboard shortcuts, system primitives, app icon, or general Mac UX, use the sibling skill `macos-app-design` instead.
---

# Liquid Glass — macOS 26 material

This skill turns "build a Liquid Glass surface" into deterministic SwiftUI or AppKit code that uses the *real* Apple APIs (`.glassEffect`, `NSGlassEffectView`, `ConcentricRectangle`, `.buttonStyle(.glassProminent)`, etc.).

**Scope is the material only.** Layout primitives, menu bar conformance, multi-window scenes, keyboard shortcuts, system primitives (alerts/dialogs/tooltips), app icon, and general accessibility live in the sibling skill `macos-app-design`. Compose the two: most Mac apps need both.


## Required workflow

1. **Pick the framework.**
   - **SwiftUI** — default for new code. Modifiers: `.glassEffect`, `GlassEffectContainer`, `.backgroundExtensionEffect`, `ConcentricRectangle`, `.buttonStyle(.glass)` / `.glassProminent`, `.searchable`, `.sheet` with `.presentationDetents`, `ToolbarSpacer`, `.sharedBackgroundVisibility`.
   - **AppKit** — when the user is in an existing AppKit codebase or asks for it explicitly. APIs: `NSGlassEffectView`, `NSGlassEffectContainerView`, `NSBackgroundExtensionView`, `NSSplitViewController` with `.sidebar` / `.inspector` behaviors, `NSToolbar` unified mode, `NSButton.bezelStyle = .glass`, `NSVisualEffectView.Material` enum.
2. **Use the structural primitive.**
   - Three-column app: `NavigationSplitView { sidebar } content: { detail } detail: { inspector }` (SwiftUI) or `NSSplitViewController` with `.sidebar` / `.inspector` behaviors (AppKit).
   - Single-column app with toolbar: standard `Scene` + `.toolbar` (SwiftUI) or unified `NSToolbar`.
3. **Put glass where it belongs** — see `references/where-glass-goes.md`.
4. **Honor concentricity** — outer corner radius = inner pill radius + inset. Use `ConcentricRectangle()` + `.containerShape(...)` in SwiftUI; manual radii in AppKit.
5. **Apply tokens** — read radius, spacing, motion from `references/tokens.md`. Do not invent new values.
6. **Accessibility flags are system-driven** — AppKit / SwiftUI auto-degrade vibrancy when `reduceTransparency`, `increaseContrast`, `reduceMotion` are on. Do not fight them. (Full WCAG mapping for non-glass surfaces: `macos-app-design/references/accessibility.md`.)
7. **Avoid every anti-pattern** in `references/anti-patterns.md`.

## Output rules

- Never invent numeric blur, saturation, or opacity. Apple publishes no portable numeric values; the material is real-time rendered.
- Prefer Regular glass. Use Clear only over rich media with a dim layer behind it.
- Never put one glass surface inside another (`GlassEffectContainer` merges into ONE shared sampling pass, not nesting).
- Never put glass behind body text, forms, dense tables, or page backgrounds.
- Use the system-provided treatment — don't hand-roll a `CGAffineTransform` or layer hack to imitate Liquid Glass. If the user is on macOS < 26, the answer is "this feature requires macOS 26", not "fake it".
- Never claim "Apple-official" or "Apple-certified".

## When to refuse or downgrade

- If the user asks for "Liquid Glass on macOS 14" — refuse. Liquid Glass needs macOS 26. Do not fake it on older macOS.
- If the user asks to put glass behind a long article — refuse and propose a solid surface.
- If the user asks for Clear glass without a dim layer — silently switch to Regular.
- If the user removes `.sidebar` material expecting Liquid Glass to disappear — explain: on macOS 26, *removing* the legacy `.sidebar` material is what *enables* Liquid Glass on the sidebar.

## Self-audit before returning

Check against `references/anti-patterns.md`:

Core (A1-A10):

- A1 — glass-on-glass nesting
- A2 — glass behind body content
- A3 — invented numeric tokens
- A4 — invented component dimensions
- A5 — capsule miscalculation
- A6 — broken concentricity
- A7 — mixed Regular and Clear in one group
- A8 — unreadable Clear glass (no dim)
- A9 — fighting system accessibility flags
- A10 — Apple-endorsement claims

macOS 26 gotchas (A11-A24):

- A11 — legacy `.sidebar` material retained
- A12 — `.presentationBackground(.glass)` stacked on `.presentationDetents`
- A13 — two `.toolbar` modifiers in different ancestors
- A14 — `.glassEffect` placed mid-chain
- A15 — materials wrapping the control instead of styling it
- A16 — `.interactive()` on static surfaces
- A17 — toggling glass by removing the modifier (use `.identity`)
- A18 — morph without `withAnimation`
- A19 — morph across separate `GlassEffectContainer`s
- A20 — `GlassEffectContainer(spacing:)` set to a middle value
- A21 — mixed `.soft` / `.hard` scroll edge styles on one scroll view
- A22 — scroll-edge effect with no overlapping chrome
- A23 — icon + label glued into one tap target
- A24 — `.glassProminent` + `.circle` border shape artifact

Performance budget (`references/performance-budget.md`):

- B1 — more live-blurred surfaces per pane than the hard ceiling (6). A `GlassEffectContainer` counts as one surface; share sampling instead of stacking.

Forbidden surfaces (`references/when-not-to-use-glass.md`, review-only):

- F1 — glass on the window background
- F2 — glass behind long-form text (catches what A2 misses)
- F3 — glass behind forms / inputs
- F4 — glass behind dense tables
- F5 — glass on glass (matches A1 conceptually; cite when the issue is *where* glass goes)

## What this skill is not

- Not an Apple-official design system.
- Not a port of Apple internal rendering values — Apple publishes none.
- Not a Liquid Glass polyfill for older macOS — the APIs only exist on macOS 26.
- Not the place for HIG conformance, menu bar, file management, multi-window, keyboard shortcuts, icon, or general accessibility — see `macos-app-design`.

## Reference map

- `references/tokens.md` — radii, spacing, motion, typography tokens.
- `references/where-glass-goes.md` — layer rules and the canonical "yes / no" list.
- `references/when-not-to-use-glass.md` — F1–F5 forbidden surfaces with failure modes and external citations (NN/g, Infinum, JuniperPhoton).
- `references/performance-budget.md` — cap on live-blurred surfaces per pane (B1).
- `references/swiftui.md` — SwiftUI cheat-sheet with signatures.
- `references/appkit.md` — AppKit cheat-sheet with class / enum names.
- `references/anti-patterns.md` — the A1–A24 rule space.
- `references/example.md` — pointer to `examples/macos-native-swift/`.
- `references/accessibility.md` — glass-specific accessibility: auto-degradation table for `reduceTransparency` / `increaseContrast` / `reduceMotion`, and A9. For generic WCAG (labels, focus, target size, color signals) see `macos-app-design/references/accessibility.md`.
- `references/metal-shaders.md` — `.layerEffect` / `.colorEffect` / `.distortionEffect` recipes for hero surfaces and brand transitions when `.glassEffect` is insufficient. Used by the `liquid-glass-shader-implementer` subagent.
- `references/components/` — one focused recipe per component:
  - `popover.md`, `menu.md`, `search-field.md`, `toggle.md`, `slider.md`, `progress.md`, `badge.md`.
- `references/patterns/` — glass-specific patterns:
  - `morphing.md`, `scroll-edge-effects.md`, `floating-hud.md`, `command-palette.md`, `sidebar.md`.

Sources and maintainer provenance live in the apple-agent-kit repository's `docs/resources.md`.
