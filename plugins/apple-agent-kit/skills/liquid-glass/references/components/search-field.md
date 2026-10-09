# Search field

Single-line search input. Always solid — glass behind text reduces
readability under autocomplete and validation states.

## SwiftUI — toolbar placement

```swift
DetailView()
    .searchable(text: $query, placement: .toolbar, prompt: "Search tokens…")
```

`.searchable(...)` integrates with the surrounding `NavigationSplitView`
and renders a capsule-shaped field (32 tall) in the toolbar. The
toolbar provides the glass; the field itself stays solid.

For a sidebar-aware search:

```swift
.searchable(text: $query, placement: .sidebar, prompt: "Filter")
```

## SwiftUI — inline placement

When the search field belongs inside a content panel, fall back to a
plain `TextField` with a leading magnifying-glass `Label`:

```swift
HStack(spacing: 6) {
    Image(systemName: "magnifyingglass")
        .foregroundStyle(.secondary)
    TextField("Search…", text: $query)
        .textFieldStyle(.plain)
}
.padding(.horizontal, 12)
.padding(.vertical, 10)
.background(
    RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(Color(nsColor: .controlBackgroundColor))
)
.overlay(
    RoundedRectangle(cornerRadius: 12, style: .continuous)
        .strokeBorder(Color.primary.opacity(0.12))
)
.frame(maxWidth: 320)
```

## AppKit

```swift
final class SearchFieldOwner: NSObject, NSSearchFieldDelegate {
    let search = NSSearchField()

    override init() {
        super.init()
        search.placeholderString = "Search…"
        search.delegate = self
    }

    func controlTextDidChange(_ notification: Notification) { }
}
```

For toolbar placement, wrap in `NSSearchToolbarItem`:

```swift
extension NSToolbarItem.Identifier {
    static let search = Self("com.example.search")
}

func makeSearchToolbarItem() -> NSSearchToolbarItem {
    NSSearchToolbarItem(itemIdentifier: .search)
}
```

## Geometry

- toolbar variant: min-height 32, padding 12/6, capsule, icon 14
- inline variant: min-height 44, padding 12/10, radius 12 (`sm`)
- clear-button size 16

## Caveats

- Never put `.glassEffect` behind the field. The toolbar host provides
  the surrounding glass — the field is solid.
- Suggestions / token row use `.searchSuggestions { ... }` (SwiftUI).
- Scoping: `.searchScopes($scope, scopes: { ... })` adds a segmented
  scope picker just below the toolbar.
- AppKit search recents: bind `NSSearchField.recentsAutosaveName`.
