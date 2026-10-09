# Anti-patterns (native)

The things to never ship, with native-specific failure modes.

## A1 — Glass on glass

Two glass surfaces stacked. On native, this happens when you wrap a
`.glassEffect`-ed view inside another `.glassEffect`, or when you put an
`NSGlassEffectView` inside another `NSGlassEffectView`. The lower surface
contributes no real refraction; the upper surface samples mostly glass.

On macOS 26 / iOS 26 the inner element can fail to render — JuniperPhoton
documented a regression in iOS 26.1 where a `Menu` inside a
`GlassEffectContainer` drops its glass entirely, and each
`CABackdropLayer` costs three offscreen textures.

Fix: use `GlassEffectContainer` (SwiftUI) / `NSGlassEffectContainerView`
(AppKit) to *group* sibling glass elements onto one sampling pass — that
is not nesting, that is sharing.

See `when-not-to-use-glass.md` F5 for citations.

## A2 — Glass behind body content

Glass behind paragraphs, articles, forms, dense tables. Text shimmers
under scroll and contrast drops below WCAG AA on busy backgrounds.
NN/g documented this on iOS 26 Lock Screen; Infinum on Control Center.

Native-specific:
- Glass behind `Text` inside a `ScrollView` — bad.
- Glass behind a `TextField` — bad. SwiftUI / AppKit text fields should be
  solid. If you need a tinted look, use `.background(.thinMaterial)` *not*
  `.glassEffect`.

See `when-not-to-use-glass.md` F2–F4 for citations.

## A3 — Invented material values

There are no published numeric blur / saturation / opacity values for
Liquid Glass. Apple renders it in real time. Do not:

- Reach for `CIFilter` or `Metal` to "tune" the look.
- Force a `.backgroundEffect(.regularMaterial)` and treat it as Liquid Glass — that's the *older* vibrancy material on Sonoma and earlier.

Use the variant API and trust the system.

## A4 — Invented component dimensions

Touch / click targets are 44 × 44 pt minimum. Button heights, paddings,
icon sizes come from `references/tokens.md`.
Do not improvise a "looks right" size.

## A5 — Capsule miscalculation

A capsule's corner radius is `height / 2`. A 44 pt tall button with a 12
pt radius is not a capsule.

Native fix: use `.buttonBorderShape(.capsule)` (SwiftUI) or
`button.borderShape = .capsule` (AppKit). Don't hand-roll a
`RoundedRectangle(cornerRadius: 12)` for a 44 pt button.

## A6 — Broken concentricity

Window outer radius = 28 pt, toolbar inner pill radius = 24 pt, inset
between them is 4 pt → 24 + 4 = 28 ✓.

Wrong: outer 28 pt, inner pill 28 pt (no inset apparent).
Wrong: outer 28 pt, inner pill 16 pt (visible "jump" where curves diverge).

SwiftUI fix: declare `.containerShape(...)` on the parent and use
`ConcentricRectangle()` on children to inherit the resolved curvature.

## A7 — Mixed Regular and Clear in one group

`GlassEffectContainer` or any sibling glass set must use one variant.
Mixing Regular and Clear in one group breaks the unified appearance.

If a Materials demo *must* show both for comparison, put them in
*different* containers / sections clearly separated, with their own
labels.

## A8 — Unreadable Clear glass

Clear glass without a dim layer behind it on rich media (photo, video,
heavy gradient) drops contrast below WCAG AA. Either:

- Add a `Color.black.opacity(0.24)` layer behind the Clear surface, or
- Switch to Regular.

If you can't guarantee a dim layer at build time (e.g. user-supplied
media), default to Regular.

## A9 — Fighting system accessibility flags

Do not implement custom reduced-transparency, reduced-motion, or
increased-contrast fallbacks for Liquid Glass — the system does this
automatically.

What this means:

- Don't query `accessibilityReduceTransparency` and swap to a solid
  background yourself for `.glassEffect`-ed views. The system already
  did it.
- Don't override `NSAccessibility.shouldDifferentiateWithoutColor` to
  re-enable transparency.

If your *own custom rendering* (a metaball, a CAEmitterLayer, etc.) needs
fallback, branch on `@Environment(\.accessibilityReduceTransparency)`.
But your custom rendering should rarely sit in the Liquid Glass layer
anyway — it belongs in content.

## A10 — Apple endorsement claims

