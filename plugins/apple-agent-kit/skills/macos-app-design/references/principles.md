# Behavioral principles — what makes a Mac app feel like a Mac app

These principles are framework-agnostic. They apply equally to SwiftUI, AppKit, or an Electron app striving for native feel. Internalize them before writing any view code.

Distilled from working Mac apps (Linear, Raycast, Things, Arc, Fantastical, Bear, Tot) and Apple HIG.

## Core philosophy

A native app is **not a destination**. It is a **system tool** that lives where the user needs it. Design every interaction around this principle: appear when needed, get out of the way immediately after.

A Mac user has many apps open at once. They expect smooth transitions between active and inactive states. They expect the menu bar, keyboard, drag-and-drop, and Spotlight to work without surprise.

## Pre-flight checklist

Before writing any view code:

1. **Layout** — top bar for global actions, sidebar for navigation (skip if nav is minimal), center for content. Inspector on the right when contextual detail beats modality.
2. **Traffic lights** — integrate into the UI (top bar or sidebar). Never floating awkwardly over content.
3. **Window drag zone** — top ~50pt must be draggable. Keep it uncluttered.
4. **Empty states** — show them. Progressive disclosure: only reveal UI when it's useful.
5. **Keyboard shortcuts** — every primary action needs one. Every shortcut needs visual feedback when triggered (don't fire silently).
6. **Light + Dark mode** — design both. Do NOT invert colors. See `light-dark-and-accessibility.md`.
7. **Search** — always prominent and accessible. Consider a floating search field or a Cmd-K palette.
8. **Drag and drop** — content **in** AND **out** of the app. This is non-negotiable for native feel. If your content has any persistence, it has a drag representation.
9. **Micro-animations** — every state change gets a transition. No interaction without feedback. But honor `reduceMotion`.
10. **Onboarding** — brief, modal-based, teaches shortcuts **through doing** (not reading). Five clicks, not five paragraphs.

## Behavioral rules

### Progressive disclosure

Don't show UI until it's useful. Toolbar items that only apply to selection appear when there's a selection. Inspector panels reveal on demand. The view starts quiet and reveals depth as the user engages.

### Action discovery

Every action exists in at least two places:

1. The menu bar (always — the user looks here first).
2. A visible UI affordance (button, toolbar item, sidebar control) **or** a keyboard shortcut.

If only the menu bar has it, the user finds it slowly. If only the UI has it, the keyboard-driven user can't reach it. If only the keyboard has it, nobody discovers it. Two surfaces minimum.

### Drag and drop, both directions

Drag content **in** AND **out**. Both. Test:

- Can I drag a file from Finder onto the app? Does the app do the right thing?
- Can I drag content **out** of the app to Finder, Mail, Notes, another app?
- Does the drag preview look right at the cursor?

This is the single biggest "feels like Mac" signal. Don't compromise it.

### Keyboard parity

Anything mouse-clickable should be keyboard-reachable. Anything keyboard-driven should have a visible affordance for discovery. Custom hit areas need explicit focus rings — the system doesn't draw them on your behalf.

### Onboarding teaches through doing

The worst onboarding: a five-screen modal of text. The best: a guided sequence where the user clicks once per step and the app teaches a shortcut as it happens. ("Press ⌘N to create your first note.")

Skip-able. Re-enterable from Help. Never blocking.

### Settings are sparse

A native Mac app doesn't have 40 settings. It has the 5 the user actually needs and good defaults for the rest. Settings open from App → Settings (⌘,). Never reach for Settings to fix a UX problem; redesign the default.

### Window is not the app

The user closes a window. The app keeps running. Reopen from Dock, ⌘N, or clicking the Dock icon. Quit only on ⌘Q. Don't fight this — `applicationShouldTerminateAfterLastWindowClosed` returns `false` for utility-class apps; `true` for single-window-document apps. Pick deliberately.

### Respect the system

- System accent color — read it, don't override.
- System font — `-apple-system` family or `Font.system`. Don't ship Helvetica.
- Sound effects — almost never. The user has chosen silence.
- Auto-hide menu bar — works in full-screen automatically. Don't fight it.

## What "native feel" actually is

The user can't articulate it but can sense it instantly:

- Spring animations feel like the system's, not custom curves.
- Window resize is smooth, content reflows without flicker.
- Right-click on anything that selects gives a contextual menu.
- ⌘-clicking opens in a new window/tab where appropriate.
- ⌥-modifier reveals power options without dedicated UI.
- The menu bar is alive — items enable/disable to match state.
- Fonts hint correctly at every size.
- The cursor changes shape over interactive regions.

None of this is about Liquid Glass. None of it is about visuals. It's about behavior matching expectation.

## Sources

- Apple HIG — Designing for macOS, The menu bar, Going full screen, File management, Dock menus.
- Linear / Raycast / Things / Arc / Fantastical / Bear — working reference apps.
- WWDC25 session 219 (Meet Liquid Glass) — for the macOS 26 material layer on top of this.

## See also

- `menu-bar.md` — the menu bar contract.
- `keyboard-shortcuts.md` — shortcut discipline.
- `accessibility.md` — the WCAG mapping that operationalizes these principles.
- `liquid-glass/SKILL.md` — apply the macOS 26 material on top of this structure when the brief asks for it.
