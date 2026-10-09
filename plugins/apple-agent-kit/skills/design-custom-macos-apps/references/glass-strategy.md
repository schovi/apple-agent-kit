# Glass strategy for custom designs

Liquid Glass is optional inside a custom design. Pick one strategy per app, then apply it per surface. Material rules, anti-patterns (A1–A24), the budget (B1), and forbidden surfaces (F1–F5) live in the sibling skill `liquid-glass`.

## Three valid strategies

| Strategy | What it means | Good fit |
|---|---|---|
| **Standard adoption** | Rebuild on macOS 26 SDK. System toolbars, sidebars, sheets, menus, and controls pick up glass. Add no glass yourself | Apps built mostly from system structure; teams with low design capacity |
| **Selective adoption** | Standard adoption plus glass on a few custom controls that float over content (a canvas toolbar, a playback HUD, a floating action group) | Custom apps with a clear content layer and a few overlay controls |
| **Restrained surfaces** | Keep the system chrome the OS provides. Make custom content and panels calm: opaque or classic `Material` surfaces | Dense pro tools, reading and editing apps, data-heavy views where clarity wins |

All three are legitimate. "We did not add glass" is a design decision, not a failure.

## Where identity lives

Identity lives in composition, typography, color, content, and interaction. Glass is shared by every app on the platform, so it cannot carry identity alone.

## Where glass fits and where it does not

- **Fits:** controls and navigation that float over content. Toolbars, sidebars (system-managed), floating control groups, HUDs, transient panels.
- **Keep calm:** dense reading, editing surfaces, tables, charts, visualizations, forms. Use solid or system-background surfaces.
- **Avoid:** glass on every card, glass inside glass, glass as a page background. See `liquid-glass/references/when-not-to-use-glass.md`.

## Real glass vs imitation

- Real Liquid Glass comes from system components and these APIs on macOS 26+: SwiftUI `glassEffect(_:in:)`, `.buttonStyle(.glass)` / `.glassProminent`, `GlassEffectContainer`; AppKit `NSGlassEffectView`, `NSGlassEffectContainerView`.
- `Material` (`.regularMaterial`), `NSVisualEffectView`, and custom blur are **not** Liquid Glass. Call them translucent or blurred surfaces.
- When you review an app or read a changelog, do not report "uses Liquid Glass" from a translucent look or a new icon. See `case-studies.md`.
- Check current Apple documentation for exact signatures and availability before relying on any of these. Do not assume they exist on every supported macOS version.

## Decide which layer owns the material

System toolbars, sidebars, and scroll-edge effects manage their own material on macOS 26. Conflicts look broken: double backgrounds, muddy edges, lost scroll-edge treatment.

- Do not paint a custom background behind a system toolbar or sidebar to "match the brand". Let the system own it, or own it fully with a custom surface and no system material on that layer.
- Remove legacy sidebar materials on macOS 26 so the system glass applies (`liquid-glass` A11).
- Use one toolbar owner per window (`liquid-glass` A13).
- Coordinate custom headers with scroll-edge effects: `liquid-glass/references/patterns/scroll-edge-effects.md`.

## Availability and fallback

When the deployment target is below macOS 26:

```swift
extension View {
    @ViewBuilder
    func floatingControlSurface() -> some View {
        if #available(macOS 26, *) {
            glassEffect(.regular, in: .capsule)
        } else {
            background(.regularMaterial, in: .capsule)
        }
    }
}
```

- Put every gate in one shared place (a view modifier, a style, a factory). Never scatter `#available` checks across screens.
- The fallback is a coherent older design, not a fake glass. Classic `Material` or an opaque token surface is fine.
- Test both branches. The older branch is the one users of older systems actually see.

## Accessibility and appearance checks

Check every glass or translucent surface under:

- Light and dark appearance.
- Increase Contrast.
- Reduce Transparency (system glass degrades on its own; do not fight it, `liquid-glass` A9).
- Reduce Motion (morphs and transitions).
- Changing backgrounds: scroll busy content, images, and both appearances behind the surface. Text and icons must stay readable.

## Performance

Profile effects with Instruments during scrolling, live window resize, and animation, on the slowest supported hardware. Group nearby glass in one container so it shares a sampling pass. Budget rule: `liquid-glass/references/performance-budget.md`.
