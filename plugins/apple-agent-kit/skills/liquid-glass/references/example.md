# Worked example

`examples/macos-native-swift/` is a runnable SwiftUI showcase that uses
every primitive in this skill:

- `NavigationSplitView` (sidebar + content + inspector) — `ContentView.swift`
- Unified titlebar + toolbar with `Picker(.segmented)`, `.searchable`, `Menu`, `.buttonStyle(.glassProminent)` — `ContentView.swift`
- `.glassEffect(.regular, in: ...)` and `.glassEffect(.clear, in: ...)` with the required dim — `Sections.swift` (`MaterialsSection`, `ClearVariantSection`)
- `GlassEffectContainer(spacing:)` grouping toolbar pill buttons — `Sections.swift` (`ButtonsSection`)
- `ConcentricRectangle()` reading from `.containerShape(...)` — `Sections.swift` (`ConcentricDemo`)
- `.sheet(...)` with `.presentationDetents([.medium, .large])` getting Liquid Glass automatically — `ContentView.swift` (`NewEntrySheet`)

Run it on macOS 26 with Xcode 26:

```bash
cd examples/macos-native-swift
swift run
```

Or open `Package.swift` in Xcode.

It demonstrates native Liquid Glass patterns section by section.
