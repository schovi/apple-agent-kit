# Liquid Glass — research dossier

Provenance for every non-obvious design rule used by this repo. Compiled from
WWDC25 sessions, Apple Newsroom, Apple developer docs, Apple Support, the HIG
(via session transcripts), and the independent press / community write-ups
that quote them. Cite from here when adding new tokens, components, or rules.

This file is the source of truth for "where did that come from?" The plugin
references it; the native Swift example
references it.

---

## A. Primary Apple sources

### Marketing and HIG
- [Apple Newsroom — new software design (Liquid Glass)](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [Apple Newsroom — macOS Tahoe 26](https://www.apple.com/newsroom/2025/06/macos-tahoe-26-makes-the-mac-more-capable-productive-and-intelligent-than-ever/)
- [Apple Support — What's new in macOS Tahoe 26](https://support.apple.com/en-us/122868)

### WWDC25 sessions
- [Session 219 — Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
  Notes: [wwdcnotes.com](https://wwdcnotes.com/documentation/wwdcnotes/wwdc25-219-meet-liquid-glass/)
- [Session 310 — Build an AppKit app with the new design](https://developer.apple.com/videos/play/wwdc2025/310/)
- [Session 323 — Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)

### Developer documentation
- [`NSVisualEffectView.Material`](https://developer.apple.com/documentation/appkit/nsvisualeffectview/material)
  — semantic material enum (`sidebar`, `popover`, `menu`, `sheet`, `hudWindow`,
  `headerView`, `windowBackground`, `selection`, `contentBackground`,
  `underWindowBackground`, `underPageBackground`, `fullScreenUI`, `toolTip`,
  `titlebar`). Unchanged since 10.14's semantic refactor; macOS 26 layers
  Liquid Glass on top.
- [`SwiftUI.View.glassEffect(_:in:)`](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:))
  — applies Liquid Glass. Default shape: `Capsule`.
- [`SwiftUI.View.glassEffectUnion(id:namespace:)`](https://developer.apple.com/documentation/swiftui/view/glasseffectunion(id:namespace:))
  — manually merge distant glass elements.
- [`SwiftUI.GlassButtonStyle`](https://developer.apple.com/documentation/swiftui/glassbuttonstyle) (`.glass`)
- [`SwiftUI.GlassProminentButtonStyle`](https://developer.apple.com/documentation/swiftui/glassprominentbuttonstyle) (`.glassProminent`)
- [`SwiftUI.ConcentricRectangle`](https://developer.apple.com/documentation/swiftui/concentricrectangle)
  — resolves corner radius from the nearest `.containerShape`.
- [`SwiftUI.CustomizableToolbarContent.sharedBackgroundVisibility(_:)`](https://developer.apple.com/documentation/swiftui/customizabletoolbarcontent/sharedbackgroundvisibility(_:))
  — controls per-item glass background visibility.
- [Sample: Landmarks — Applying a background extension effect](https://developer.apple.com/documentation/SwiftUI/Landmarks-Applying-a-background-extension-effect)

---

## B. Anatomy of a macOS 26 window

### Window chrome
- Traffic-light controls (close / minimize / zoom), top-left, ~12 px circles. Slightly higher in the titlebar than on Sonoma.
  Source: [eclecticlight.co — appearance matters](https://eclecticlight.co/2025/09/15/appearance-matters-get-tahoe-looking-in-better-shape/)
- **Concentric corners**: outer window corner radius is selected to wrap around the inner toolbar pill, so radii align visually.
  Source: [WWDC25 session 310](https://developer.apple.com/videos/play/wwdc2025/310/),
  [lapcatsoftware.com — corner radius variations](https://lapcatsoftware.com/articles/2026/3/4.html)
- The legacy `.sidebar` `NSVisualEffectMaterial` should be **removed** from sidebar view hierarchies on macOS 26 — it blocks the new Liquid Glass treatment from being applied automatically.
  Source: [WWDC25 session 310](https://developer.apple.com/videos/play/wwdc2025/310/)

### Layout spine
- `NSSplitViewController` with sidebar + content + inspector behaviors. Sidebar and inspector pick up Liquid Glass automatically.
- `NSSplitViewItem.behavior = .sidebar` / `.inspector` is the structural hook for Liquid Glass automatic treatment.
- Set `automaticallyAdjustsSafeAreaInsets = true` on the content split item so content extends edge-to-edge under the floating sidebar.
  Source: [WWDC25 session 310](https://developer.apple.com/videos/play/wwdc2025/310/)
- New split-item accessory APIs:
  `addTopAlignedAccessoryViewController` / `addBottomAlignedAccessoryViewController` — these get the **scroll edge effect** automatically.

### Toolbar
- Lives in the unified titlebar region; visually a floating glass pill above content.
- Adjacent items auto-group into a single glass element. Non-interactive items (titles, status) should set `isBordered = false` to drop the glass.
- New (AppKit): `style = .prominent`, `backgroundTintColor`, `NSItemBadge.count` / `.text` / `.indicator`.
- New (SwiftUI): `ToolbarSpacer(_:placement:)` with `.fixed` / `.flexible` sizes splits the shared glass into separate capsules.
  Source: [createwithswift.com — toolbar Liquid Glass](https://www.createwithswift.com/adapting-toolbar-elements-to-the-liquid-glass-design-system/)
- `CustomizableToolbarContent.sharedBackgroundVisibility(_:)` hides per-item glass.
  Source: [Apple docs](https://developer.apple.com/documentation/swiftui/customizabletoolbarcontent/sharedbackgroundvisibility(_:))

---

## C. Materials

### AppKit
- `NSGlassEffectView` — single glass surface. Configurable `cornerRadius`, `tintColor`, `contentView`.
- `NSGlassEffectContainerView` — groups multiple glass elements so they share sampling and fluidly merge during animation.
- `NSBackgroundExtensionView` — mirrors and blurs content underneath floating sidebars / inspectors.
  Source: [WWDC25 session 310](https://developer.apple.com/videos/play/wwdc2025/310/),
  [createwithswift.com](https://www.createwithswift.com/exploring-a-new-visual-language-liquid-glass/)

### SwiftUI
- `.glassEffect(_:in:isEnabled:)` — applies Liquid Glass to a view. `Glass` exposes `.regular`, `.clear`, `.identity`, chainable `.tint(_:)` and `.interactive()`.
- `GlassEffectContainer(spacing:)` — SwiftUI equivalent of `NSGlassEffectContainerView`.
- `.glassEffectUnion(id:namespace:)` — manually merge distant glass elements.
- `.backgroundExtensionEffect()` — SwiftUI equivalent of `NSBackgroundExtensionView`. Mirrors and blurs content outside the safe area so it shows through floating surfaces.
  Sources: [Apple docs](https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)),
  [dev.to — GlassEffectContainer](https://dev.to/arshtechpro/understanding-glasseffectcontainer-in-ios-26-2n8p),
  [nilcoalescing — backgroundExtensionEffect](https://nilcoalescing.com/blog/BackgroundExtensionEffectInSwiftUI/)

### Variants
- **Regular** — default. Auto-legible. Use for almost every floating surface.
- **Clear** — more transparent. Only over rich media (photo, video) and with a dim layer behind for safe contrast.
- **Default** vs **Tinted** is a *user* setting (System Settings → Appearance). Tinted increases opacity.
  Source: [Apple Support](https://support.apple.com/en-us/122868)

### What's visually distinctive vs. Sonoma vibrancy
- Edge refraction / lensing at glass rims.
- Specular highlight line tracking geometry.
- Glass gets *thicker* (deeper shadow, stronger lensing) as it grows — e.g. menu emerging from a toolbar button.
- Dynamic tint sampled from content behind.
- Auto-flips appearance with `NSAppearance` light/dark.
  Sources: [Apple Newsroom](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/),
  [wwdcnotes session 219](https://wwdcnotes.com/documentation/wwdcnotes/wwdc25-219-meet-liquid-glass/)

### Numeric values
Apple publishes **no** numeric blur / saturation / opacity values for Liquid Glass — it's
real-time rendered and adaptive. This kit does not port internal Apple values.
Source: [Apple Newsroom](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/) (no numeric specs published).

---

## D. Components

| Component | AppKit | SwiftUI |
|---|---|---|
| Push button (glass) | `NSButton.bezelStyle = .glass`, `borderShape = .capsule` | `.buttonStyle(.glass)` / `GlassButtonStyle` |
| Prominent button | `style = .prominent` + `backgroundTintColor` | `.buttonStyle(.glassProminent)` / `GlassProminentButtonStyle`, `.tint(_:)` for color |
| Segmented control | `NSSegmentedControl` (capsule shape) | `Picker(...).pickerStyle(.segmented)` |
| Search field | `NSSearchField` / `NSSearchToolbarItem` (renders as glass capsule in toolbar) | `.searchable(text:)` |
| Popover | `NSPopover` (material `.popover`) | `.popover(isPresented:)` |
| Menu | `NSMenu` (material `.menu`); redesigned with single-column icon-led rows | `Menu` / `Picker(.menu)` |
| Sidebar / source list | `NSOutlineView` style source-list, rows render directly on glass | `List` inside `NavigationSplitView` |
| Sheet | `NSWindow` sheet (material `.sheet`); morphs in from presenting control | `.sheet(isPresented:)` with `.presentationDetents` — Liquid Glass is automatic |
| Tab view | Floating glass tabs (Safari reference) | `TabView` with new style |
| Slider | `NSSlider` with `neutralValue` | `Slider(value:neutralValue:in:)` |
| Lists / tables | `NSTableView` rows against glass; selection uses material `.selection` | `List` |
| Concentric shape | n/a (manual radius math) | `ConcentricRectangle()` resolves from `.containerShape(...)` |

Sources: [WWDC25 session 310](https://developer.apple.com/videos/play/wwdc2025/310/),
[Apple docs (glass button styles)](https://developer.apple.com/documentation/swiftui/glassbuttonstyle),
[tanaschita.com — glass button styles](https://tanaschita.com/swiftui-glass-button-style/),
[medium / DevTechie — Slider neutralValue](https://medium.com/devtechie/the-ios-26-slider-gets-a-big-upgrade-heres-what-s-new-423a215b898a),
[nilcoalescing — sheets in Liquid Glass](https://nilcoalescing.com/blog/PresentingLiquidGlassSheetsInSwiftUI/),
[nilcoalescing — ConcentricRectangle](https://nilcoalescing.com/blog/ConcentricRectangleInSwiftUI/)

---

## E. SwiftUI toolbar specifics (WWDC25 additions)

- `ToolbarSpacer(.fixed)` / `ToolbarSpacer(.flexible)` — splits a toolbar's shared glass into separate capsules.
  Source: [createwithswift.com](https://www.createwithswift.com/adapting-toolbar-elements-to-the-liquid-glass-design-system/)
- `CustomizableToolbarContent.sharedBackgroundVisibility(_:)` — `.visible`, `.hidden`, `.automatic`.
  Source: [Apple docs](https://developer.apple.com/documentation/swiftui/customizabletoolbarcontent/sharedbackgroundvisibility(_:))
- `ToolbarItemGroup` — explicit group; items inside share one glass background.
- Placements `.confirmationAction` / `.cancellationAction` auto-promote to `.glassProminent` semantics.
  Source: [swiftwithmajid — glassifying toolbars](https://swiftwithmajid.com/2025/07/01/glassifying-toolbars-in-swiftui/)

---

## F. Sheets / presentations

- Liquid Glass on sheets is **automatic** when `.presentationDetents` includes a partial-height detent. Avoid `.presentationBackground(.glass)`; it's redundant.
  Source: [nilcoalescing](https://nilcoalescing.com/blog/PresentingLiquidGlassSheetsInSwiftUI/)
- Sheet morph in from a control: `.matchedTransitionSource(id:in:)` + `.navigationTransition(.zoom(sourceID:in:))`.

---

## G. Concentricity (matched corner radii)

- AppKit: use `safeArea(cornerAdaptation:)` on the content view and pick the toolbar pill / window radii so `outer = inner + inset`. `NSView.LayoutRegion` helps content avoid the rounder corners.
- SwiftUI: `ConcentricRectangle()` reads from the nearest `.containerShape(.rect(cornerRadius:))` so children automatically inset their corners.
  Source: [nilcoalescing — ConcentricRectangle](https://nilcoalescing.com/blog/ConcentricRectangleInSwiftUI/)

---

## H. Where glass goes (and where it does not)

Layer rules from the HIG (per session 219 quotes):

**Glass-allowed**
- Top navigation, bottom navigation, tab bar.
- Floating toolbars, action bars.
- Sheets, popovers, menus.
- Floating cards or panels above content.
- Primary action surface (a single highlighted action button).

**Glass-forbidden**
- Page background.
- Long-form text containers.
- Forms and input fields.
- Dense data tables.
- Any element that sits behind another glass element ("glass-on-glass").

---

## I. Accessibility

- Native: `NSAccessibility` flags `reduceTransparency`, `increaseContrast`, `reduceMotion`. AppKit auto-degrades vibrancy when these are on.

---

## J. Independent reviews & deep-dives

Useful for visual reference and for understanding *how* the material reads in
practice. None are Apple-published; treat them as community interpretation.

- [Six Colors — macOS 26 Tahoe review (power under glass)](https://sixcolors.com/post/2025/09/macos-26-tahoe-review-power-under-glass/)
- [MacStories — macOS 26 Tahoe review](https://www.macstories.net/stories/macos-26-tahoe-the-macstories-review/2/)
- [Eclectic Light Co. — appearance matters in Tahoe](https://eclecticlight.co/2025/09/15/appearance-matters-get-tahoe-looking-in-better-shape/)
- [Lapcat Software — window corner radius variations](https://lapcatsoftware.com/articles/2026/3/4.html)
- [createwithswift.com — exploring Liquid Glass](https://www.createwithswift.com/exploring-a-new-visual-language-liquid-glass/)
- [Conor Luddy — Liquid Glass reference](https://www.conor.fyi/writing/liquid-glass-reference) (also: https://github.com/conorluddy/LiquidGlassReference)
- [Swift with Majid — Glassifying toolbars](https://swiftwithmajid.com/2025/07/01/glassifying-toolbars-in-swiftui/)
- [Doran Gao — Tahoe-style Liquid Glass UI in SwiftUI](https://medium.com/@dorangao/build-a-macos-swiftui-app-with-a-tahoe-style-liquid-glass-ui-fecb8029b2d8)
- [tanaschita — glass button styles](https://tanaschita.com/swiftui-glass-button-style/)
- [DevTechie — iOS 26 Slider upgrades](https://medium.com/devtechie/the-ios-26-slider-gets-a-big-upgrade-heres-what-s-new-423a215b898a)
- [appcircle.io — Build a SwiftUI app with the new design](https://www.appcircle.io/blog/wwdc-25-build-a-swiftui-app-with-the-new-design)
- [Wikipedia — macOS Tahoe](https://en.wikipedia.org/wiki/MacOS_Tahoe)
- [Wikipedia — Liquid Glass](https://en.wikipedia.org/wiki/Liquid_Glass)

---

## K. Representative screenshots

From Apple's official macOS marketing page (`apple.com/os/macos/`). Image
URLs change with site revisions; if a link 404s, navigate via the parent page.

- Liquid Glass hero (widgets over beach):
  https://www.apple.com/v/os/e/images/macos/liquid_glass/liquid_glass_hero__e4g9pjpws8ya_xlarge.jpg
- Transparent menu bar with widgets:
  https://www.apple.com/v/os/e/images/macos/highlights/liquid_glass__f595gw1ozwi2_large.jpg
- Lock-screen Liquid Glass typography:
  https://www.apple.com/v/os/e/images/macos/liquid_glass/design__51h6pg9xusii_large.jpg
- Tinted Liquid Glass app icons:
  https://www.apple.com/v/os/e/images/shared/liquid_glass/app_icons__ghno6awtphe2_large.jpg
- Control Center custom controls:
  https://www.apple.com/v/os/e/images/macos/liquid_glass/controls__djddwinnqlqq_large.jpg
- Redesigned Safari (refreshed apps end frame):
  https://www.apple.com/v/os/e/images/shared/liquid_glass/refreshed_apps_endframe__caoxm8a8obqq_large.jpg
- Spotlight (Messages integration) end frame:
  https://www.apple.com/v/os/e/images/macos/highlights/spotlight_endframe__dp92pp9cet4y_large.jpg
- Phone app on Mac (contact poster, toolbar):
  https://www.apple.com/v/os/e/images/macos/highlights/mac_phone__e2u9ab76th8i_large.jpg
- Three Macs on Tahoe desktop:
  https://www.apple.com/v/os/e/images/macos/welcome/hero_macos_imac_screen_endframe__5l04et7rmtu6_large.jpg

Wikipedia full UI screenshot:
https://upload.wikimedia.org/wikipedia/en/thumb/f/fa/MacOS_Tahoe_screenshot.png/330px-MacOS_Tahoe_screenshot.png

---

## L. Confirmed gaps

These were investigated and not confirmed at the time of writing — do not
guess at API names if you need them, look them up first.

- `backgroundExtensionEffect()` formal parameter list (only the modifier name is documented in the cited sample).
- `presentationCornerRadius` as a *new* Liquid Glass affordance (existing modifier; unclear if its behavior changed).
- A new sidebar list-row API name beyond `List` in `NavigationSplitView`.
- Glass-aware `safeAreaInset` / `safeAreaPadding` behavior — implied, not confirmed by name.
- Programmatic Default-vs-Tinted setting hook (HIG-level user preference; no documented SwiftUI API surface in this pass).

---

## M. House rules

- Never claim "Apple-official" or "Apple-certified". The kit is inspired-by, not endorsed.
- Never invent numeric material values. Use native system APIs for Liquid Glass.
- Apple ships no portable numeric blur, saturation, or opacity values for Liquid Glass.

---

## N. Extended research (May 2026 sweep)

Second-pass sources that go beyond sections A–L. Collected from community
implementations, cross-platform analogs, criticism, and adjacent Mac craft.
Everything below was new at sweep time and is not duplicated above.

### N.1 Open-source SwiftUI / native packages

- [DnV1eX/LiquidGlassKit](https://github.com/DnV1eX/LiquidGlassKit) — Backports Liquid Glass to iOS 13–18 and reimplements it on iOS 26+ with a Metal-shader rendering engine (refraction, chromatic dispersion, Fresnel, glare, shape merging). Goes deeper than Apple's stock APIs allow.
- [muhittincamdali/LiquidGlassKit](https://github.com/muhittincamdali/LiquidGlassKit) — Pre-built `LiquidGlassCard / LiquidGlassButton / LiquidGlassNavigationBar` wrappers.
- [mertozseven/LiquidGlassSwiftUI](https://github.com/mertozseven/LiquidGlassSwiftUI) — Minimal sample exercising `GlassEffectContainer`, shared style, and symbol transitions.
- [dambertmunoz/dm-swift-swiftui-liquid-glass](https://github.com/dambertmunoz/dm-swift-swiftui-liquid-glass) — Practical adoption examples.

### N.4 Shader / rendering deep dives

- [Victor Baro — Refractive glass shader in Metal](https://medium.com/@victorbaro/implementing-a-refractive-glass-shader-in-metal-3f97974fbc24) + [SDF in Metal: Liquid](https://medium.com/@victorbaro/sdf-in-metal-adding-the-liquid-to-the-glass-69abd57e2151) — End-to-end SDF + refraction + Fresnel + dispersion. Strongest single source on the underlying math.
- [Hacking with Swift — Metal shaders in SwiftUI](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-metal-shaders-to-swiftui-views-using-layer-effects) + [Inferno shader library](https://github.com/twostraws/Inferno) — How `layerEffect` / `colorEffect` glue Metal to SwiftUI.
- [OverShifted/LiquidGlass](https://github.com/OverShifted/LiquidGlass) — Pure OpenGL reference rendering outside the Apple stack.
- [Manav Kaushal — Engineering behind Apple's Liquid Glass](https://medium.com/@manavkaushal756/engineering-behind-apple-liquid-glass-ui-fb51b1d599ad) — Fresnel + head-relative reflectance lighting model.
- [JuniperPhoton — Adopting Liquid Glass: experiences and pitfalls](https://juniperphoton.substack.com/p/adopting-liquid-glass-experiences) — Strongest performance source. Documents three offscreen textures per `CABackdropLayer`, glass-on-glass sampling failure, iOS 26.1 Menu-in-`GlassEffectContainer` regression.
- [Flutter — Impeller blur perf #126353](https://github.com/flutter/flutter/issues/126353) + [BackdropFilter perf #161297](https://github.com/flutter/flutter/issues/161297) — Hard frame numbers: 6 ms Skia vs 16–24 ms Impeller per blurred frame.

### N.5 SwiftUI / native walkthroughs

- [Donny Wals — Designing custom UI with Liquid Glass](https://www.donnywals.com/designing-custom-ui-with-liquid-glass-on-ios-26/), [Opting out via UIDesignRequiresCompatibility](https://www.donnywals.com/opting-your-app-out-of-the-liquid-glass-redesign-with-xcode-26/), [Tab bars on iOS 26](https://www.donnywals.com/exploring-tab-bars-on-ios-26-with-liquid-glass/).
- [Swift with Vincent — How to disable Liquid Glass](https://www.swiftwithvincent.com/blog/how-to-disable-liquid-glass).
- [Kodeco — An Introduction to Liquid Glass for iOS 26](https://www.kodeco.com/49905345-an-introduction-to-liquid-glass-for-ios-26).
- [The Swift Kit — Liquid Glass UI in SwiftUI](https://theswiftk.it.com/blog/liquid-glass-ui-swiftui-ios-26-tutorial).
- [YouTube — Mastering Liquid Glass in SwiftUI](https://www.youtube.com/watch?v=E2nQsw0El8M) — `.glassEffectID` morphing.
- [OpenAI Codex — iOS Liquid Glass use case](https://developers.openai.com/codex/use-cases/ios-liquid-glass) — Peer LLM-assisted migration kit.
- [Apple — Liquid Glass overview](https://developer.apple.com/documentation/TechnologyOverviews/liquid-glass), [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass), [`SwiftUI.Glass`](https://developer.apple.com/documentation/swiftui/glass) — Official material description + API surface.

### N.6 Icon Composer

- [Apple Icon Composer](https://developer.apple.com/icon-composer/) — Layered Liquid Glass icons across iPhone, iPad, Mac, Watch.

### N.7 Accessibility and criticism

- [NN/g — Liquid Glass Is Cracked, and Usability Suffers in iOS 26](https://www.nngroup.com/articles/liquid-glass/) — Most-cited usability takedown.
- [NN/g — Glassmorphism definition and best practices](https://www.nngroup.com/articles/glassmorphism/) — Glass needs cooperative backgrounds + stroke/gradient reinforcement.
- [Infinum — Sleek, Shiny, and Questionably Accessible](https://infinum.com/blog/apples-ios-26-liquid-glass-sleek-shiny-and-questionably-accessible/) — Concrete iOS 26 Control Center / Lock Screen contrast regressions.
- [Axess Lab — Glassmorphism meets accessibility](https://axesslab.com/glassmorphism-meets-accessibility-can-frosted-glass-be-inclusive/) — `prefers-reduced-transparency` patterns; recommends a 30%-opacity film behind text.
- [Vidit B — Solving Liquid Glass accessibility with more materials](https://blog.viditb.com/solving-liquid-glass-accessibility/) — Argues for a tiered material set bound to system preferences.
- [Designed For Humans — Practical guidance on Liquid Glass](https://designedforhumans.tech/blog/liquid-glass-smart-or-bad-for-accessibility) — Walks WCAG 2.2 4.5:1 / 3:1 against dynamic backgrounds.
- [Orizon — Glassmorphism in 2026 without killing UX](https://www.orizon.co/blog/glassmorphism-in-2026-how-to-use-frosted-glass-without-killing-ux) — "Don't use it for" list.
- [Leigh Brown — The most beautiful trap in modern UI design](https://medium.com/design-bootcamp/glassmorphism-the-most-beautiful-trap-in-modern-ui-design-a472818a7c0a).
- [Iconfactory Breakroom — Peeking Through the Liquid Glass](https://blog.iconfactory.com/2025/06/peeking-through-the-liquid-glass/) and Craig Hockenberry's [author archive](https://blog.iconfactory.com/author/craig/) — Edge-avoidance argument suggests wraparound-OLED hardware foreshadowing.
- [Geeky Gadgets — 45% adoption record low](https://www.geeky-gadgets.com/apple-liquid-glass-adoption-rate/).
- [Verklaren — Through the lens of design history](https://verklaren.space/liquid-glass-through-design-history/) — Aqua / Frutiger Aero lineage.
- [Design Republic — Revolution or step backwards?](https://www.designrepublic.io/en/blog/von-flat-design-zu-liquid-glass-revolution-oder-ruckschritt) — European design-studio critique.
- [TechRadar — Federighi on simulating physical glass](https://www.techradar.com/phones/ios/we-did-all-this-work-with-physical-glass-simulating-as-closely-as-we-could-the-actual-properties-of-glass-for-liquid-glass-says-apples-craig-federighi-then-they-went-further).

### N.9 Broader macOS craft (beyond Liquid Glass)

**Modern Mac product writeups**

- [Linear — How we redesigned the UI](https://linear.app/now/how-we-redesigned-the-linear-ui), [A calmer interface](https://linear.app/now/behind-the-latest-design-refresh), [Linear Method](https://linear.app/method).
- [Raycast — A technical deep dive into the new Raycast](https://www.raycast.com/blog/a-technical-deep-dive-into-the-new-raycast) — Hybrid native+web architecture, 120fps animation budget, corner-radius rigor.
- [Stijn Bakker — How Raycast standardises native Mac design of plugins](https://www.stijnbakker.com/how-raycast-standardises-native-mac-design-of-plugins).
- [yetone/native-feel-skill](https://github.com/yetone/native-feel-skill) — Reverse-engineered tenets from Raycast Beta: four-layer architecture, WebKit survival guide, 75-item ship audit.
- [Arc browser design analysis (Blake Crosley)](https://blakecrosley.com/guides/design/arc).
- [Cultured Code — Things features](https://culturedcode.com/things/features/).
- [MacStories — Craft review](https://www.macstories.net/reviews/craft-review-a-powerful-native-notes-and-collaboration-app/).

**Books and long-form**

- [objc.io — Thinking in SwiftUI](https://www.objc.io/books/thinking-in-swiftui/), [App Architecture](https://www.objc.io/books/app-architecture/), [Advanced Swift](https://www.objc.io/books/advanced-swift/).
- [Paul Hudson — Hacking with macOS (SwiftUI Edition)](https://twostraws.gumroad.com/l/hwmacos) — 18 Mac projects; multi-window, tabbed UI, Settings/About, Canvas.
- [Kodeco — macOS by Tutorials](https://www.kodeco.com/books/macos-by-tutorials/v1.0).
- [Evil Martians — How to make any app look like a macOS app](https://evilmartians.com/chronicles/how-to-make-absolutely-any-app-look-like-a-macos-app).

**AppKit / SwiftUI on Mac**

- [Mario Aguzman — Toolbar Guidelines](https://marioaguzman.github.io/design/toolbarguidelines/).
- [Paul Bancarel — macOS full-height sidebar window](https://medium.com/@bancarel.paul/macos-full-height-sidebar-window-62a214309a80).
- [Kean — AppKit is Done](https://kean.blog/post/appkit-is-done) — Which AppKit corners still matter in 2025.
- [SwiftUI Lab](https://swiftui-lab.com/), [Swift with Majid (weekly)](https://weekly.swiftwithmajid.com/), [NSHipster](https://nshipster.com/), [Swift by Sundell — The Sweeter Mac App (ep. 21)](https://www.swiftbysundell.com/podcast/21/).

**Icons, typography, motion**

- [Bjango — My Mac app icon design workflow](https://bjango.com/articles/macappiconworkflow/).
- [Bjango — Designing macOS menu bar extras](https://register.bjango.com/articles/designingmenubarextras/).
- [macOS Icon Gallery](https://www.macosicongallery.com/), [The macOS App Icon Book (Flarup)](https://www.appiconbook.com/).
- [Jonathan Willing — Short guide to OS X animations](https://jwilling.com/blog/osx-animations/).

**Awards and showcases**

- [Apple Design Awards 2025](https://developer.apple.com/design/awards/2025/), [MacStories Selects 2025](https://www.macstories.net/stories/macstories-selects-2025-recognizing-the-best-apps-of-the-year/), [ADA 2025 trends](https://www.macstories.net/news/2025-apple-design-awards-winners-and-finalists-announced/).

**Patterns and tooling**

- [Superhuman — How to build a remarkable command palette](https://blog.superhuman.com/how-to-build-a-remarkable-command-palette/), [awesome-command-palette](https://github.com/stefanjudis/awesome-command-palette), [MacStories — Command-K Bars as a modern interface pattern](https://www.macstories.net/linked/command-k-bars-as-a-modern-interface-pattern/).
- [Atlassian Design System](https://atlassian.design/), [Carbon Design System (IBM)](https://carbondesignsystem.com/) — Reference for multi-product token + accessibility rigor.

**Communities**

- [Under the Radar (Relay FM)](https://relay.fm/radar), [Indie Dev Monday](https://indiedevmonday.com/), [Design Details podcast](https://designdetails.fm/episodes), [The Iconfactory](https://iconfactory.com/).

### N.10 Hacker News / social

- [HN — Prep work for AR interfaces](https://news.ycombinator.com/item?id=44271630).
- [HN — Liquid Glass: when aesthetics beat function](https://news.ycombinator.com/item?id=44658103).
- [HN — Liquid Glass is permanent](https://news.ycombinator.com/item?id=47499641).
- [David Smith (Underscore) on Mastodon — Adopting Liquid Glass](https://mastodon.social/@_Davidsmith/114698383012166785).

---

## O. Expansion ideas (strategic backlog)

Synthesis of where the kit could grow, grouped by ambition tier. None of this
is committed scope; treat as a backlog for prioritization.

### O.1 Tighten the existing dossier (low risk)

1. **Promote criticism to a first-class rule.** Expand the native forbidden-surface guidance with concrete failure cases and citations from NN/g, Infinum, Axess Lab, Iconfactory, and the 45%-adoption stat.
2. **Add a performance-budget rule with citations.** Encode JuniperPhoton's three-textures-per-`CABackdropLayer` number, the Flutter Impeller 16–24 ms data, and the iOS 26.1 Menu regression into a hard limit ("max N live-blurred surfaces; prefer one shared container").

### O.2 Fill obvious craft gaps (medium)

4. **Command palette / Cmd-K as a documented pattern.** Expand the native recipe with Superhuman's design notes, Raycast's plugin grammar, and `awesome-command-palette`.
5. **Mac app icon guidance.** Expand the native icon reference with the squircle grid, layered model, Icon Composer flow, Bjango, Flarup, and macOS Icon Gallery.
6. **Sidebar / window-chrome patterns beyond toolbars.** Bancarel's full-height sidebar walkthrough and Mario Aguzman's toolbar guidelines have details not currently captured (sidebar inset, titlebar height, traffic-light alignment with first row).

### O.3 Expand the kit's surface area (bigger)

9. **A Metal-shader companion on the native side.** Document `layerEffect` / `colorEffect` recipes against Victor Baro's SDF + refraction math; link Inferno. New subagent: `liquid-glass-shader-implementer`.

### O.4 Reframe the product (big bets — pick one)

12. **Position as the accessibility-first Liquid Glass implementation.** Apple's reception is mixed (NN/g, Infinum, 45% adoption). Open lane: a kit that ships Liquid Glass with reduced-transparency guidance and review rules.
14. **Become the canonical Mac craft kit, not just glass.** Glass is one chapter. The larger craft is sidebars + toolbars + command palette + icons + menu bar + multi-window + keyboard, codified the way Linear / Raycast / Things / Craft / Arc share unwritten conventions. More durable than glass-specific guidance if Apple iterates hard in macOS 27.

### O.5 Recommendation

If only one direction: **O.4 #12 (accessibility-first framing)**. **O.4 #14** is the long-game bet if this becomes a serious project.
