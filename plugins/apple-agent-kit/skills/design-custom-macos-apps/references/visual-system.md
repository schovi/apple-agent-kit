# Visual system

Identity comes from composition, typography, color, content, and interaction. Materials and effects come last.

## Order of work

1. **Hierarchy.** What is navigation, what is an action, what is content? Make that obvious in grayscale.
2. **States.** Selected, focused, disabled, error, loading readable without color.
3. **Identity.** A few repeated cues: a type pairing, an accent, a shape language, an icon style.
4. **Effects.** Blur, shadow, material, animation. Only when 1 to 3 already work.

If a design only reads well with blur and shadow, the hierarchy is broken. Fix the hierarchy.

## Centralize tokens

Put every value in one place the whole app reads. Never scatter literals.

| Token group | Notes |
|---|---|
| Semantic colors | Name by role (`textPrimary`, `accent`, `destructive`, `separator`), not by hue. Define light, dark, and increased-contrast values. Start from system semantic colors and override only where identity needs it |
| Typography | Build on system text styles (`.body`, `.headline`, `NSFont.preferredFont(forTextStyle:)`) so system text-size settings apply where macOS supports them. Use `.monospacedDigit()` for changing numbers |
| Spacing | A small scale (for example 4, 8, 12, 16, 24). Use it for padding and gaps |
| Radii | Few values. Keep inner and outer radii concentric |
| Icon sizes | Match SF Symbols scales and control sizes |
| Elevation | A short list of shadow / layer levels with clear meaning |
| Motion | Durations and curves by purpose (appear, move, emphasize), each with a reduced-motion variant |

In SwiftUI: a `Theme` or `DesignTokens` type plus `ShapeStyle` / `Font` extensions, asset-catalog colors with appearance variants. In AppKit: `NSColor` asset-catalog colors and a shared constants type. Follow the project's existing pattern if one exists.

## Identity cues

- Use **two or three** repeated cues. More looks noisy, not distinctive.
- Give the accent one meaning (primary action or selection) and keep it.
- Make destructive actions distinct by role and wording, not only by red.
- Respect the user's system accent color unless brand identity needs a fixed accent. If you fix it, check contrast on every state.

## Layout and density

- Separate navigation (sidebar, tabs), actions (toolbar, inspector buttons), and content clearly.
- Keep a discoverable window drag region. A custom title area still needs empty, draggable space.
- Pick density by task: dense for pro tools and data, relaxed for occasional-use utilities. Use `.controlSize` instead of shrinking fonts by hand.
- Use the desktop. Wider windows should show more content or more columns, not larger padding.

## Discoverability

- Keep primary actions visible. Hover-only reveal is acceptable for secondary, repeated row actions, if a menu or keyboard path also exists.
- Label ambiguous icons. Add `.help(...)` / `toolTip` to every icon-only control.
- Mirror important actions in the menu bar so users can find them and see their shortcuts.

## State communication

- Pair color with a second signal: icon, text, shape, weight, or position.
- Make selection, focus, and hover visibly different from each other.
- Show inactive-window state: selection and accents dim when the window is not key.

## Motion

- Use motion to explain a change: where something came from, where it went, what changed.
- Keep it short. Never block input during an animation.
- Respect `accessibilityReduceMotion`: replace movement with a fade or an instant change.

## Realistic content states

Design and test each of these, with real data:

- Empty (first run, no results, filtered to nothing).
- Crowded (thousands of rows, long names, many tags).
- Loading and partial loading.
- Error and offline, with a recovery action.
- Narrow window and minimum window size.
- Long text: localized strings 30 to 50 percent longer, right-to-left languages if supported, larger system text sizes.

## Mockups

Treat generated or Figma mockups as proposals. Before implementing one, add what it lacks: focus order, keyboard path, every state above, resize behavior, and accessibility names.
