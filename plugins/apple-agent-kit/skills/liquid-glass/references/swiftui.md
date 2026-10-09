# SwiftUI cheat-sheet

Confirmed APIs for SwiftUI on macOS 26 and later / iOS 26. Sources and maintainer
provenance live in the apple-agent-kit repository's `docs/resources.md` (§ B–F).
Do not invent API names — if you need
something not listed here, check Apple's reference first.

## Glass material

```swift
view.glassEffect(.regular, in: Capsule())            // default shape is Capsule
view.glassEffect(.clear, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
view.glassEffect(.regular.tint(.indigo))             // chained tint
view.glassEffect(.regular.interactive())             // press / hover response
```

`Glass` exposes `.regular`, `.clear`, `.identity`. Chainable: `.tint(_:)`, `.interactive()`.

### Modifier order — `.glassEffect` must run last

Glass samples whatever is behind the view. The sampling pass uses the
view's final shape, so every layout / frame / padding modifier must
run *before* `.glassEffect`. Putting `.glassEffect` mid-chain samples
the wrong region.

```swift
// ✅ Correct
Text("Hello")
    .padding()
    .frame(width: 200)
    .glassEffect(.regular, in: .rect(cornerRadius: 16))

// ❌ Wrong — padding / frame apply after glass sampling
Text("Hello")
    .glassEffect()
    .padding()
    .frame(width: 200)
```

### `.identity` — the conditional off-state

`Glass.identity` is the no-op variant. Toggle glass off with it instead
of conditionally removing the `.glassEffect` modifier — `.identity`
keeps layout stable and avoids re-running the sampling pass.

```swift
button
    .glassEffect(highlighted ? .regular : .identity)
```

### `.interactive()` — only on input

`.interactive()` adds press, hover, and pointer-illumination response.
Apply it **only** to views that actually respond to user input
(buttons, sliders, tappable pills). Putting it on a static status pill
or decorative badge produces phantom hover targets and confuses screen
readers.

## Grouping glass

`GlassEffectContainer(spacing:)` groups glass elements so they share one
sampling pass and morph fluidly during animations.

```swift
GlassEffectContainer(spacing: 4) {
    HStack(spacing: 4) {
        Button { } label: { Image(systemName: "arrowshape.turn.up.left") }
            .buttonStyle(.glass).buttonBorderShape(.capsule)
        Button { } label: { Image(systemName: "arrowshape.turn.up.right") }
            .buttonStyle(.glass).buttonBorderShape(.capsule)
    }
}
```

### Morphing — `glassEffectID` + `@Namespace`

When a glass element appears, disappears, or swaps shape, give every
participant a `glassEffectID` in a shared `@Namespace` and wrap the
state change in `withAnimation`. The full pattern lives in
`references/patterns/morphing.md`.

```swift
@Namespace private var ns
@Binding var expanded: Bool

GlassEffectContainer(spacing: 24) {
    Button(expanded ? "Collapse" : "Expand") {
        withAnimation(.bouncy) { expanded.toggle() }
    }
    .buttonStyle(.glass)
    .glassEffectID("toggle", in: ns)

    if expanded {
        Button("Action 1") { }.buttonStyle(.glass).glassEffectID("a1", in: ns)
        Button("Action 2") { }.buttonStyle(.glass).glassEffectID("a2", in: ns)
    }
}
```

Requirements: same `GlassEffectContainer`, same `@Namespace`, animated
state change. Use `.glassEffectUnion(id:namespace:)` when participants live
far apart (e.g. toolbar item morphing into a content-area capsule).

### `.glassEffectUnion(id:namespace:)` — dynamic and cross-ancestor

Apple's guidance: `glassEffectUnion` is "useful when creating views
dynamically or with views that live outside of an HStack or VStack."
Use it on:

- Views generated in a `ForEach` whose count varies at runtime.
- Two glass surfaces in different parent containers that should still
  read as one shape (a toolbar pill morphing into a content-area
  capsule).
- Any case where you can't physically nest the participants inside
  the same `GlassEffectContainer`.

```swift
ForEach(items) { item in
    ItemPill(item)
        .glassEffectUnion(id: "pill-row", namespace: ns)
}
```

## Background extension

```swift
HeroImage()
    .backgroundExtensionEffect()
```

Mirrors and blurs the view outside the safe area so it shows through
floating sidebars and inspectors. Apply on the **content**, never on
the chrome — the chrome already paints Liquid Glass.

The split-view detail variant uses a per-column background:

```swift
NavigationSplitView {
    Sidebar()
} detail: {
    Detail()
        .background {
            HeroImage()
                .backgroundExtensionEffect()
        }
}
```

### Horizontal scroll under sidebar / inspector

```swift
ScrollView(.horizontal) { ... }
    .ignoresSafeArea(.container, edges: .horizontal)
    .safeAreaPadding(.horizontal)
```

Extend the scroll container under the sidebar or inspector. Keep scroll
content readable with `safeAreaPadding`. Put
`backgroundExtensionEffect()` on background art when it should show
through the surrounding chrome.

## Scroll edge effects

Controls how scrolling content fades or hardens beneath floating
chrome. Full rules in `references/patterns/scroll-edge-effects.md`.

```swift
ScrollView { ... }
    .scrollEdgeEffectStyle(.hard, for: .top)
```

- Styles: `.automatic` (default), `.soft`, `.hard`.
- Edges: `.top`, `.bottom`, `.leading`, `.trailing`, `.all`.
- One style per edge. Never mix soft + hard on adjacent edges of the
  same scroll view.
