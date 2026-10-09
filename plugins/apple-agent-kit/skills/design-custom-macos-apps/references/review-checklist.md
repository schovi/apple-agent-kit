# Review checklist

Verify that people can complete real tasks. Pixel accuracy comes last.

## Checklist

### 1. Primary task

- [ ] A new user finds the primary action without hover and without docs.
- [ ] The primary action is in the menu bar with a shortcut.
- [ ] Navigation, actions, and content are distinct at a glance.

### 2. Keyboard and focus

- [ ] The primary task completes with the keyboard only (Keyboard navigation on).
- [ ] Focus is visible on every focusable element, including styled controls.
- [ ] Return triggers the default action. Escape cancels or closes.
- [ ] Tab order follows the visual order.

### 3. States

- [ ] Selected, focused, hovered, pressed, disabled, loading, error, and inactive-window states are defined and distinct.
- [ ] No essential state relies on color alone.
- [ ] Empty, crowded, loading, error, and offline states exist with real data.

### 4. Accessibility

- [ ] VoiceOver reads a correct name, role, and value for every control.
- [ ] Custom views expose elements and actions (`accessibilityRepresentation`, `accessibilityChildren`, `NSAccessibilityElement`), verified with VoiceOver or Accessibility Inspector.
- [ ] Increase Contrast, Reduce Transparency, and Reduce Motion produce a usable result.
- [ ] Hit targets follow `macos-app-design/references/accessibility.md`.

### 5. Layout and content

- [ ] Minimum window size, narrow window, and large window all work.
- [ ] Long labels, localized strings, and larger text sizes do not clip or overlap.
- [ ] Realistic data volume (not three sample rows).

### 6. Appearance and materials

- [ ] Light and dark appearance both read well.
- [ ] Text over glass or translucent surfaces stays readable over changing content.
- [ ] Glass passes `liquid-glass` A/B/F checks. Fallback works on the oldest supported macOS.

### 7. Performance

- [ ] Scrolling, live resize, and animation stay smooth with representative content.
- [ ] Profiled on the slowest supported hardware, not only on the dev machine.

### 8. Platform behavior

- [ ] Menus, Settings, Find, Cmd-W, Cmd-Q behave correctly for the window type.
- [ ] Dialogs and alerts are system components.
- [ ] Text editing supports selection, copy/paste, undo, and input methods.
- [ ] Context menus match menu and toolbar actions.

## Regression tests

Write tests where behavior is at risk:

- Model and view-model logic behind custom interaction (selection, undo, graph edits, keyboard commands).
- Accessibility element generation for custom views (count, labels, roles).
- UI tests (`XCUITest`) for keyboard paths through the primary task.
- Availability branches: the logic that picks a fallback.

Do not write tests that only repeat visual constants (a test that asserts `cornerRadius == 12`). They break on every design change and catch nothing.

## Evidence levels

Report what you actually did. Use these levels and never upgrade one:

| Level | Meaning |
|---|---|
| **Inspected** | Read the source. No build |
| **Built** | Compiled for the deployment target |
| **Ran** | Launched and looked at it |
| **Interacted** | Completed the task with keyboard and pointer |
| **Assistive tech** | Tested with VoiceOver and accessibility settings |
| **Profiled** | Measured with Instruments on named hardware |

When macOS execution is not available, say so. Report findings as "inspected only" and list build, interaction, accessibility, and performance as unverified.
