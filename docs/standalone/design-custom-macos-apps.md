# Design custom macOS apps (single-file edition)

Use when: planning, building, reviewing, or costing a Mac app with a distinctive custom look that must still behave like a Mac app. Triggers: branded or bespoke macOS UI, custom-styled controls, custom canvas or editor, design refresh, "how much Liquid Glass", "unique but native", custom `ButtonStyle`, "our own design system on macOS", "does this custom UI break Mac conventions".

Goal: a Mac app with its own identity that stays intuitive, accessible, reliable, and maintainable. Respect the project's existing stack. Never mandate a SwiftUI or AppKit rewrite. Never port an iOS layout to the Mac unchanged.

## 1. Three separate decisions

| Decision | Covers | Owner |
|---|---|---|
| Technology | SwiftUI, AppKit, or the existing stack | Engineering |
| Behavior | Keyboard, focus, selection, menus, windows, text editing, accessibility | Platform conventions |
| Appearance | Composition, type, color, spacing, shape, density, motion, materials | Product identity |

- Decide each on its own. A custom appearance can keep native behavior. Native code does not guarantee good platform integration.
- Liquid Glass is a tool, not an identity.
- A screenshot never shows technology, performance, or maintenance cost.

## 2. Modes

| User asks | Mode | Output |
|---|---|---|
| "Design / plan X" | Plan | Brief, table `surface / level / reason / what we own`, short token list, glass strategy with fallback, open questions |
| "Build / restyle X" | Implement | Compile-ready code with imports. Shared styles in one place. `if #available(macOS 26, *)` around glass APIs when the target is lower |
| "Review this" | Review | Findings per checklist section (§9): location, user impact, fix. Prefix HIG items `HIG —` |
| "Is custom worth it?" | Assess | Ownership table (§8) |

Every mode ends with an **evidence line** (§9 evidence levels). Never report an unverified step as passed.

## 3. Workflow

1. **Inspect the project.** Repo instructions, existing tokens, shared components, deployment target (`MACOSX_DEPLOYMENT_TARGET`, `Package.swift` `platforms`), tests. Reuse before you add.
2. **Write the brief.** Primary workflow, audience, frequency of use, keyboard needs, density, window type (document, single window, utility, menu bar extra, panel), accessibility, localization, minimum macOS. Ask only what the repo cannot answer.
3. **Pick a customization level per surface** (§4). Lowest level that meets the need.
4. **Define the visual system** (§5). Hierarchy and states before effects.
5. **Preserve Mac behavior** (§6) on every customized surface.
6. **Pick a glass strategy** (§7). Gate macOS 26 APIs, design the fallback.
7. **Make ownership explicit** (§8).
8. **Verify tasks, not pixels** (§9).

## 4. Customization levels

Pick per surface, not per app.

| Level | Use for | You own | System owns |
|---|---|---|---|
| 1. Standard system UI | Menus, alerts, open/save panels, Settings, routine forms, tables | Composition, labels, layout, re-verify per macOS release | Rendering, states, focus, accessibility, input |
| 2. Styled native control | Branded buttons, toggles, segmented controls, list rows, cards with real controls | Visual states, contrast (light/dark/increased contrast), hit area | Activation, focus traversal, a11y role, keyboard |
| 3. Custom interaction | Canvases, node graphs, timelines, waveform editors | Keyboard model, focus, a11y tree, pointer/trackpad, selection, undo, copy/paste, performance, edge cases | Almost nothing |

Choosing: standard control works → 1. Same interaction, different look/layout → 2. Interaction no control offers (direct manipulation, spatial layout, continuous editing) → 3, with a one-sentence task benefit. "Looks better" is not a task benefit. A level-3 canvas does not make the toolbar or Settings level 3.

**Semantic controls: keep the control, change the look.**
- SwiftUI: `Button`, `Toggle`, `Picker`, `TextField`, `Slider`, `Stepper`, `Menu`, `Link`, `List`, `Table`.
- AppKit: `NSButton`, `NSSwitch`, `NSPopUpButton`, `NSSegmentedControl`, `NSTextField`, `NSSlider`, `NSTableView`, `NSOutlineView`.
- No `onTapGesture` on a shape as a button: no keyboard activation, no role, no focus ring. A glass pill with a tap gesture is still not a button.
- `ButtonStyle` = appearance only (gets `label`, `isPressed`, `role`; system handles activation). Use it for almost every branded button.
- `PrimitiveButtonStyle` = you own triggering via `trigger()`. Only for long-press or a truly different gesture, and keep keyboard and a11y activation working.
- In a custom `ButtonStyle`, read `@Environment(\.isEnabled)`, `\.isFocused`, `\.controlActiveState`. Turn on Keyboard navigation and confirm focus shows.
- AppKit: subclass `NSButtonCell` or `isBordered = false` plus a layer, but keep it an `NSButton`.

