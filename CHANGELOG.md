# Changelog

## Unreleased

### Added

- **`docs/standalone/design-custom-macos-apps.md`.** Single-file version of the `design-custom-macos-apps` skill for tools without skill support. Inlines all references and the sibling-skill rules it points to. Hand-maintained copy: the skill stays the source of truth.

## 0.7.0 — native only, macOS 27, SDK-verified snippets

### Breaking

- **Web side removed.** The repo is now native Apple only: the plugin plus the Swift showcase. Deleted `prompts/` (web frosted-glass prompt), `examples/macos-web/`, `audit/` (web auditor), `spec/` and `dist/` (token spec and exports), `scripts/serve.mjs`, `kit-figma/`, `package.json`, `.claude/skills/liquid-glass-sync/`, `docs/design-system.md`, `docs/apple-prompt-comparison.md`, `docs/web-prompt.md`, `docs/quickstart.md`, `CONTRIBUTING.md`, and stray screenshots. Recover any of it from git history (commit `e6384ea`, v0.6.0).
- **Plugin is the source of truth.** Token values cited from `spec/tokens/material.yaml` are inlined in the skill references. Showcase `Tokens.generated.swift` is now hand-maintained `TokenValues.swift`.
- **`ios-app-design` stub removed.** It never triggered and held no content. iOS stays on the roadmap; for iOS code use Apple's Xcode 27 skills.
- **Web-only audit IDs retired.** A25 is gone. Native focus and accessible-name issues formerly tagged A26 / A27 are reported as `HIG — accessibility`. A1–A24, B1, F1–F5 are unchanged.

### Added

- **`design-custom-macos-apps` skill** (`plugins/apple-agent-kit/skills/design-custom-macos-apps/`). Plans, implements, reviews, and costs distinctive custom Mac UI that keeps Mac behavior. Treats technology, behavior, and appearance as separate decisions. `SKILL.md` plus references: `customization-levels.md`, `visual-system.md`, `mac-behavior.md`, `glass-strategy.md`, `maintenance.md`, `review-checklist.md`, `scenarios.md`, `case-studies.md` (Things, Bear, Craft, Fantastical, Rogue Amoeba, DaisyDisk, CleanShot, NetNewsWire, with sources and evidence limits). Composes `macos-app-design` and `liquid-glass`. No new audit IDs, no token changes.
- Skill listed in `AGENTS.md`, `README.md`, both plugin manifests, and `.claude-plugin/marketplace.json`.
- **`tools/check-swift-snippets.py`.** Typechecks every Swift block in the plugin against the installed macOS SDK (target macOS 26), stubbing names a snippet borrows from surrounding code. FAIL means API misuse. Baseline: 133 blocks, 0 fail on Xcode 27 / macOS 27 SDK.
- **macOS 27 coverage.** "macOS 27 changes" sections in `liquid-glass/references/swiftui.md` and `appkit.md`: `NSGlassEffectView.effectIsInteractive`, `effectiveCornerRadii` / `viewDidChangeEffectiveCornerRadii()`, `GeometryProxy.concentricCornerRadii`, menu item image visibility, the user's clear-to-tinted glass setting.
- `apple-app-reviewer` loads `design-custom-macos-apps` and reports custom-UI findings as `CUSTOM —`, with an evidence level.
- `docs/resources.md` § P: October 2026 verification sources.

### Fixed (API errors caught by the snippet checker)

- `glassEffectUnion(id:in:)` → `glassEffectUnion(id:namespace:)`.
- macOS-unavailable APIs removed from macOS recipes: `.navigationTransition(.zoom)`, `ToolbarItem(placement: .largeSubtitle)`, `.navigationBarLeading` / `.bottomBar` placements. `DefaultToolbarItem` kind `.sidebar` → `.sidebarToggle`.
- Nonexistent APIs replaced: `.scrollExtensionMode(.underSidebar)`, `NSScrollView.topEdgeEffect` (now `preferredScrollEdgeEffectStyle` on accessory view controllers), `NSCollectionViewCompositionalLayout.list` (now `NSTableView` `.inset` style), `NSToolbarItem.Identifier.search`, a `KeyboardShortcut` used as a view.
- Wrong signatures: `Slider(value:in:neutralValue:label:)` order, `frame(minWidth:minHeight:)` order, `NSItemBadge.indicator` is a property, `NSGlassEffectContainerView` children go in `contentView`.
- Context-dependent snippets made self-contained (toolbar identifiers, sidebar sections, search delegate, `keyDown` override).

### Changed (macOS 27 and current HIG)

- **Click targets:** 44 × 44 pt was the iOS figure. macOS policy is now 28 × 28 pt default, 20 × 20 pt floor (HIG Accessibility), custom hit areas at least 24 × 24 pt (WCAG 2.2 SC 2.5.8 AA; 2.5.5 was AAA). A4, `macos-app-design` accessibility, and the reviewer agree.
- **Window radius and sidebar:** no recipe hard-codes the window corner radius (macOS 27 tightened it). Sidebars are edge to edge on macOS 27; the 8 pt floating inset is a macOS 26 observation drawn by the system.
- **Scroll edge:** `.automatic` is the default (was documented as `.soft`). A21 follows the HIG: one style per scroll view, prefer automatic.
- **A8:** Clear-glass dimming layer 0.24 → 35% (HIG Materials). The skill no longer switches Clear to Regular silently; it says what it chose.
- **A12** rewritten: `.presentationBackground(.glass)` does not compile; the rule is now "do not override a partial-detent sheet's system glass".
- **A23** narrowed to two actions merged into one hit target; plain icon + label buttons are fine.
- **F3** narrowed to forms and data entry; a single search or command field in floating glass is allowed.
- **B1** counts classic backdrop materials too, and its numbers are labelled kit defaults that call for a profile, not Apple limits.
- **Glass on older macOS:** gate with `#available(macOS 26, *)` plus a non-glass fallback instead of refusing.
- Shader recipes apply `.layerEffect` last (`metal-shaders.md`, showcase `ShaderHeroSection.swift`).
- `macos-app-design`: Document protocol on macOS 27 (`FileDocument` deprecated), menu item images hidden by default on macOS 27, icon appearances per current HIG, Icon Composer bundled with Xcode 27, composition with Apple's Xcode 27 skills.
- Plugin, marketplace: version 0.7.0.

