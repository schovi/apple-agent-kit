# Where glass goes (and where it doesn't)

The single most common Liquid Glass mistake is putting glass behind
content. The rules below follow Apple's HIG (sourced from WWDC25 session
219).

## Layer model

- **Navigation / functional layer** — glass lives here. Titlebar, toolbar, sidebar, tab bar, popover, menu, sheet, floating action button.
- **Content layer** — solid. Text, forms, tables, lists, cards.

## Allowed

- Top navigation, bottom navigation, tab bar.
- Floating toolbars and action bars. (On macOS 26 the unified `NSToolbar` / SwiftUI `.toolbar` *is* the floating bar.)
- Sheets, popovers, menus.
- Floating cards or panels above content.
- Primary action surface — a single highlighted action button, or one prominent capsule.

## Forbidden

- **Page background** (F1). Glass needs something behind it. The page is the *something behind*, not the something glass.
- **Long-form text containers** (F2). Glass shimmers under scroll and pulls contrast below WCAG AA on busy backdrops (NN/g documented this on iOS 26 Lock Screen; Infinum on Control Center).
- **Forms and data-entry surfaces** (F3). Keep their fields solid. A single toolbar or command-palette search field may sit inside glass.
- **Dense data tables** (F4). Glass under tables erodes legibility row-by-row.
- **Anything that sits behind another glass element** (F5, "glass-on-glass"). Two stacked glass surfaces produce no real refraction and read as muddy; on macOS 26 / iOS 26 the inner element can fail to render (JuniperPhoton documented an iOS 26.1 `Menu`-in-`GlassEffectContainer` regression).

Full failure cases and citations live in `when-not-to-use-glass.md`
(this directory).

## Native-specific gotchas

### macOS 26 sidebars
- Remove the legacy `NSVisualEffectMaterial.sidebar` from sidebar view hierarchies — it *blocks* the new Liquid Glass auto-treatment.
- Use `NSSplitViewItem.behavior = .sidebar` (AppKit) or `NavigationSplitView` (SwiftUI). The system renders the glass for you.

### macOS 26 toolbars
- Adjacent items auto-merge onto one shared glass capsule. Insert a `ToolbarSpacer(.flexible)` (SwiftUI) or call `sharedBackgroundVisibility(.hidden)` if you need separate capsules.
- Non-interactive items (titles, status) should set `isBordered = false` (AppKit) or use `.sharedBackgroundVisibility(.hidden)` (SwiftUI) so they don't claim a glass background.

### Concentric corners
- The outer window corner radius wraps around the inner toolbar pill.
- SwiftUI: declare `.containerShape(RoundedRectangle(cornerRadius: 28))` on the parent and use `ConcentricRectangle()` (or rely on system-resolved insets) on children.
- AppKit: pick the radii manually so `outer = inner + inset`.

### Sheets
- Liquid Glass on `.sheet` is automatic when `.presentationDetents` includes a partial-height detent (`.medium`, `.large`, `.fraction`, `.height`).
- Do not override a partial detent with `.presentationBackground(<material or color>)`.

### Background extension
- Use `.backgroundExtensionEffect()` (SwiftUI) or `NSBackgroundExtensionView` (AppKit) on hero art so it shows through under the floating sidebar / inspector.

## Native variant selection

| Surface | Variant | Why |
|---|---|---|
| Toolbar pill | Regular | Always over content; needs legibility. |
| Sidebar | Regular | Over scrolling content with mixed colors. |
| Popover, menu | Regular | Always. |
| Sheet | Regular | Auto via `.presentationDetents`. |
| Hero overlay on photo / video | Clear | With dim layer. |
| Content card | None | Solid. |
| Text field | None | Solid. |

## How variants flow

- SwiftUI: `.glassEffect(.regular, in: shape)` or `.glassEffect(.clear, in: shape)`. Chain `.tint(_:)` for a programmatic tint, `.interactive()` for press / hover response.
- AppKit: `NSGlassEffectView()` (defaults to Regular) with optional `tintColor`. For Clear, you'd typically render content over media; AppKit doesn't expose a separate "clear" constructor — it picks variants based on context.
