# Customization levels

Pick a level **per surface**, not per app. Most custom apps mix all three. Prefer the lowest level that meets the need.

## The three levels

| Level | Use for | You own | The system still owns |
|---|---|---|---|
| **1. Standard system UI** | Menus, alerts, open/save panels, Settings forms, routine forms, tables | Correct composition, labels, layout, verification on every supported macOS | Rendering, states, focus, accessibility, input |
| **2. Styled native control** | Branded buttons, toggles, segmented controls, list rows, cards that hold real controls | Visual states, contrast in light/dark/increased contrast, layout, hit area | Activation, focus traversal, accessibility role, keyboard input |
| **3. Custom interaction** | Canvases, node graphs, timelines, waveform editors, manipulation tools | Keyboard model, focus, accessibility tree, pointer and trackpad input, selection, undo, copy/paste, performance, edge cases | Almost nothing |

### Choosing

1. Can a standard control do the job with good composition? Use level 1.
2. Does the task need the identity or the layout, but the same interaction? Use level 2.
3. Does the task need an interaction no control offers (direct manipulation, spatial layout, continuous editing)? Use level 3, and write down the task benefit in one sentence. "Looks better" is not a task benefit.

Escalate one surface at a time. A level 3 canvas does not make the toolbar, sidebar, or Settings window level 3.

## Semantic controls

Keep the control. Change its appearance.

- SwiftUI: `Button`, `Toggle`, `Picker`, `TextField`, `Slider`, `Stepper`, `Menu`, `Link`, `List`, `Table`.
- AppKit: `NSButton`, `NSSwitch`, `NSPopUpButton`, `NSSegmentedControl`, `NSTextField`, `NSSlider`, `NSTableView`, `NSOutlineView`.
- Avoid `onTapGesture` on a shape as a button. It has no default keyboard activation, no button role, and no focus ring.
- Decorative effects (glow, gradient, glass) add no semantics. A glass pill with a tap gesture is still not a button.

### SwiftUI: `ButtonStyle` vs `PrimitiveButtonStyle`

| | `ButtonStyle` | `PrimitiveButtonStyle` |
|---|---|---|
| Changes | Appearance only | Appearance **and** when the action fires |
| Gets | `configuration.label`, `isPressed`, `role` | `configuration.label`, `role`, `trigger()` |
| Activation | System handles click, keyboard, accessibility | You call `trigger()`. You must keep keyboard and accessibility activation working |
| Use for | Almost every branded button | Long-press, press-and-hold, or a custom gesture that truly changes the interaction |

With a custom `ButtonStyle`, read `@Environment(\.isEnabled)`, `\.isFocused`, and `\.controlActiveState` to draw disabled, focused, and inactive-window states. Turn on Keyboard navigation in System Settings and confirm a focus indication appears.

AppKit equivalent: subclass `NSButtonCell` or set `isBordered = false` and draw in a layer, but keep it an `NSButton`.

### States to define

For each styled or custom control, define the states that apply:

`enabled · disabled · hovered · pressed · focused · selected · loading · inactive window · error`

- Hover is a hint, never the only way to see an action.
- Inactive window state matters on the Mac. Selection and accent colors dim when the window is not key.
- Loading needs a visible state and a disabled or cancellable action.

### Accessibility semantics

Provide for every control:

- **Name:** `accessibilityLabel` for icon-only controls.
- **Role:** keep the native role. Add traits (`.isButton`, `.isHeader`, `.isSelected`) only when they are missing.
- **Value:** `accessibilityValue` for toggles, sliders, progress, custom pickers.
- **Actions:** `accessibilityAction`, `accessibilityAdjustableAction` for custom increments.
- **Grouping:** `accessibilityElement(children: .combine)` or `.contain` so VoiceOver reads a row as one item when that is the task.
- **Hit target:** follow `macos-app-design/references/accessibility.md`.

`accessibilityRepresentation { ... }` lets a custom view borrow a standard control's semantics. Verify it with VoiceOver and Accessibility Inspector. Do not assume it worked.

## Mixing SwiftUI and AppKit

Mix when a specific capability requires it, not by default.

- AppKit inside SwiftUI (`NSViewRepresentable`): `NSTextView` with full text system, `NSTableView` at very large row counts, custom first-responder handling, `NSTrackingArea` details.
- SwiftUI inside AppKit (`NSHostingView`, `NSHostingController`): new panels or rows inside an existing AppKit app.
- Keep the boundary in one file per bridge. Name it after the capability, not the framework.

## Custom text editing

Treat a custom text engine as a separate project.

- Prefer `TextField`, `TextEditor`, `NSTextField`, `NSTextView` (TextKit 2), styled through attributes and the field editor.
- A custom engine must implement `NSTextInputClient` (marked text for Japanese, Chinese, Korean input; dictation; accent menu), selection and caret movement by word, line, and paragraph, undo grouping, copy/paste with rich types, spelling, Services, Writing Tools where the platform offers them, and full accessibility text APIs.
- If the requirement is "looks different", it is a styling task. Use the system text view.