**States to define:** enabled, disabled, hovered, pressed, focused, selected, loading, inactive window, error. Hover is a hint only. Selection and accent dim when the window is not key. Loading needs a visible state and a disabled or cancellable action.

**Accessibility per control:** label (icon-only controls), native role (add traits only if missing), `accessibilityValue` (toggles, sliders, progress, custom pickers), `accessibilityAction` / `accessibilityAdjustableAction`, grouping via `accessibilityElement(children: .combine/.contain)`. `accessibilityRepresentation { }` borrows a standard control's semantics; verify with VoiceOver and Accessibility Inspector.

**Mixing frameworks:** only for a specific capability. `NSViewRepresentable` for full `NSTextView`, huge `NSTableView`, first-responder control, `NSTrackingArea`. `NSHostingView` / `NSHostingController` for SwiftUI in AppKit. One bridge per file, named by capability.

**Custom text engine = separate project.** Style `TextField`, `TextEditor`, `NSTextField`, `NSTextView` (TextKit 2) instead. A custom engine must do `NSTextInputClient` (CJK marked text, dictation, accent menu), word/line/paragraph movement, undo grouping, rich copy/paste, spelling, Services, Writing Tools, full a11y text APIs.

## 5. Visual system

Order: **hierarchy** (readable in grayscale) → **states** (readable without color) → **identity** (2-3 repeated cues) → **effects** (blur, shadow, material, motion). If it only reads with blur and shadow, fix the hierarchy.

**Centralize tokens** in one type the whole app reads (SwiftUI `Theme`/`DesignTokens` plus `ShapeStyle`/`Font` extensions and asset-catalog colors; AppKit `NSColor` assets plus a constants type). Follow the existing pattern if one exists.
- Colors by role (`textPrimary`, `accent`, `destructive`, `separator`), with light, dark, increased-contrast values. Start from system semantic colors.
- Type on system text styles (`.body`, `.headline`, `NSFont.preferredFont(forTextStyle:)`). `.monospacedDigit()` for changing numbers.
- Spacing scale (4, 8, 12, 16, 24). Few radii, concentric inner/outer. Icon sizes match SF Symbols scales. Short elevation list. Motion by purpose, each with a reduced-motion variant.

**Identity:** accent has one meaning (primary action or selection). Destructive = role plus wording, not just red. Respect the system accent unless brand needs a fixed one; then check contrast on every state.

**Layout:** separate navigation, actions, content. Keep an empty draggable window region. Density by task (dense for pro tools, relaxed for occasional utilities); use `.controlSize`, not hand-shrunk fonts. Wider windows show more content, not more padding.

**Discoverability:** primary actions always visible. Hover-reveal only for secondary row actions that also have a menu or shortcut. `.help(...)` / `toolTip` on every icon-only control. Mirror important actions in the menu bar.

**State:** pair color with icon, text, shape, weight, or position. Selection, focus, hover look different from each other.

**Motion:** explains a change, stays short, never blocks input. Respect `accessibilityReduceMotion` (fade or instant).

**Content states to design with real data:** empty, crowded (thousands of rows, long names), loading/partial, error/offline with recovery, narrow and minimum window, long text (+30-50% localization, RTL if supported, larger text).

**Mockups are proposals.** Add focus order, keyboard path, all states, resize behavior, a11y names before building.

## 6. Preserve Mac behavior

**Match the window type:**

| Window type | Expected | Not expected |
|---|---|---|
| Document app | File menu, New/Open/Save/Duplicate, autosave, Window menu, tabs, restoration | n/a |
| Single-window (library, shoebox) | Full menu bar, Find, Settings, Cmd-W closes window without losing data | Document Save flow |
| Menu bar extra / popover | Escape closes, focus lands inside, Settings entry, Quit entry when no Dock icon | File menu, Cmd-N, multi-window, restoration |
| Utility panel / HUD | Floats, does not steal key status unless it takes input, Escape closes | Own full menu bar |