This kit is not Apple-official. Do not ship docs, marketing copy, or
inline comments saying "Liquid Glass certified" / "Apple-official" /
"licensed by Apple". Even in jest.

The kit is inspired-by, not endorsed. That's stated in the spec, the
plugin manifests, and every README.

## macOS 26 gotchas (A11-A24)

These are macOS 26-specific failure modes that burn real engineers.
They sit alongside A1-A10 in the same audit ID space.

## A11 — Legacy `.sidebar` material retained

Keeping `NSVisualEffectMaterial.sidebar` (or the SwiftUI equivalent) on
a sidebar hierarchy *blocks* Liquid Glass. Removing it is what enables
the new material on macOS 26. Migrations often look "broken" because
the engineer left the legacy material in place.

## A12 — `.presentationBackground(.glass)` stacked on `.presentationDetents`

A sheet with `.presentationDetents` (partial detent) already renders
its background as glass. Adding `.presentationBackground(.glass)` on
top produces double glass. Pick one.

## A13 — Two `.toolbar` modifiers in different ancestors

Two `.toolbar` modifiers in different parents render two glass strips
stacked. Pick one place to declare toolbar content.

## A14 — `.glassEffect` placed mid-chain

Glass samples whatever is behind the view at the point the modifier
runs. Layout / frame / padding must run *before* `.glassEffect`. Move
`.glassEffect` to the end of the modifier chain.

## A15 — Materials wrapping the control instead of styling it

Wrapping a `Button` in `Capsule().fill(.regularMaterial)` makes the
backdrop the affordance and the button a label on top. The button
itself should be glass: `.buttonStyle(.glass)` /
`.buttonStyle(.glassProminent)`. AppKit equivalent: set
`NSButton.bezelStyle = .glass`, do not wrap in an
`NSVisualEffectView`.

## A16 — `.interactive()` on static surfaces

`.interactive()` enables press / hover / pointer-illumination. Status
pills, decorative badges, non-tappable HUDs must not carry it — it
produces phantom hover targets and confuses screen readers.

## A17 — Toggling glass by removing the modifier

Removing `.glassEffect` conditionally reflows the view. Use
`.glassEffect(condition ? .regular : .identity)` to toggle off without
layout recalc.

## A18 — Morph without `withAnimation`

`glassEffectID` + `@Namespace` only morph when the state change is
wrapped in `withAnimation(...)`. Without it the views just pop.
AppKit equivalent: wrap the change in
`NSAnimationContext.runAnimationGroup`.

## A19 — Morph across separate `GlassEffectContainer`s

Participants in different containers never morph. Move them into the
same container, or use `.glassEffectUnion(id:in:)` for cross-distance
identity.

## A20 — `GlassEffectContainer(spacing:)` set to a middle value

`spacing:` is the metaball merge threshold, not a margin. Container
`24` with HStack gap `8` renders blob-tail tension between siblings at
rest — the half-merged state that's correct during animation but
wrong as a resting visual. Pick `spacing: ≥ gap` for a fused pill,
`spacing: < gap` for separate capsules. Never in between.

## A21 — Mixed `.soft` and `.hard` scroll edge styles

Mixing `.soft` and `.hard` on adjacent edges of one scroll view
fights itself. Pick one boundary character.

## A22 — Scroll-edge effect with no overlapping chrome

Edge effects are not decoration — they hand off content to floating
chrome (toolbar, search bar). If nothing overlaps the scroll view,
strip the modifier.

## A23 — Icon + label glued into one tap target

A glyph and a label inside the same button read as one affordance
with two tap zones. Pick icon-only or label-only per button. If you
genuinely need both behaviors, give them their own affordances.

## A24 — `.glassProminent` + `.circle` border shape artifact

The prominent style can paint outside the circle. Add
`.clipShape(Circle())` *after* `.buttonStyle(.glassProminent)` when
combined with `.buttonBorderShape(.circle)`.

## B1 — Performance budget exceeded

More live-blurred surfaces in one pane than the hard ceiling (6)
allows. A `GlassEffectContainer` /
`NSGlassEffectContainerView` counts as **one** surface regardless of
children — that is the point of the container.

Fix: group siblings into one container, or downgrade non-primary
surfaces to solid. See `performance-budget.md` for the full rule,
the range (recommended 3 / busy 5 / ceiling 6), and sources.

The B-prefix is intentional: anti-patterns A1–A24 keep their meaning,
the budget rule is a separate category emitted as `[B1]` by the
reviewer.