## 0.6.0 — rebrand + skill split (apple-agent-kit)

### Breaking

- **Repo rebranded** `liquid-glass-agent-kit` → `apple-agent-kit`. The GitHub repo URL changes; the marketplace catalogs now point at `schovi/apple-agent-kit`. The old name is retired.
- **Plugin rebranded** `liquid-glass-native` → `apple-agent-kit`. Plugin folder moved: `plugins/liquid-glass-native/` → `plugins/apple-agent-kit/`. Both Codex (`.codex-plugin/plugin.json`) and Claude (`.claude-plugin/plugin.json`) manifests updated.
- **Single skill split into two.** The former `liquid-glass-native-ui` skill is now:
  - `skills/liquid-glass/` — macOS 26 glass material only. Anti-patterns A1–A24, performance budget B1, forbidden surfaces F1–F5, tokens, accessibility auto-degradation, Metal shaders, glass-specific components and patterns.
  - `skills/macos-app-design/` — HIG conformance and Mac craft. Principles, menu bar, file management, multi-window, keyboard shortcuts, menu bar extra, window chrome, system primitives, app icon, generic WCAG accessibility, structural patterns.
  Compose the two for any non-trivial Mac app.
- **Subagent rename + reorg.**
  - `liquid-glass-native-auditor` → **removed**. Replaced by `apple-app-reviewer` (read-only, broader: covers both HIG and Liquid Glass IDs).
  - `liquid-glass-native-implementer` → `liquid-glass-implementer`. Loads both `liquid-glass` and `macos-app-design`.
  - `liquid-glass-native-shader-implementer` → `liquid-glass-shader-implementer`. Loads `liquid-glass`.
- **Slash command prefix change.** Claude Code: `/liquid-glass-native:liquid-glass-native-ui …` → `/apple-agent-kit:liquid-glass …` or `/apple-agent-kit:macos-app-design …`. Codex: `$liquid-glass-native-ui …` → `$liquid-glass …` or `$macos-app-design …`.

### Added

- **`macos-app-design` skill** — HIG and Mac craft, glass-agnostic, macOS 14+. New SKILL.md with required workflow and full reference map. New references derived from Apple HIG: `principles.md` (behavioral checklist — system tool, drag in/out, onboard via doing, progressive disclosure, every primary action has a shortcut); `menu-bar.md` (required menu order, per-menu standards for App / File / Edit / Format / View / Window / Help, Dock menus, dynamic menu items); `file-management.md` (Save vs Duplicate, autosave dot, Quick Look, custom file browsers, Finder Sync); `windows-and-full-screen.md` (`WindowGroup` / `Window` / `DocumentGroup`, full-screen rules, Window menu); `accessibility.md` (generic WCAG mapping — A26 / A27 native scopes live here); `light-dark-and-accessibility.md` (appearance, system semantic colors, increase contrast, reduce transparency). Existing references moved in: `system-primitives.md`, `icon.md`, `keyboard-shortcuts.md`, `menu-bar-extra.md`, `multi-window.md`, `window-chrome.md`, `titlebar-accessory.md`, and the non-glass structural patterns (`form-rows`, `inset-list`, `disclosure-group`, `stepper`).
- **`ios-app-design` skill placeholder** — stub for future iOS / iPadOS coverage. Description intentionally narrow so it doesn't auto-trigger.
- **`apple-app-reviewer` subagent** — read-only, replaces the former `liquid-glass-native-auditor`. Reviews both HIG conformance (with `HIG —` prefix findings) and Liquid Glass anti-patterns (A / B / F IDs).
- **Web prompt window-chrome mockup section.** `prompts/web-frosted-glass.md` gains a section on simulating real Mac windows in HTML containers: `-webkit-app-region: drag` on the top 50 px, traffic-light placement, behavioral conformance checklist (empty states, drag-and-drop in/out, keyboard parity, onboarding via doing) for full pseudo-app prompts. Cross-references the `macos-app-design` skill for real native conformance.

### Changed

- `liquid-glass/SKILL.md` — narrowed to the material. Reference map dropped non-glass entries (`system-primitives`, `icon`, and the non-glass patterns) which now live in `macos-app-design`. Added cross-skill pointer.
- `liquid-glass/references/accessibility.md` — narrowed to glass-specific auto-degradation + A9 mapping. Generic WCAG content (labels, focus, target size, color signals — including A26 / A27 native scopes) moved to `macos-app-design/references/accessibility.md`.
- `AGENTS.md` — "Native plugin layout" + "Slash command naming" + "Subagent boundaries" sections rewritten for the new structure. Order-of-operations step 6 now references both skills.
- `.claude/skills/liquid-glass-sync/SKILL.md` — paths updated; step 6 now mentions both skills; pointer to subagents updated.
- `README.md` — rewritten around the rebrand. Tagline shifted from "Mac craft toolkit / Liquid Glass headline" to "native Apple-app kit with HIG + glass". Install instructions updated.
- `package.json` — name → `apple-agent-kit`, version → `0.6.0`, description rewritten.
- Marketplace catalogs (`.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json`) — repo URL, plugin name, display name, description, tags updated.