**Checklist:**
- **Menus/shortcuts:** standard menu order (App, File, Edit, Format, View, app-specific, Window, Help; omit unused). Every primary action has a menu item and shortcut. Never override system shortcuts. Cmd-, Settings (SwiftUI `Settings` scene). Cmd-F/Cmd-G when searchable. Cmd-W closes, Cmd-Q quits, neither loses data silently.
- **Windows:** sensible minimum size, resize, full screen. Traffic lights visible and aligned with a custom title area. Multi-window and restoration where the app type needs them. Draggable region with a hidden title bar: `isMovableByWindowBackground`, `mouseDownCanMoveWindow`, or SwiftUI `WindowDragGesture` (check availability).
- **Keyboard/focus:** Tab/Shift-Tab reach every control with Keyboard navigation on (`NSApplication.isFullKeyboardAccessEnabled` in AppKit). Visible focus on every focusable element; draw your own ring if a style hides the system one. Return = `.keyboardShortcut(.defaultAction)`, Escape = `.cancelAction` / `onExitCommand`. SwiftUI: `@FocusState`, `.focusable()`, `.focusSection()`, `.onKeyPress` (check availability), `.onMoveCommand`.
- **Lists:** arrows move selection, Shift extends, Cmd toggles, Cmd-A, type-select. Use `List(selection:)`, `Table`, `NSTableView`, `NSOutlineView` before building a custom list. Delete removes when safe and undoable.
- **Text/clipboard/undo:** fields support selection, Services, spelling, input methods, Edit menu. Copy/paste in useful types (plain text plus rich/custom). Every edit undoable via the window's `UndoManager` with action names. Context menus match toolbar and menu actions.
- **Files/drag/preview:** `fileImporter`/`fileExporter`/`NSOpenPanel`/`NSSavePanel`. Drag in and out (`Transferable`, `draggable`, `dropDestination`). Space bar Quick Look where useful.
- **System primitives:** alerts, confirmation dialogs, tooltips stay system components.
- **Menu bar extras:** template image for the status item, sensible popover size, Quit item when there is no Dock icon.

## 7. Glass strategy

Pick one per app, apply per surface.

| Strategy | Meaning | Fit |
|---|---|---|
| Standard adoption | Build on macOS 26+ SDK; system chrome gets glass; add none yourself | Mostly system structure, low design capacity |
| Selective adoption | Standard plus glass on a few custom controls floating over content (canvas toolbar, playback HUD) | Clear content layer with a few overlays |
| Restrained surfaces | System chrome as provided; custom content opaque or classic `Material` | Dense pro tools, reading/editing, data-heavy views |

All three are valid. "We did not add glass" is a design decision.

- **Fits:** controls floating over content: toolbars, system sidebars, floating control groups, HUDs, transient panels.
- **Keep calm:** reading, editing, tables, charts, forms. Solid or system-background surfaces.
- **Avoid:** glass on every card, glass inside glass, glass as a page background, glass as the only carrier of identity.

**Real vs imitation.** Real Liquid Glass = system components plus macOS 26+ APIs: SwiftUI `glassEffect(_:in:)`, `.buttonStyle(.glass)` / `.glassProminent`, `GlassEffectContainer`; AppKit `NSGlassEffectView`, `NSGlassEffectContainerView`. `Material`, `NSVisualEffectView`, custom blur are **not** Liquid Glass; call them translucent or blurred. Never report "uses Liquid Glass" from a translucent look, a changelog, or a new icon. Check current Apple docs for signatures and availability.

**Material ownership.** System toolbars, sidebars, and scroll-edge effects own their material on macOS 26+ (macOS 27 added edge-to-edge sidebars and harder scroll-edge under titles). Conflicts = double backgrounds, muddy edges, lost scroll-edge.
- Never paint a brand background behind a system toolbar or sidebar. Let the system own the layer, or own it fully with no system material.
- Remove legacy sidebar material (`NSVisualEffectMaterial.sidebar` or the SwiftUI equivalent) on macOS 26+ so system glass applies.
- One toolbar owner per window.
- Coordinate custom headers with scroll-edge effects.

**Availability and fallback** (deployment target below 26):

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

- All gates in one shared place (modifier, style, factory). No scattered `#available`.
- Fallback = coherent older design (classic `Material` or opaque token surface), never fake glass.
- Test both branches; older-OS users see the fallback.

**Check every glass/translucent surface under:** light and dark; Increase Contrast; Reduce Transparency (system glass degrades itself, do not fight it); Reduce Motion; the user's Liquid Glass clear-to-tinted setting (custom translucent surfaces do not follow it, check both ends); busy changing content behind it, text stays readable.

