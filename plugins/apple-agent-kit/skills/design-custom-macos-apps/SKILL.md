---
name: design-custom-macos-apps
description: Plan, implement, or review a Mac app with a distinctive custom look that still behaves like a Mac app. Use when the user wants a branded or bespoke macOS UI, custom-styled controls, a custom canvas or editor, a design refresh, a decision on how much Liquid Glass to adopt in a custom design, a review of an existing custom Mac interface, or an estimate of the compatibility and maintenance cost of custom versus standard UI. Also trigger on "make it look unique but native", "custom ButtonStyle", "our own design system on macOS", or "does this custom UI break Mac conventions". For HIG conformance details (menu order, shortcuts, windows) use the sibling `macos-app-design`; for glass material rules use `liquid-glass`.
---

# Design custom macOS apps

Help the user ship a Mac app with its own identity that stays intuitive, accessible, reliable, and maintainable. Respect the project's established stack. Never mandate a SwiftUI or AppKit rewrite, and never port an iOS layout to the Mac unchanged.

## Core principle: three separate decisions

Decide each one on its own. Do not let one decide the others.

| Decision | Covers | Typical owner |
|---|---|---|
| **Technology** | SwiftUI, AppKit, or the project's existing stack | Engineering |
| **Behavior** | Keyboard, focus, selection, menus, windows, text editing, accessibility | Platform conventions |
| **Appearance** | Composition, typography, color, spacing, shape, density, motion, materials | Product identity |

- A custom appearance can keep native behavior.
- A native implementation does not guarantee good platform integration.
- Liquid Glass can live inside a custom design. It is a tool, not an identity.
- Screenshots do not show technology, performance, or maintenance cost. Never infer them from a screenshot.

## Pick the mode

| User asks for | Mode | Main output |
|---|---|---|
| "Design / plan the UI for X" | **Plan** | Brief + per-surface decision table + visual-system outline |
| "Build / restyle X" | **Implement** | Code using semantic controls + centralized styles + availability gates |
| "Review this UI / code" | **Review** | Findings mapped to `references/review-checklist.md`, with evidence level |
| "Is custom worth it? What will it cost?" | **Assess** | Ownership table from `references/maintenance.md` |

## Required workflow

1. **Inspect the project first.** Read repo instructions, existing design tokens, shared UI components, deployment target (`MACOSX_DEPLOYMENT_TARGET`, `Package.swift` `platforms`), and test setup. Reuse existing components before proposing new ones.
2. **Write the brief.** Primary workflow, audience, usage frequency, keyboard needs, information density, window type (document, single window, utility, menu bar extra, panel), accessibility needs, localization, minimum macOS. Ask only for what the repo cannot answer.
3. **Pick a customization level per surface.** Standard system UI, styled native control, or custom interaction. Prefer the lowest level that meets the need. Justify every custom interaction with a concrete task benefit. See `references/customization-levels.md`.
4. **Define the visual system.** Centralize semantic tokens. Fix hierarchy and state clarity before adding blur, shadow, or animation. See `references/visual-system.md`.
5. **Preserve Mac behavior.** Walk `references/mac-behavior.md` for every surface you customize. Skip document-window conventions for menu bar utilities and popovers.
6. **Choose a glass strategy.** Standard adoption, selective adoption, or restrained surfaces. Decide which layer owns the material. Gate every macOS 26 API and design the fallback. See `references/glass-strategy.md`.
7. **Make ownership explicit.** List what the team now owns for each custom surface. See `references/maintenance.md`.
8. **Verify working tasks, not pixels.** Run `references/review-checklist.md`. Report what you verified and how.

## Hard rules

- Keep semantic controls (`Button`, `Toggle`, `TextField`, `Picker`, `NSButton`). Restyle them. Do not replace them with gesture-only views.
- In SwiftUI, use `ButtonStyle` to change looks. Use `PrimitiveButtonStyle` only when you intend to own triggering, and then keep keyboard and accessibility activation working.
- Every essential action is reachable without hover and without a pointer.
- Never communicate essential state through a subtle color change alone.
- Never build a custom text engine for a styling goal. Style `TextField`, `TextEditor`, `NSTextView`. A custom engine is a separate engineering commitment (`NSTextInputClient`, input methods, undo, services).
- Never call a blur or translucency "Liquid Glass". Real Liquid Glass comes only from the system APIs on macOS 26+.
- Never use private APIs or walk the system view hierarchy to restyle system chrome.
- Treat generated mockups as proposals. A mockup has no focus order, no states, and no keyboard path until you design them.
- Do not expand an appearance change into an architecture change.

## Output contract

- **Plan:** the brief, a table `surface | level | reason | what we own`, a short token list, the glass strategy with fallback, and open questions.
- **Implement:** compile-ready code with imports. Shared styles in one place. `if #available(macOS 26, *)` (or `@available`) around glass APIs when the deployment target is lower.
- **Review:** findings grouped by checklist section, each with location, user impact, and fix. Prefix HIG items `HIG —` and glass items with their `liquid-glass` A/B/F code.
- **Every mode:** an evidence line. Separate "inspected source" from "built", "ran", "tested with VoiceOver", and "profiled". Never report an unverified step as passed.

## Evidence discipline

- Use `references/case-studies.md` for precedent. Cite the limitation next to the lesson.
- Do not claim a case study proves user preference or that custom looks caused an app's success.
- Separate visual taste from utility, reliability, accessibility, pricing, and interaction quality when you compare apps.
- Check current Apple documentation for API names and availability before you rely on them.

## Project-specific knowledge

This skill holds reusable guidance only. Record project facts (token file path, component library, deployment target, house rules) in the target project's own docs or agent instructions, not here.

## Reference map

- `references/customization-levels.md`: the three levels, what each one owns, semantic-control rules, SwiftUI/AppKit mixing, custom text editing.
- `references/visual-system.md`: tokens, identity cues, states, density, motion, realistic content states.
- `references/mac-behavior.md`: behavior checklist per surface, with pointers into `macos-app-design`.
- `references/glass-strategy.md`: three valid glass strategies, material ownership, availability gates, fallbacks.
- `references/maintenance.md`: ownership costs, compatibility handling, how to assess custom versus standard.
- `references/review-checklist.md`: verification checklist, regression tests, evidence levels.
- `references/scenarios.md`: worked decisions for a menu bar utility, a dense pro app, and a custom canvas.
- `references/case-studies.md`: lessons from shipping Mac apps, with sources and evidence limits.

## Composes with

- `macos-app-design`: HIG conformance (menu bar, shortcuts, windows, file management, system primitives, accessibility).
- `liquid-glass`: the macOS 26 material, its anti-patterns (A1–A24), budget (B1), and forbidden surfaces (F1–F5).
