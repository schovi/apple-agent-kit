---
name: macos-app-design
description: Design and build native-feeling macOS apps in SwiftUI or AppKit. Use whenever the user asks to make a desktop app, Mac app, system utility, or anything that should look and feel like a native Mac application — including layout, menu bar conformance, multi-window scenes, keyboard shortcuts, file management, app icon, system primitives (alerts/dialogs/tooltips), light/dark mode, and accessibility. Also trigger when users mention "native feel", "Apple design patterns", "sidebar layout", "traffic lights", menu bar order, or want tools that feel like they belong on macOS. For Liquid Glass material specifically (macOS 26+ `glassEffect`, glass anti-patterns, glass performance budget), use the sibling skill `liquid-glass`.
---

# macOS app design — native craft for agents

Build interfaces that feel like they belong on the user's computer — not websites crammed into a window. A native Mac app is a **system tool** that lives where the user needs it: appear when needed, get out of the way immediately after.

This skill is glass-agnostic. Many Mac apps still support macOS 14+, and apps built with the macOS 26+ SDK get system glass on standard chrome without writing `.glassEffect`. Custom glass is a separate concern — see the sibling skill `liquid-glass` and compose it on top of the structure this skill teaches.

## When to use this skill vs `liquid-glass`

| Question | Skill |
|---|---|
| Where do menu items go? What's the required menu order? | `macos-app-design` |
| How do I do multi-window / Cmd-N / restoration? | `macos-app-design` |
| What's the keyboard shortcut for X? Which shortcuts are off-limits? | `macos-app-design` |
| Native alert vs confirmation dialog vs sheet? | `macos-app-design` |
| App icon — Icon Composer, squircle, tinted variants? | `macos-app-design` |
| WCAG label / focus / target-size / color-signal rules? | `macos-app-design` |
| Where can I put a `.glassEffect`? What's the glass budget per pane? | `liquid-glass` |
| Glass auto-degradation under `reduceTransparency`? | `liquid-glass` |
| Metal `.layerEffect` for a hero surface? | `liquid-glass` (shader subagent) |
| Branded custom UI that still behaves like a Mac app? Custom canvas? Is custom worth the cost? | `design-custom-macos-apps` |

When in doubt, both. The HIG conformance bits compose cleanly with glass.

## Required workflow

1. **Read `references/principles.md` first.** Behavior before chrome — every primary action gets a shortcut, drag content in *and* out, show empty states, progressive disclosure.
2. **Pick the framework.** SwiftUI default for new code. AppKit when the user is in existing AppKit or needs `NSStatusBar` / `NSWindowController`-grade control.
3. **Structure the shell.**
   - Three-column: `NavigationSplitView { sidebar } content: { detail } detail: { inspector }` (SwiftUI) or `NSSplitViewController` with `.sidebar` / `.inspector` behaviors (AppKit).
   - Single-column with toolbar: standard `Scene` + `.toolbar` (SwiftUI) or unified `NSToolbar`.
4. **Wire the menu bar correctly.** Required menu order, App / File / Edit / Format / View / Window / Help. See `references/menu-bar.md`.
5. **Every primary action gets a keyboard shortcut.** See `references/keyboard-shortcuts.md` for modifier conventions and what NOT to override.
6. **Use the system primitives for alerts, dialogs, tooltips.** Do not restyle. See `references/system-primitives.md`.
7. **Light + dark mode is not optional.** Design both. Do not invert colors. See `references/light-dark-and-accessibility.md`.
8. **Run the accessibility checklist** before returning: labels on every icon-only control, focus visible, hit areas per the macOS size policy (28 × 28 pt default, 20 × 20 pt floor, 24 × 24 pt for custom hit areas), color is never the only signal. See `references/accessibility.md`.

## Output rules

- Compile-ready Swift, with imports.
- Use system APIs — `.toolbar`, `.searchable`, `.keyboardShortcut`, `.help`, `.alert`, `MenuBarExtra`, `WindowGroup`. Do not hand-roll equivalents.
- Empty states matter. Show them. Empty state is a first-class screen, not an afterthought.
- Drag-and-drop in *and* out where content has any persistence semantics.
- Onboarding teaches through doing (interactive sequence), not a wall of text.

## What this skill is not

- Not iOS. The kit targets macOS; for iOS code use Apple's Xcode 27 skills.
- Not Liquid Glass material rules — see `liquid-glass`.
- Not an Apple-official design system. Build to HIG, but never claim "Apple-certified" or "Apple-endorsed".

## Reference map

- `references/principles.md` — behavioral principles (system tool, drag in/out, onboard via doing, progressive disclosure).
- `references/menu-bar.md` — anatomy, required menu order, per-menu standards (App, File, Edit, Format, View, Window, Help) and Dock menu.
- `references/file-management.md` — Save vs Duplicate vs Export, autosave dot, Quick Look, custom file browsers, Finder Sync.
- `references/windows-and-full-screen.md` — `WindowGroup` / `Window` / `DocumentGroup`, per-window toolbar, full-screen rules.
- `references/multi-window.md` — multi-window scene patterns, restoration, Cmd-N / Cmd-Shift-T / Cmd-W discipline.
- `references/keyboard-shortcuts.md` — modifier conventions, four-scope taxonomy, what NOT to override, discoverability.
- `references/menu-bar-extra.md` — `MenuBarExtra` / `NSStatusBar.statusItem`, template-image discipline, popover anti-patterns.
- `references/window-chrome.md` — outer radius, padding, titlebar heights, traffic-light alignment, `fullSizeContentView`, toolbar composition.
- `references/titlebar-accessory.md` — title-bar accessory views.
- `references/system-primitives.md` — alerts, confirmation dialogs, tooltips. Use the system; don't restyle.
- `references/icon.md` — Icon Composer, squircle grid, light / dark / tinted variants.
- `references/accessibility.md` — WCAG mapping (1.4.1 color, 2.4.7 focus, 2.5.8 target size, 4.1.2 name) and the macOS click-target size policy with SwiftUI + AppKit recipes.
- `references/light-dark-and-accessibility.md` — appearance, dynamic system color, system accent.
- `references/patterns/` — common SwiftUI structural patterns:
  - `form-rows.md`, `inset-list.md`, `disclosure-group.md`, `stepper.md`.

## Composes with

- `liquid-glass` — apply glass material to the surfaces this skill structures. Glass anti-patterns / budget / accessibility auto-degradation live there.
- `design-custom-macos-apps` — when the app needs its own visual identity: customization levels, glass strategy, maintenance cost.
- Apple's Xcode 27 skills (`swiftui-specialist`, `swiftui-whats-new-27`, `building-document-based-swiftui-applications`). They cover SwiftUI code correctness, data flow, performance, and the `Document` protocol; this skill covers HIG and Mac behavior. Prefer Apple's skill when both apply to the same API.