**Performance:** profile scrolling, live resize, animation in Instruments on the slowest supported hardware. Group nearby glass in one container. Keep live-blur surfaces per pane few.

## 8. Maintenance and ownership

Neither native nor custom is free. Assess per surface.

| Level | Ongoing cost |
|---|---|
| Standard | Re-verify each major macOS. New materials, spacing, control sizes, radii break layouts that assumed old metrics |
| Styled native | Keep states in sync with new system states/appearances; re-check contrast |
| Custom interaction | Own keyboard, focus, a11y tree, input devices, undo, performance; every platform change is your work |

Reduce cost: centralize styles, tokens, gates. Flexible layout, no fixed text widths. Public APIs only (no private selectors, swizzling, walking `NSWindow`/`NSToolbar` subviews). Never depend on system subview order or class. Gate with `#available`, not parsed version strings. Keep the older-OS branch tested on a real older system or VM until the target moves.

**Assess table**, one row per surface:

| Surface | Level | Task benefit | Behavior we own | Compatibility risk | Test plan |
|---|---|---|---|---|---|

Overall: complexity (low/med/high), blast radius (one view / module / app-wide), risk (low/med/high), unknowns (what needs a spike first). Never estimate from screenshots; read code and the deployment target.

## 9. Review checklist

1. **Primary task:** found without hover or docs; in the menu bar with a shortcut; navigation/actions/content distinct.
2. **Keyboard/focus:** keyboard-only completion; visible focus everywhere; Return default, Escape cancel; Tab order = visual order.
3. **States:** all states defined and distinct; nothing essential by color alone; empty/crowded/loading/error/offline with real data.
4. **Accessibility:** VoiceOver name/role/value per control; custom views expose elements and actions (`accessibilityRepresentation`, `accessibilityChildren`, `NSAccessibilityElement`), verified; Increase Contrast, Reduce Transparency, Reduce Motion usable; adequate hit targets.
5. **Layout/content:** min, narrow, large windows; long and localized labels, larger text do not clip; realistic data volume.
6. **Appearance/materials:** light and dark; text over glass readable over changing content; glass follows §7; fallback works on oldest supported macOS.
7. **Performance:** smooth scroll, resize, animation with real content; profiled on slowest supported hardware.
8. **Platform behavior:** menus, Settings, Find, Cmd-W, Cmd-Q right for window type; system dialogs; text selection, copy/paste, undo, input methods; context menus match menu/toolbar.

**Regression tests:** model/view-model logic behind custom interaction (selection, undo, graph edits, key commands); a11y element generation (count, labels, roles); `XCUITest` keyboard paths through the primary task; availability fallback logic. No tests that restate visual constants (`cornerRadius == 12`).

**Evidence levels** (report the real one, never upgrade): Inspected (read source) → Built → Ran → Interacted (keyboard and pointer) → Assistive tech (VoiceOver plus a11y settings) → Profiled (Instruments, named hardware). Without macOS execution, say "inspected only" and list the rest as unverified.

## 10. Hard rules

- Keep semantic controls; restyle them. No gesture-only replacements.
- Every essential action reachable without hover and without a pointer.
- No essential state by subtle color change alone.
- No custom text engine for a styling goal.
- Never call blur or translucency "Liquid Glass".
- No private APIs, no walking system view hierarchies to restyle chrome.
- Mockups have no focus order, states, or keyboard path until you design them.
- An appearance change never becomes an architecture change.
- Never claim output is Apple-official or Apple-certified.
- Record project facts (token paths, component library, target) in the project's own docs, not in this guide.

## 11. Worked scenarios (patterns, not templates)

**A. Menu bar clipboard utility, no Dock icon, target macOS 14, strong brand.**
Status item L1 (template image, `MenuBarExtra` + `.menuBarExtraStyle(.window)`). History L2 (`List(selection:)`, styled rows, arrows and type-select kept). Row actions L2 (real `Button`s with `ButtonStyle`, visible on selected row, plus context menu and shortcuts). Settings L1 (`Settings` scene, `Form`). Identity via accent, one header typeface, icon style. Behavior: focus in search on open, Return pastes, Escape closes, Cmd-, Settings, Quit item in panel; no File menu, Cmd-N, restoration. Glass: standard; no extra background in the panel; any floating group gated to 26 with plain-row fallback. Verify on 14 and 26.

