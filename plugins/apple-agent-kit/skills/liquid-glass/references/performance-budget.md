# Performance budget (native)

Liquid Glass is expensive to render. Cap the number of
live-blurred surfaces an agent composes into one pane.

## Definition

A **live-blurred surface** in native code is:

- any view modified by `.glassEffect(...)` where the variant is not
  `.identity`,
- any `NSGlassEffectView`,
- `Material` and `NSVisualEffectView` with behind-window or within-window
  blending, because they are live backdrop blurs,
- the content of a `GlassEffectContainer` / `NSGlassEffectContainerView`
  — the *container* counts as one surface regardless of how many
  children it groups. That is the point of the container.

## The cap

Per top-level layout pane (sidebar / content / inspector), use these kit
defaults from observation, not Apple limits:

| Tier | Surfaces | When |
|---|---|---|
| Calm | 2–3 | Default. Mail, Notes, Finder at rest. |
| Busy | 4–5 | Transient — popover or floating HUD on screen. |
| Ceiling | 6 | Profile before exceeding this. Share sampling first. |

Numbers come from observed Apple-ship apps plus JuniperPhoton's
measurement of three offscreen textures per `CABackdropLayer` and the
iOS 26.1 regression where deep glass-on-glass drops rendering.

## Custom shaders sit alongside the budget, not inside it

`.layerEffect`, `.colorEffect`, and `.distortionEffect` (Metal-shader
surfaces — see `references/metal-shaders.md`) are **not** counted by
B1 because they are not `CABackdropLayer` instances. They have their
own cost class and their own cap:

- **One shader-driven hero surface per top-level pane.** Multiple
  shader surfaces compete for offscreen texture allocations and
  bypass Apple's shared-sampling optimization, so the per-surface
  cost is *higher* than a `.glassEffect`, not lower.
- **Never wrap a `.glassEffect` view in a shader.** That's
  snapshot-on-snapshot — folds conceptually into A1.
- **Shaders do not auto-degrade** on `accessibilityReduceTransparency`.
  Branch on the environment value and provide a fallback yourself.

The `liquid-glass-shader-implementer` subagent enforces this
when it produces shader code. The reviewer flags shader-driven heroes
that exceed one-per-pane even though B1 does not count shaders directly.

## Patterns that stay under

- **One container per logical group.** Toolbar items, stepper, HUD
  rows — all into one `GlassEffectContainer`. Cost: 1 surface.
- **Cross-distance morph** — `.glassEffectUnion(id:namespace:)` keeps two
  far-apart elements on one sample.
- **Downgrade non-primary surfaces.** A second floating panel that
  doesn't compete for attention can drop to solid (system color +
  shadow) instead of glass. Visual hierarchy improves and so does
  the budget.

## When to fail review

`apple-app-reviewer` flags a screen when:

- a single visible pane carries more than the ceiling (6) live-blurred
  surfaces without an Instruments profile on the slowest supported Mac, **or**
- the screen rests above the recommended cap (3) with no transient
  reason (no open popover / HUD / sheet).

Recommendation is a soft rule for `liquid-glass-implementer`:
if the design needs more than 3 floating elements at rest, the
implementer should propose grouping (`GlassEffectContainer`) or
downgrading before adding `.glassEffect` calls.

## Sources

- [JuniperPhoton — Adopting Liquid Glass: pitfalls](https://juniperphoton.substack.com/p/adopting-liquid-glass-experiences)
- WWDC25 session 219 — "use one glass container, not several."
- Flutter Impeller blur perf issues (Skia 6 ms vs Impeller 16–24 ms per blurred frame) inform the order-of-magnitude cost.
