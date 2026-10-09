# When not to use glass (native)

Glass is a navigation-layer material. Putting it behind content makes content
harder to read, and on macOS 26 / iOS 26 it can outright fail to
render.

The forbidden-surface IDs (F1–F5) are documentary surface rules. The
audit IDs (A1, A2) are the patterns the auditor agent flags.

## F1 — Page background

A window-spanning glass surface samples the desktop wallpaper, turns
every other floating glass element into glass-on-glass automatically,
and costs the GPU a full-screen sampling pass for what reads as a
flat tint.

- failure: `.glassEffect()` on the root container, an
  `NSGlassEffectView` sized to the window.
- fix: keep the window background solid. Apply glass to the chrome on
  top (toolbar, sidebar via `NSSplitViewItem.behavior = .sidebar`,
  popover, menu).

## F2 — Long-form text containers

Body text on a sampled backdrop shimmers under scroll. Contrast drops
below WCAG AA on busy backdrops — documented on iOS 26 Lock Screen
(NN/g) and Control Center (Infinum). The system reduced-transparency
fallback is the escape hatch; if you need it, you used glass in the
wrong place.

- failure: `Text(article).background(.glass(...))`,
  `ScrollView { Text(body) }.glassEffect()`.
- fix: place body text on solid content surfaces. Chrome around the
  reading surface may be glass (Mail / Notes pattern).

## F3 — Forms and input fields

Inputs stack their own surfaces — system autocomplete, validation,
suggestion bars. Any of them landing on a glass-backed field becomes
glass-on-glass (F5).

- failure: `.glassEffect` behind a `TextField` / `SecureField` /
  `NSTextField`.
- fix: inputs stay solid. If the panel around them is glass, the
  input is a solid pill on the panel.

## F4 — Dense data tables

Tables put a contrast battle on every row before glass enters the
mix. Sampled backdrop noise destroys row boundaries where the eye
most needs an anchor.

- failure: `NSTableView` or SwiftUI `Table` with `.glassEffect()` on
  the enclosing surface.
- fix: tables are content. Render on a solid surface. Toolbar /
  inspector around the table may be glass.

## F5 — Glass-on-glass

Two glass surfaces stacked. The upper surface samples a backdrop that
is itself sampled — no real refraction, the specular line tracks
nothing meaningful. On macOS 26 / iOS 26 the inner element can fail
to render: JuniperPhoton documented a regression in iOS 26.1 where a
`Menu` inside a `GlassEffectContainer` drops its glass entirely, and
each `CABackdropLayer` costs three offscreen textures.

- failure: nested `.glassEffect`, nested `NSGlassEffectView`, glass
  popover anchored to a glass toolbar item without separating
  spacers.
- fix: group siblings with `GlassEffectContainer` (SwiftUI) /
  `NSGlassEffectContainerView` (AppKit). The container shares one
  sampling pass. For cross-distance grouping use
  `.glassEffectUnion(id:in:)`.

## Adoption context

Apple shipped Liquid Glass to a mixed reception. NN/g published a
usability takedown; Apple's removal of the
`UIDesignRequiresCompatibility` opt-out in Xcode 27 is being treated
by some developers as a forced upgrade. The kit's position: ship
Liquid Glass on the floating layer where it works, and follow the
rules above on the content layer where it doesn't.

Citations and full source URLs live in the apple-agent-kit repository's
`docs/resources.md` section N.7. Highlights:

- NN/g — Liquid Glass Is Cracked
- Infinum — Questionably accessible (Control Center, Lock Screen)
- Axess Lab — Glassmorphism meets accessibility
- JuniperPhoton — Adopting Liquid Glass: pitfalls (iOS 26.1 Menu
  regression, three offscreen textures per `CABackdropLayer`)