### Migration

- **GitHub repo URL changes.** The local clone still works (you renamed the GitHub repo); existing checkouts continue to function. CI / CD references to `schovi/liquid-glass-agent-kit` need to point at `schovi/apple-agent-kit`. GitHub serves a redirect for the old URL but the marketplace entries should be updated.
- **Slash commands change.** Users who had muscle memory for `/liquid-glass-native:liquid-glass-native-ui` need to learn the new forms (see Breaking). Both Codex and Claude will need to re-install the plugin from the marketplace.
- **Subagent invocation changes.** Anyone calling `liquid-glass-native-auditor` should call `apple-app-reviewer`. Anyone calling `liquid-glass-native-implementer` should call `liquid-glass-implementer`.
- **No audit ID changes.** A1–A27, B1, F1–F5 are unchanged. Existing findings still pin to the same IDs.
- **No token / numeric changes.** All `spec/tokens/*.yaml` values are unchanged.

## 0.5.0 — T4 pass · accessibility-first framing (#12) + Mac craft beyond glass (#14)

### Added (#12 — accessibility-first Liquid Glass)

- **Accessibility is now the kit's headline rule.** Apple shipped Liquid Glass to documented WCAG-AA failures (NN/g "Liquid Glass Is Cracked", Infinum's Control Center audit, Axess Lab, 45%-adoption stat). The kit's position is the opposite: every glass surface ships the fallback ladder, the contrast film, the focus indicator, and an accessible name on every icon-only action — enforced statically through the auditor.
  - `spec/rules/accessibility-rules.md` — promoted from a short reference into the canonical headline rule. New "Why a11y is the kit's position" intro, WCAG-criterion mapping for every rule (1.4.1, 1.4.3, 1.4.11, 2.3.3, 2.4.7, 2.5.5, 4.1.2), citations (NN/g, Infinum, Axess Lab, Vidit B, Iconfactory, Geeky Gadgets), audit-ID coverage table.
  - `prompts/web-frosted-glass.md` — new "Accessibility first" paragraph immediately after the opening sentence. Existing Accessibility block expanded into the kit's headline rule with WCAG citations, A26 / A27 expectations, and explicit framing of reduced-transparency as "the escape hatch, not the design."
  - `README.md` — new "The kit's position" section right after the tagline, citing NN/g / Infinum / 45%-adoption and naming the WCAG criteria the kit enforces. Tagline updated.
  - `docs/design-system.md` — new "Position" section at the top mirroring the README. The existing "Accessibility" section expanded into the headline rule with a full WCAG-criterion → enforcement table.
- **Two new audit IDs: A26 (focus indicator) + A27 (icon-only accessible name).**
  - `audit/liquid-glass-audit.mjs` — new `checkFocusVisible` (A26) requires any CSS file with `.lg-glass` rules to declare a `:focus-visible { outline: ... }` rule (lenient: global `:focus-visible` satisfies the cascade). New `checkIconOnlyAccessibleName` (A27) scans `<button>` and `<summary>` opening tags whose class matches the kit's icon-only patterns (`lg-icon-button`, `lg-toolbar-pill__item`, `lg-floating-hud__item`, `lg-sidebar-toggle`, `lg-stepper__button`, `lg-toolbar-button`) and fires when none of `aria-label` / `aria-labelledby` / `title` is present.
  - `audit/README.md` — A26 and A27 listed in the "What it catches" section; prefix taxonomy updated to note A25–A27 are web-only.
  - `spec/rules/anti-patterns.md` — full A26 + A27 entries with WCAG mapping (2.4.7 and 4.1.2 respectively), native scope, and pointers to `accessibility-rules.md`.
  - `AGENTS.md` — audit ID prefix taxonomy line updated to enumerate A25 / A26 / A27 as web-only.
  - `spec/rules/when-not-to-use-glass.md` — the F-vs-A namespace note now lists A25 / A26 / A27 as web-only.
  - `docs/design-system.md` — Anti-patterns section heading bumped to "(A1-A10, A25-A27 web-only) and budget (B1)"; the enumeration adds A25, A26, A27 with one-line descriptions.