- Only apply where a floating chrome element actually sits at that
  edge — edge effects are not decoration.

## Window chrome

```swift
WindowGroup("Title") { ContentView() }
    .windowStyle(.titleBar)
    .windowToolbarStyle(.unified(showsTitle: true))
    .defaultSize(width: 1180, height: 760)
```

The unified toolbar style is what gives you the macOS 26 single floating
glass strip across the top.

## Layout — three-column

```swift
NavigationSplitView {
    Sidebar(selection: $selection)
} content: {
    Detail()
        .navigationTitle("Showcase")
        .searchable(text: $query, placement: .toolbar)
        .toolbar { ... }
} detail: {
    Inspector()
}
```

`NavigationSplitView` picks up Liquid Glass automatically on macOS 26 and later —
don't add `.sidebar` background materials manually.

## Toolbar

```swift
.toolbar(id: "main") {
    ToolbarItem(placement: .principal) {
        Picker("View", selection: $mode) { ... }
            .pickerStyle(.segmented)
    }
    ToolbarSpacer(.fixed)                // hard gap inside one shared capsule
    ToolbarSpacer(.flexible)             // splits the shared capsule in two
    ToolbarItem {
        Menu { ... } label: { Label("More", systemImage: "ellipsis") }
    }
    ToolbarItem {
        Button { } label: { Label("New", systemImage: "plus") }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
    }
}
```

`CustomizableToolbarContent.sharedBackgroundVisibility(_:)` hides the
shared glass background per group.

### `ToolbarSpacer` — `.fixed` vs `.flexible`

- `.fixed` inserts a hard gap *inside* one shared glass capsule
  (keeps items grouped; just spaces them apart).
- `.flexible` splits the shared capsule in two — items on either side
  get their own capsule.

Use `.fixed` for visual breathing room within a group; `.flexible`
when adjacent items should read as separate controls.

### `DefaultToolbarItem` — reposition system items

```swift
.toolbar {
    DefaultToolbarItem(kind: .sidebarToggle, placement: .navigation)
    DefaultToolbarItem(kind: .search, placement: .primaryAction)
}
```

Use `DefaultToolbarItem(kind:placement:)` when the system-provided
search or sidebar control needs to live in a non-default slot.

### Title and subtitle

```swift
ContentView()
    .navigationTitle("Inbox")
    .navigationSubtitle("12 unread")
```

On macOS, use `navigationSubtitle(_:)`. There is no public macOS toolbar
placement for a custom large subtitle view.

## Buttons

```swift
Button("Continue") { }
    .buttonStyle(.glassProminent)         // primary
    .controlSize(.large)

Button("Secondary") { }
    .buttonStyle(.glass)                  // secondary

Button("Ghost") { }
    .buttonStyle(.borderless)             // ghost

Button { } label: { Image(systemName: "plus") }
    .buttonStyle(.glass)
    .buttonBorderShape(.capsule)          // .capsule | .circle | .roundedRectangle(radius:)
```

`.controlSize(.extraLarge)` shipped in macOS 14. On macOS it resolves to
the large control metrics.

## Segmented / search / popover

```swift
Picker("Density", selection: .constant(0)) {
    Text("Compact").tag(0)
}
    .pickerStyle(.segmented)

View()
    .searchable(text: $query, placement: .toolbar)
    .searchToolbarBehavior(.minimize)    // collapse to button, expand on tap

view
    .popover(isPresented: $shown, arrowEdge: .bottom) { PopoverContent() }
```

`.searchToolbarBehavior(.minimize)` renders the search field as a
button-like capsule that expands to the full field on focus.
Recommended on space-constrained toolbars (smaller windows, sidebar
inspector toolbars). The default behavior keeps the field expanded.

## Sheet — Liquid Glass is automatic

```swift
.sheet(isPresented: $shown) {
    NewEntry()
        .presentationDetents([.medium, .large])
}
```

Do not override the partial detent with
`.presentationBackground(<material or color>)`; it triggers Liquid Glass automatically.

For a macOS sheet or popover, use the standard presentation transition.
For related glass controls in one `GlassEffectContainer`, use shared
`glassEffectID(_:in:)` values to morph their glass shapes.

## Concentricity

```swift
RoundedRectangle(cornerRadius: 28, style: .continuous)
    .containerShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    .overlay(
        ConcentricRectangle()             // reads parent radius automatically
            .padding(8)                   // child = 28 − 8 = 20
    )
```

## Slider with neutral value

```swift
Slider(value: $volume, in: 0...1, neutralValue: 0.5) {
    Text("Volume")
}
```

## Tinting

`.tint(_:)` flows into `.glassProminent` (sets background tint) and into
`Glass.tint(_:)` for `.glassEffect`.

## Accessibility — the system handles it

Do not implement reduced-transparency / increased-contrast / reduced-motion
fallbacks manually. SwiftUI auto-degrades vibrancy when those flags are on.
Use `@Environment(\.accessibilityReduceTransparency)` only if you need to
branch your own custom rendering.

## macOS 27 changes

- `GeometryProxy.concentricCornerRadii` (macOS 27+) resolves container radii for custom drawing.
- Inactive windows dim more visibly on macOS 27. Dim custom views with `@Environment(\.appearsActive)` (available since macOS 10.15, not new) so they match the system chrome.
- AppKit adds `NSGlassEffectView.effectIsInteractive`; enable it only for interactive glass.
- System glass adapts to the user’s Clear or Tinted appearance setting in 26.1 and its 27 slider.
- The SDK exposes no public API to read that appearance setting. Use system glass instead of branching.