**B. Dense log/metrics analyzer, keyboard-heavy, target macOS 15.**
Sidebar/toolbar L1 (`NavigationSplitView`, system toolbar, glass applies on its own). Log table L1-2 (`Table` or `NSTableView` for huge counts, compact `.controlSize`, monospaced digits). Severity L2 (icon + text + color). Inspector L1. Charts L2 (Swift Charts, token colors, opaque). Glass: restrained; nothing on rows, cards, charts, inspector body. Behavior: full table keyboard nav, Cmd-F, Cmd-C copies rows as text, row context menus, inactive-window selection, persisted sort/resize. Verify 100,000 rows scroll and live resize in Instruments on the slowest Mac; Increase Contrast on severity; long localized headers.

**C. Node-graph audio editor on an infinite canvas, target macOS 14.**
Canvas L3 (benefit: spatial signal wiring has no standard control). Node titles and parameters L1 (real `TextField`/`NSTextField` overlays). Floating canvas toolbar L2 (real buttons, glass on 26 via one gated modifier, `Material` fallback). Inspector, menus, Settings L1. Team owns: selection (click, Shift/Cmd extend, marquee, Cmd-A, Escape clears); keyboard (Tab between nodes, arrows move, Shift for bigger steps, menu command to connect ports without dragging, Delete, Cmd-+/-/0 zoom); focus ring distinct from selection; a11y element per node and connection, connections described in words ("Gain output connected to Filter input"); `UndoManager` grouped per gesture with names; clipboard as custom type plus text; trackpad pinch/scroll, wheel, port cursors; culling, profile 1,000 nodes during drag and zoom. Glass: selective (toolbar and transient HUDs only). Tests: graph model, selection, undo; a11y list matches graph; keyboard-only UI test building a small graph.

## 12. Case studies (precedent, not proof)

Rules: precedent for a decision, not proof it is right. A small opinionated sample, not user preference. Never claim a custom look caused success. Posts rarely name APIs; do not infer API adoption. Sources checked October 2026; re-check before quoting.

| App | Lesson | Limit |
|---|---|---|
| Things | Custom layout and platform materials coexist ("touch of glass in the sidebar", glassy buttons; toolbar is not `NSToolbar`) | Never says "Liquid Glass" or names APIs |
| Bear | Similar look ≠ full adoption ("a UI similar to Liquid Glass but without adopting it entirely"); themes and system materials can conflict | Forum reply not marked staff |
| Craft (OS 27) | Controls change, content stays the focus; sidebars sit on the window surface | macOS 27 only |
| Fantastical | Domain UI inside platform materials; adoption can be revised (glass toolbars on 26, old sidebar look back on 27) | Calendar grid not discussed |
| Rogue Amoeba SoundSource 6 | Selective adoption for clarity: rejected "less compact and less legible" glass, accepted concentric shapes | One developer's rationale, no user outcomes |
| DaisyDisk, CleanShot | New icons and "Tahoe interface" notes do not prove in-app glass | Do not cite as glass examples |
| NetNewsWire | Stock UI still cost a lot on the glass change; "native" is not automatically cheaper | One app, no component detail |

Sources: culturedcode.com/things/blog/2025/09/things-for-os-26 · blog.bear.app/2025/09/bear-is-now-com-paw-tible-with-new-oses-with-adapted-glassy-look · community.bear.app/t/sidebar-is-always-dark/18818 · craft.do/blog/craft-update-3-6-5 · flexibits.com/blog/2025/09/apple-os-26-updates-starring-fantastical-4-1-and-cardhop-2-4 · flexibits.com/blog/2026/09/apples-latest-dropped-and-so-did-fantastical-4-2-cardhop-2-5 · weblog.rogueamoeba.com/2026/05/07/soundsource-6-design-stories · weblog.rogueamoeba.com/2022/09/09/the-design-of-audio-hijack-4 · daisydiskapp.com/blog/daisydisk-4-32-released · cleanshot.com/changelog · inessential.com/2026/09/22/that-about-wraps-it-up-for.html

Apple refs: HIG "Designing for macOS" · "Adopting Liquid Glass" · "Applying Liquid Glass to custom views" (SwiftUI) · WWDC25 session 310 · `ButtonStyle` · SwiftUI accessibility fundamentals · SwiftUI focus · `NSTextInputClient` · `NSGlassEffectView` (macOS 26.0+). All under developer.apple.com.