- **Native plugin gets a first-class accessibility reference.**
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/accessibility.md` (new) — the native side of the headline rule. Auto-degradation table (`accessibilityReduceTransparency` / `accessibilityReduceMotion` / `accessibilityDifferentiateWithoutColor` / `accessibilityIncreaseContrast` → SwiftUI + AppKit signals), `accessibilityLabel` / `accessibilityHint` examples, focus-state recipe, 44×44 hit-area recipe, color-isn't-the-only-signal recipe, native-scope mapping for A2 / A8 / A9 / A26 / A27. Cites WWDC25 session 219, Apple Accessibility Inspector, NN/g, Infinum, Axess Lab.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/SKILL.md` — reference map adds `accessibility.md` (flagged as the kit's headline rule). Self-audit "Web-only IDs" subsection expanded to enumerate A25, A26, A27 with native-scope notes.
  - `plugins/liquid-glass-native/agents/liquid-glass-native-implementer.md` — self-check now references `references/accessibility.md`; mentions A25–A27 as web-only.
  - `plugins/liquid-glass-native/agents/liquid-glass-native-auditor.md` — A9 rewritten to include the native scope of A26 (custom hit area with no focus reflection) and A27 (icon-only `Button` / `NSButton` without `accessibilityLabel`); rule-set listing notes A25 / A26 / A27 are web-only as literal IDs but have native scopes.

### Added (#14 — Mac craft beyond glass)

- **Three new Mac craft patterns** codify the conventions Linear / Raycast / Things / Arc share but Apple doesn't document in one place. Liquid Glass remains the headline; these are the rest of the chapters.
  - `spec/patterns/menu-bar-extra.md` (new) — `MenuBarExtra` / `NSStatusBar.statusItem`, `.menuBarExtraStyle(.window | .menu)`, geometry, template-image discipline, hover / animated-icon anti-patterns, global-hotkey path for `.window` style. Cites Apple HIG menu-bar chapter, Sindre Sorhus blog, Bartender.
  - `spec/patterns/multi-window.md` (new) — `WindowGroup` vs `Window` vs `DocumentGroup`, `openWindow(id:value:)`, `@SceneStorage` restoration, per-window `.toolbar` rule (sharing across scenes is A13), Cmd-N / Cmd-Shift-T / Cmd-W discipline, `applicationShouldTerminateAfterLastWindowClosed` policy. Cites WWDC22 session 10054, Apple SwiftUI / AppKit docs.
  - `spec/patterns/keyboard-shortcuts.md` (new) — modifier conventions (⌘ app, ⇧ inverse, ⌥ variant, ⌃ system, fn system), four-scope taxonomy (app / document / modal / letter-only), what NOT to override (⌘W, ⌘N, ⌘Q, ⌘H, ⌘M, ⌘\`, ⌘⇧/, ⌘,), discoverability requirements, letter-only-in-text-input pitfall. Cites Apple HIG, Raycast deep-dive, Things, Linear, Arc, Sublime / VS Code.
- **Native plugin mirrors the three patterns.**
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/patterns/menu-bar-extra.md` (new) — SwiftUI + AppKit recipes, template-image discipline, popover anti-patterns, global-hotkey path. Native scope of A27 noted.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/patterns/multi-window.md` (new) — scene-picker table, `WindowGroup(id:for:)` recipe, `NSWindowController` recipe, restoration primitives, per-window toolbar rule.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/patterns/keyboard-shortcuts.md` (new) — `keyboardShortcut(_:modifiers:)` recipe, AppKit `NSMenuItem.keyEquivalent` + `keyDown(with:)` recipe, system-wide hotkey pointers (`KeyboardShortcuts` package / Carbon).
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/SKILL.md` — reference map adds the three patterns under "Mac craft beyond glass."
- **Positioning shift in README + design-system.**
  - `README.md` tagline rewritten: "A Mac craft toolkit for AI tools. Liquid Glass is the headline … and the rest of the conventions that make a Mac app feel like a Mac app." Native delivery mode now flags "plus the broader Mac craft chapters."
  - `docs/design-system.md` — new top-level "Mac craft (beyond glass)" section with full entries for menu-bar-extra, multi-window, and keyboard-shortcuts (spec / web / native plugin / Apple API / caveats pointers).
- **Plugin manifest + marketplace catalog reframed.**
  - `plugins/liquid-glass-native/.claude-plugin/plugin.json`, `plugins/liquid-glass-native/.codex-plugin/plugin.json` — description updated: "Build authentic macOS 26 (Tahoe) Mac apps: Liquid Glass materials, NavigationSplitView, NSGlassEffectView, toolbars, Cmd-K palette, menu-bar extras, multi-window scenes, keyboard shortcuts, app icons, accessibility ladder, anti-patterns. Liquid Glass is the headline, plus the rest of the Mac craft chapters."
  - `.claude-plugin/marketplace.json` — description and tags broadened; `mac-craft` and `accessibility` added.

### Changed

- `package.json` — `"version": "0.5.0"`; description rewritten to reflect the Mac craft reframing.
- `plugins/liquid-glass-native/.claude-plugin/plugin.json`, `plugins/liquid-glass-native/.codex-plugin/plugin.json`, `.claude-plugin/marketplace.json` — version bumped 0.4.0 → 0.5.0.

### Migration

No code, API, or token renames. The audit ID namespace grew by two web-only IDs (A26, A27) — consumers running `npm run audit` against `examples/macos-web` see no new findings because the showcase already ships a global `:focus-visible { outline: ... }` rule and `aria-label` on every icon-only button. Pages that hand-roll icon-only `<button>` markup with a kit class name now need to declare `aria-label` / `aria-labelledby` / `title`; pages without any `:focus-visible` rule on a stylesheet that uses `.lg-glass` now fail A26. The renderer-tier ladder is unchanged.

The three new Mac craft patterns are additive — existing spec / showcase / native code is unaffected. The plugin description and marketplace tags broadened; users who installed `liquid-glass-native@0.4.0` will see the new patterns the next time they pull the plugin.

## 0.4.0 — T3 pass · web tier ladder (#8) + token export (#10) + Figma kit (#11) + Metal shaders (#9)

### Added (#9 — Metal shader companion for the native side)

- **Metal-shader recipes for hero surfaces.** When `.glassEffect` can't express the effect (chromatic dispersion, SDF metaball merge, head-tracked specular), the native side now has a documented path through `.layerEffect` / `.colorEffect` / `.distortionEffect`, a dedicated subagent that knows when to reach for Metal, and a working `Shader hero` section in the showcase.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/metal-shaders.md` (new) — when-to-use-which-modifier table, a minimal `lensRefract` SDF shader with dispersion + Fresnel optional extensions, the SwiftUI wiring, `maxSampleOffset` sizing rule, performance-budget rules (one shader hero per pane), reduce-transparency fallback recipe, anti-patterns (shader on top of glass, shader mid-chain, animated args without `withAnimation`), **a "SwiftPM packaging gotchas" section** (swift build doesn't compile .metal; `ShaderLibrary.bundle(.module)` vs `.default`; Xcode 26 Metal Toolchain download), citations (Victor Baro, Hacking with Swift, Inferno, Manav Kaushal, JuniperPhoton, OverShifted).
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/SKILL.md` — reference map adds `metal-shaders.md`.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/performance-budget.md` — new section "Custom shaders sit alongside the budget, not inside it" documenting the one-per-pane shader cap.
  - `plugins/liquid-glass-native/agents/liquid-glass-native-shader-implementer.md` (new) — Claude subagent. Reaches for `.glassEffect` first; only writes Metal when the brief actually needs it. Decision tree, output rules, self-check.
  - `plugins/liquid-glass-native/agents/liquid-glass-native-implementer.md` — hand-off note pointing at the new shader subagent.
  - `plugins/liquid-glass-native/agents/liquid-glass-native-auditor.md` — new "Shader-driven hero surfaces" subsection in the budget rule (flags more than one shader hero per pane, missing reduce-transparency fallback).
  - `examples/macos-native-swift/Sources/LiquidGlassShowcase/Shaders.metal` (new) — `lensRefract` SDF shader, ~20 lines, `[[ stitchable ]]`.
  - `examples/macos-native-swift/Sources/LiquidGlassShowcase/ShaderHeroSection.swift` (new) — `ShaderHeroSection` view that calls `ShaderLibrary.bundle(.module).lensRefract(...)` via `.layerEffect`, demonstrates the reduce-transparency fallback branch, and renders a high-frequency grid pattern so the rim displacement is unambiguously visible.
  - `examples/macos-native-swift/Sources/LiquidGlassShowcase/Sidebar.swift` / `ContentView.swift` / `Inspector.swift` — new `shaderHero` `SectionID` case wired into the patterns group, with an inspector surface rule.
  - `examples/macos-native-swift/Package.swift` — `Shaders.metal` declared as a `.process` resource so SwiftPM packages it into `Bundle.module`.
  - `examples/macos-native-swift/scripts/build.sh` — post-`swift build` step that compiles `Shaders.metal` → `default.metallib` via `xcrun metal` + `xcrun metallib`, dropping it into the resource bundle. Required because `swift build` does NOT invoke the Metal compiler on .metal sources (it copies them as raw resources). Prerequisite on Xcode 26: `xcodebuild -downloadComponent MetalToolchain`.
  - `examples/macos-native-swift/scripts/run.sh` — delegates to `build.sh` then `exec`s the binary directly instead of `swift run`, which would re-trigger SwiftPM's resource copy and overwrite the metallib.
  - `plugins/liquid-glass-native/agents/liquid-glass-native-shader-implementer.md` — self-check expanded to require the SPM build-script step + `Bundle.module` lookup; "What you produce" enumerates the build wiring as a deliverable.
  - `docs/design-system.md` — new "Shader hero (`.layerEffect`)" entry under Patterns.



### Added (#11 — Figma kit)

- **Figma kit derived from tokens.** Designers import `dist/tokens.tokensstudio.json` (generated alongside the other dist artifacts) via the [Tokens Studio for Figma](https://www.figma.com/community/plugin/843461159747178978/tokens-studio-for-figma) plugin and get the same numeric tokens engineers ship with. No `.fig` file lives in the repo — community Figma kits are linked as visual baselines instead.
  - `kit-figma/README.md` (new) — install recipe (Tokens Studio plugin → import → apply), round-trip recipe (designers export back; engineers translate to YAML and `npm run build:tokens` confirms), pointers to the community Figma kits (Apple macOS 26 UI Kit, the Liquid Glass Effect file, the Liquid Glass plugin, the macOS icon template), and a "frames designers should mock up" checklist.
  - `dist/tokens.tokensstudio.json` (generated by #10 above) is the file Tokens Studio reads. Token taxonomy: `radius`, `spacing`, `duration`, `easing`, `fontWeight`, `typeScale`, `glass`.
  - `AGENTS.md`, `docs/design-system.md` Delivery map, `.claude/skills/liquid-glass-sync/SKILL.md` — all reference `kit-figma/` as a first-class delivery surface.



### Added (#10 — token export pipeline)

- **Style-Dictionary-style export pipeline.** `spec/tokens/*.yaml` is now the single source. `spec/build/build-tokens.mjs` regenerates four platform-specific artifacts under `dist/`, plus a showcase mirror that the native target compiles against.
  - `spec/build/build-tokens.mjs` (new) — one-script generator. Reads YAML, emits per-target strings, writes them (or fails CI with a drift error when run with `--check`).
  - `spec/build/README.md` (new) — usage + how to extend.
  - `dist/tokens.css` (generated) — CSS custom properties.
  - `dist/Tokens.swift` (generated) — `public enum LiquidGlassTokens { Radius, Spacing, Duration, Weight, TypeScale, Glass, Budget, Tier }`.
  - `dist/tailwind.tokens.js` (generated) — Tailwind `theme.extend` object.
  - `dist/tokens.tokensstudio.json` (generated) — Tokens Studio single-file JSON (consumed by the Figma kit in #11).
  - `dist/README.md` (new) — explains the four outputs and how to regenerate.
  - `examples/macos-native-swift/Sources/LiquidGlassShowcase/Tokens.generated.swift` (generated) — `extension Tokens { ... }` that the existing showcase compiles against. Drops the hand-written value enums from `Tokens.swift` so they can never drift from the spec.
  - `examples/macos-native-swift/Sources/LiquidGlassShowcase/Tokens.swift` — keeps the namespace declaration + `enum Tokens.Easing` (Animation factory helpers) + `MaterialRole` + `concentricRadius`; numeric values now live in the generated file.
  - `examples/macos-web/styles.css` — `@import url("../../dist/tokens.css")`; the hand-written `:root` block is gone, only the showcase-local content/surface palette remains inline.
  - `package.json` — `yaml@2` dev dependency, new scripts `build:tokens` and `check:tokens`. `validate` now runs `audit && check:tokens`.
  - `AGENTS.md`, `.claude/skills/liquid-glass-sync/SKILL.md` — both flag token-value edits as triggering `npm run build:tokens`.
  - `docs/design-system.md` Delivery map — new `spec/build/` and `dist/` entries.

### Added (#8 — web renderer tier ladder)

- **Web renderer tier ladder (#8).** The web profile now exposes four named rendering tiers and a strict selection policy. The prompt picks a tier from stated browser support; renderers stamp every glass element with `data-tier="T0|T1|T2|T3"`. T0 (solid fallback) is the floor every other tier degrades to.
  - T0 — solid tint + 1 px stroke; forced under `prefers-reduced-transparency: reduce` or when `backdrop-filter` is unsupported.
  - T1 — `backdrop-filter` blur + saturate + tint (the existing default).
  - T2 — T1 plus SVG `feDisplacementMap` edge refraction (Chromium-only).
  - T3 — WebGL2 backdrop sampling with chromatic dispersion + specular.
  - `spec/tokens/material.yaml` — new `tiers.*` and `tierSelection.*` blocks.
  - `spec/rules/web-renderer-tiers.md` (new) — selection policy and per-tier behavior, with sources (kube.io, Max Geris, naughtyduk/liquidGL, rizroze/liquid-glass).
  - `spec/rules/anti-patterns.md` — new `A25 — Renderer tier missing or invalid` (web-only).
  - `audit/liquid-glass-audit.mjs` — new `checkTierDeclaration` emitting `[A25]` when a `.lg-glass` element lacks `data-tier`.
  - `audit/README.md` — A25 listed; prefix taxonomy notes A25 as web-only.
  - `prompts/web-frosted-glass.md` — new "Renderer tiers" section in the token block with the selection policy.
  - `examples/macos-web/tier.js` (new) — runtime tier picker + `applyTier` propagator.
  - `examples/macos-web/index.html` — inline SVG defs for the T2 `#lg-glass-edge` filter; `data-tier="T1"` on static glass elements.
  - `examples/macos-web/styles.css` — `[data-tier="T0|T2|T3"]` overrides keyed off the new attribute.
  - `examples/macos-web/sections.js` — `data-tier="T1"` on every emitted glass element.
  - `examples/macos-web/app.js` — `initTier()` runs after sections mount so dynamic glass is tagged.
  - `examples/macos-web/inspector.js` — new "Renderer tier" field shows the live tier (`?tier=T0|T1|T2|T3` URL param works for demo).
  - `docs/design-system.md` — new "Material — web renderer tiers (T0–T3)" entry.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/anti-patterns.md`, `.../SKILL.md`, `plugins/liquid-glass-native/agents/{auditor,implementer}.md` — A25 documented as web-only so native auditors never raise it.
  - `AGENTS.md` — prefix taxonomy adds A25 (web-only).

### Changed

- B1 budget audit and A25 tier audit both key off the same `data-tier` / `data-role` attributes; together they let consuming tools opt a surface in or out of the live-blur path without changing class names.
- The reduced-transparency `@media` block in `examples/macos-web/styles.css` is unchanged; the new `[data-tier="T0"]` selectors duplicate the override in a form the auditor can verify statically (so T0 can be tested without faking system preferences).
- `scripts/serve.mjs` — new `/dist/*` URL alias that serves the repo-root `dist/` directory regardless of the chosen web root. The web showcase imports tokens via `@import url("../../dist/tokens.css")`, which the browser resolves to `/dist/tokens.css`; without the alias the dev server's path-escape guard 404s the generated tokens.
- `.gitignore` — `*.bak` added (catches sed test artifacts).

### Migration

Existing prompt consumers that don't pass tier information continue to get T1 (the default). Pages that hand-write `.lg-glass` markup now need to stamp `data-tier="T1"` (or another tier) to satisfy A25. The auditor will flag missing tiers; add the attribute or downgrade the surface to solid.

## 0.3.0 — T2 pass (material roles, Cmd-K, app shell, icon)

### Added

- **Material role taxonomy (#7).** Each glass surface now picks a role by where it lives (sidebar, toolbar, menu, popover, hud, sheet, header, windowBackground, content) instead of just a thickness. Roles map to Apple's own SwiftUI Material + `NSVisualEffectView.Material` + macOS 26 Glass variant on the native side, and to a CSS approximation on the web side. `liveBlur: false` roles (`windowBackground`, `content`) are excluded from the B1 performance budget.
  - `spec/tokens/material.yaml` — new `roles.*` block.
  - `spec/rules/performance-budget.md` — B1 counts only `liveBlur: true` roles. Web auditor honors `data-role="windowBackground"` / `data-role="content"` opt-outs.
  - `audit/liquid-glass-audit.mjs`, `audit/README.md` — B1 filter by role.
  - `prompts/web-frosted-glass.md` — token block names the roles.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/tokens.md` — per-role API table (SwiftUI / AppKit / Glass).
  - `examples/macos-native-swift/Sources/LiquidGlassShowcase/Tokens.swift` — `enum MaterialRole` documenting each role's Apple API hint and live-blur status.
  - `docs/design-system.md` — Material — roles entry.
- **Command palette / Cmd-K (#4).** First-class pattern with geometry, motion, keyboard model, and ARIA wiring. Spec, web demo, and native demo all ship.
  - `spec/components/command-palette.yaml` (new) — geometry + material role (`hud`) + keyboard model.
  - `spec/patterns/command-palette.md` (new) — full pattern doc with native + AppKit recipes and source citations.
  - `examples/macos-web/command-palette.js` (new) — working ⌘K palette wired with focus trap, filter, ↑↓/⏎/Esc model, click-and-hover selection, focus restore.
  - `examples/macos-web/index.html`, `examples/macos-web/styles.css`, `examples/macos-web/app.js`, `examples/macos-web/sections.js`, `examples/macos-web/sidebar.js`, `examples/macos-web/inspector.js` — palette markup, styles, app wiring, showcase tile, sidebar entry, inspector metadata.
  - `examples/macos-native-swift/Sources/LiquidGlassShowcase/Patterns.swift` — new `CommandPaletteSection` with a working SwiftUI panel (`TextField` + `onKeyPress(.upArrow / .downArrow / .return / .escape)` + `.keyboardShortcut("k", modifiers: .command)`).
  - `examples/macos-native-swift/Sources/LiquidGlassShowcase/Sidebar.swift`, `examples/macos-native-swift/Sources/LiquidGlassShowcase/ContentView.swift`, `examples/macos-native-swift/Sources/LiquidGlassShowcase/Inspector.swift` — `commandPalette` `SectionID` case + DetailView wiring + inspector surface rule.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/patterns/command-palette.md` (new) — SwiftUI / AppKit recipe.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/SKILL.md` — reference map entry.
  - `spec/liquid-glass.profile.yaml` — imports `command-palette.yaml`.
  - `prompts/web-frosted-glass.md` — Patterns section adds a Cmd-K line.
  - `docs/design-system.md` — Command palette entry.
- **App shell — sidebar + window chrome (#6).** Promotes implicit numbers in the showcases to spec entries with explicit geometry (titlebar 52 / 28, traffic-light alignment to first sidebar row, sidebar 220–260 / 320, 10 inset, 28 outer radius).
  - `spec/patterns/sidebar.md` (new) — geometry + section structure + full-height sidebar pattern + anti-patterns.
  - `spec/patterns/window-chrome.md` (new) — outer radius, padding, titlebar heights, traffic-light alignment, `fullSizeContentView`, toolbar composition rules.
  - `spec/components/toolbar.yaml` — `material.role: toolbar`; `chrome:` pointer to the new window-chrome pattern.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/patterns/sidebar.md` (new) — SwiftUI `NavigationSplitView` + AppKit `NSSplitViewController` recipes.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/patterns/window-chrome.md` (new) — Mac chrome cheat-sheet.
  - `prompts/web-frosted-glass.md` — new App shell section with chrome numbers.
  - `docs/design-system.md` — Sidebar and Window chrome entries expanded with role, native plugin pointer, and caveats.
- **Mac app icon guidance (#5).** Closes the silent gap where a credible glass UI ships with a default Xcode icon.
  - `spec/rules/icon.md` (new) — Icon Composer flow, squircle grid (1024 canvas, 820 safe area), layered model, light/dark/tinted variants, common amateur mistakes.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/icon.md` (new) — native-side mirror.
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/SKILL.md` — reference map entry.
  - `prompts/web-frosted-glass.md` — out-of-scope note pointing at the spec.
  - `docs/design-system.md` — App icon section.

### Changed

- B1 budget enforcement now filters by material role. Surfaces marked `data-role="windowBackground"` or `data-role="content"` (`liveBlur: false`) no longer count. Existing showcase pages with many demo glass tiles are unaffected because they remain `liveBlur: true`.
- The native showcase's patterns group now has three entries (command-palette, morphing, scroll-edge-effects) instead of two.

### Migration

No code or API renames. Existing tokens (`glass.regular`, `glass.clear`) are unchanged; the `roles.*` block is additive. Existing showcase markup keeps working without `data-role` attributes — defaults preserve the previous audit behavior.

## 0.2.2 — T1 rule pass (criticism, budget, Apple-prompt diff)

### Added

- **Forbidden-surface rule (F1–F5) with external citations.**
  - `spec/rules/when-not-to-use-glass.md` — five forbidden surfaces (page background, long-form text, forms, dense tables, glass-on-glass) with concrete failure cases and sources (NN/g, Infinum, JuniperPhoton, Axess Lab).
  - `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/when-not-to-use-glass.md` — native mirror.
  - `spec/rules/layout-rules.md` — forbidden list now references F-codes.
  - `spec/rules/anti-patterns.md` and `plugins/.../references/anti-patterns.md` — A1 / A2 expanded with same citations.
- **Performance-budget rule (B1) with auditor enforcement.**
  - `spec/rules/performance-budget.md` and `plugins/.../references/performance-budget.md` — cap on live-blurred surfaces per pane (recommended 3 / busy 5 / ceiling 6).
  - `spec/tokens/material.yaml` — new `budget:` block.
  - `audit/liquid-glass-audit.mjs` — new `checkBudget` function emitting `[B1]` when an HTML / JS file exceeds `GLASS_BUDGET_MAX = 6`.
  - `audit/README.md` — B1 listed + audit ID prefix taxonomy (A / B / F).
- **Apple Xcode 26 system-prompt comparison report.**
  - `docs/apple-prompt-comparison.md` — diff of `artemnovichkov/xcode-26-system-prompts` against the kit; identifies gaps and "don't adopt" items.
  - `plugins/.../references/swiftui.md` — added `searchToolbarBehavior(.minimize)`, `DefaultToolbarItem(kind:placement:)`, `ToolbarSpacer(.fixed)`, `ToolbarItem(placement: .largeSubtitle)` + `.navigationSubtitle(_:)`, `scrollExtensionMode(.underSidebar)`, expanded `glassEffectUnion` with dynamic / cross-ancestor use case.
  - `plugins/.../references/appkit.md` — `NSGlassEffectView.contentView` z-order caveat, `NSGlassEffectContainerView.spacing` default-zero note.
  - `prompts/web-frosted-glass.md` — search-minimize hint, fixed-vs-flexible spacer distinction, background extension full-bleed line, budget rule line.

### Changed

- `AGENTS.md` — expanded the order-of-operations to nine surfaces (added audit/, native agents, CHANGELOG). Added an "Audit ID prefix taxonomy" section and a "Drift sweep" command list.
- `.claude/skills/liquid-glass-sync/SKILL.md` — mirrored the AGENTS.md expansion: nine sync surfaces, new sections for audit + native agents + changelog, drift sweep at the end.
- `docs/design-system.md` — added Material — performance budget entry, expanded the Toolbar entry with the new Apple toolbar APIs, expanded the Forbidden glass surfaces rule entry.

### Migration

No code or API changes. The audit ID namespace now uses three prefixes (A / B / F) but A1–A24 are unchanged. Existing findings still pin to the same IDs.

## 0.2.1 — native auditor catches up

### Changed

- `plugins/liquid-glass-native/skills/liquid-glass-native-ui/references/anti-patterns.md` — promoted the unlabeled "Bonus — macOS 26 gotchas" section to formal IDs **A11–A24**, one heading per gotcha (legacy `.sidebar` material, `.presentationBackground(.glass)` + detents, double `.toolbar`, `.glassEffect` mid-chain, materials wrapping controls, `.interactive()` on static surfaces, conditional removal vs `.identity`, morph without `withAnimation`, morph across containers, `GlassEffectContainer(spacing:)` middle value, mixed `.soft`/`.hard` scroll edges, edge effect without chrome, icon + label glued, `.glassProminent` + `.circle` clip).
- `plugins/liquid-glass-native/skills/liquid-glass-native-ui/SKILL.md` — extended the self-audit checklist with A11–A24.
- `plugins/liquid-glass-native/agents/liquid-glass-native-auditor.md` — rewrote "What to check" to enumerate all 24 anti-patterns with concrete code signals, added a `FW —` prefix for framework-hygiene findings that have no A-ID, and updated the report format.

### Migration

No code or API changes — the audit ID space just grew. Existing
findings keyed to A1–A10 are unchanged.

## 0.2.0 — prompt-first pivot

### Changed

- **Repositioned the web side as a portable prompt, not a plugin.** Anyone targeting web Liquid Glass UI now pastes `prompts/web-frosted-glass.md` into their AI tool (ChatGPT, Claude web, Cursor, v0, Lovable, Figma Make, Bolt, Windsurf, JetBrains AI, Xcode AI, Claude Code, Codex). One artifact, every tool.
- The native side stays a Codex + Claude Code plugin (`plugins/liquid-glass-native/`). Skill-supporting tools are where native devs work, so a plugin keeps the multi-file reference loading that makes the native skill effective.
- Web prompt header reframed: it now declares itself a **frosted-glass approximation**, not a render of native Liquid Glass.

### Added

- `audit/` — standalone web audit CLI. The audit script that used to live inside the web plugin is now a top-level tool: `node audit/liquid-glass-audit.mjs <path>` or `npm run audit`.
- `audit/README.md` — documents the checks and known gaps.
- `docs/web-prompt.md` — usage guide for the portable web prompt.

### Removed

- `plugins/liquid-glass-web/` — the entire web plugin (skills, agents, Codex + Claude manifests).
- `docs/install-copy-paste.md` — superseded by `docs/web-prompt.md`.

### Migration

If you previously installed the web plugin:

- **Codex / Claude Code users:** uninstall `liquid-glass-web`. For web tasks, paste `prompts/web-frosted-glass.md` instead.
- **CI users running the audit script:** the path moved. Update `node plugins/liquid-glass-web/skills/liquid-glass-web-ui/scripts/audit-liquid-glass-html.mjs ...` to `node audit/liquid-glass-audit.mjs ...` or `npm run audit`.
- **The native plugin is unchanged.** Install paths, slash commands, and subagent names are identical.

## 0.1.1 — native sibling

### Added

- `plugins/liquid-glass-native/` — sibling plugin for native macOS Liquid Glass UI (SwiftUI / AppKit). Ships its own canonical skill `liquid-glass-native-ui` and two Claude subagents.
- `examples/macos-native-swift/` — SwiftUI showcase app exercising the native skill.
- `examples/macos-web/` — HTML/CSS showcase of macOS-style glass on the web (replaces the prior `macos-showcase`).
- `docs/resources.md` — collected external references.

### Changed

- **Renamed the existing UI plugin** to disambiguate from the new native plugin:
  - `plugins/liquid-glass-ui/` → `plugins/liquid-glass-web/`
  - Plugin name `liquid-glass-ui` → `liquid-glass-web`
  - Claude command `/liquid-glass-ui:liquid-glass-web-ui` → `/liquid-glass-web:liquid-glass-web-ui` (Codex `$liquid-glass-web-ui` unchanged).
  - Agents: `liquid-glass-auditor` → `liquid-glass-web-auditor`; `liquid-glass-implementer` → `liquid-glass-web-implementer`.
  - Plugin descriptions now make the *web* scope explicit and point at the native sibling.
- Marketplace catalogs (`.agents/plugins/marketplace.json`, `.claude-plugin/marketplace.json`) list both plugins.
- `npm run validate` now audits `examples/macos-web` (the new canonical web example).

### Removed

- `examples/vanilla-html/` — superseded by `examples/macos-web/`.

## 0.1.0 — initial v0.1 (commit 30782ef)

- Canonical spec (`spec/`).
- Single shared plugin `plugins/liquid-glass-ui/` (Codex + Claude, no duplication).
- Web canonical skill `liquid-glass-web-ui` with references and audit script.
- Two Claude subagents (auditor, implementer).
- Marketplace catalogs, copy/paste prompt, vanilla-html example, docs.
