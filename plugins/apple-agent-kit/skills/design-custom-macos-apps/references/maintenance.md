# Maintenance and ownership

Neither native nor custom UI is free. Assess the real ownership cost per surface. Do not claim one is universally cheaper.

## What each level costs over time

| Level | Ongoing cost |
|---|---|
| Standard system UI | Re-verify after each major macOS release. System changes (new materials, spacing, control sizes, corner radii) can break layouts that assumed old metrics. Fewer behavior bugs to own |
| Styled native control | Keep visual states in sync with new system states and appearances. Re-check contrast when system colors or materials change. Behavior mostly inherited |
| Custom interaction | Own behavior conventions as well as appearance: keyboard, focus, accessibility tree, input devices, undo, performance. Every platform behavior change becomes your work |

## Reduce the cost

- **Centralize** shared styles, tokens, and compatibility gates. One place to change when macOS changes.
- **Use flexible layout.** Avoid fixed widths for text. Let labels grow for localization and larger text sizes.
- **Use public APIs only.** No private selectors, no swizzling, no walking `NSWindow`/`NSToolbar` subviews to restyle system chrome. These break silently on OS updates.
- **Do not assume system view hierarchies.** Do not depend on the order or class of system subviews.
- **Gate by capability, not by version string.** Use `#available` / `@available`, not parsed OS versions.
- **Keep the older-OS branch alive.** Test it on a real older system or a VM while you support it. Drop it when the deployment target moves.

## Assess custom versus standard

For each surface, produce one row:

| Surface | Level | Task benefit | Behavior we own | Compatibility risk | Test plan |
|---|---|---|---|---|---|

Rate overall with:

- **Complexity:** low / medium / high.
- **Blast radius:** one view / one module / app-wide.
- **Risk:** low / medium / high (reversibility, OS-update exposure, unknowns).
- **Unknowns:** what needs a spike or a test on older systems before sizing.

Do not estimate cost from screenshots. Read the code and the deployment target first.
