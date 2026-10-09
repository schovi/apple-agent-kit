# Disclosure group

Collapsible content with a leading chevron. Solid surface. Used inside
inset lists, inspectors, settings panels.

## SwiftUI — single section

```swift
DisclosureGroup("Advanced") {
    Toggle("Enable beta features", isOn: $beta)
    Toggle("Use experimental renderer", isOn: $experimental)
}
```

## SwiftUI — controlled

```swift
@State private var advancedExpanded: Bool = false

DisclosureGroup(isExpanded: $advancedExpanded) {
    advancedContent
} label: {
    Label("Advanced", systemImage: "gearshape.2")
}
```

## SwiftUI — outline (hierarchical)

```swift
OutlineGroup(rootNodes, children: \.children) { node in
    Label(node.name, systemImage: node.icon)
}
```

Inside a `List`:

```swift
List {
    OutlineGroup(rootNodes, children: \.children) { node in
        NavigationLink(value: node) {
            Label(node.name, systemImage: node.icon)
        }
    }
}
.listStyle(.inset)
```

## AppKit

`NSOutlineView` with built-in disclosure triangles:

```swift
outline.outlineTableColumn = nameColumn
outline.indentationPerLevel = 16
outline.autoresizesOutlineColumn = true
```

Implement `NSOutlineViewDataSource` and `NSOutlineViewDelegate`.

## Geometry

- header min-height 32
- header padding 8 / 6
- chevron 12 leading, gap 8
- indent 16 per depth
- expand animation: fast (160 ms) standard

## Forbidden

- Glass background on the header or disclosed content (A2).
- Animating transform on anything other than the chevron rotation.

## Caveats

- Cap visible outline depth at 3 in content panels.
- Persist expansion with `@SceneStorage("section.advanced.expanded")`
  when the user expects state across window restoration.
- Avoid disclosing more than two levels of nested controls — at that
  point a separate detail pane is clearer.
