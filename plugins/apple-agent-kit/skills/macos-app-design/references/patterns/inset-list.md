# Inset list

The macOS 26 grouped list. Solid rounded sections. Used for settings,
metadata lists, navigation indices in the content area.

## SwiftUI

```swift
List {
    Section("Recents") {
        ForEach(recents) { item in
            Label(item.name, systemImage: item.icon)
                .badge(item.unread)
        }
    }
    Section("Pinned") {
        ForEach(pinned) { item in
            Label(item.name, systemImage: item.icon)
        }
    } footer: {
        Text("Compact rows are 32 tall; default rows are 44.")
    }
}
.listStyle(.inset)
```

Compact list:

```swift
.listStyle(.inset(alternatesRowBackgrounds: false))
.controlSize(.small)
```

Selection:

```swift
List(items, selection: $selection) { ... }
```

`selection: Set<Item.ID>` for multi-select; the system handles
highlight rendering.

## Sidebar variant

When the same list is used as the app sidebar:

```swift
struct SidebarList: View {
    enum SectionGroup: String, CaseIterable, Identifiable {
        case recents, pinned
        var id: Self { self }
        var label: String { rawValue.capitalized }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: .constant(SectionGroup.recents)) {
                ForEach(SectionGroup.allCases) { group in
                    Section(group.label) { Text(group.label) }
                }
            }
            .listStyle(.sidebar)
        } detail: {
            Text("Detail")
        }
    }
}
```

The system applies Liquid Glass to the sidebar surface; rows inside
stay solid.

## AppKit

For non-hierarchical inset lists, use `NSTableView` with the system inset
style. For hierarchical lists, use `NSOutlineView`.

```swift
let tableView = NSTableView()
tableView.style = .inset
```

## Geometry

- section radius 12 (`sm`)
- row min-height 32 (compact) / 44 (regular)
- row padding 12 / 8
- section gap 16 (`panelGap`)

## Forbidden

- `.glassEffect(...)` on rows or section backgrounds (A2).
- Mixing `.inset` and `.plain` styles in one list.
- Hand-rolling row dividers with full-contrast colors. Use
  `Color.primary.opacity(0.08)` if you must.

## Caveats

- Drag reorder uses `.onMove(perform:)` on the `ForEach`.
- Swipe actions: `.swipeActions(edge:allowsFullSwipe:)` on the row;
  on macOS this surfaces as a contextual menu instead.
- Selection highlight is system-rendered. Don't override.
- **Inside a `ScrollView`**: `List` claims infinite intrinsic height and
  scrolls internally. That's correct for a sidebar / settings pane (it
  *is* the scroll container) but wrong for a card inside a scrolling
  showcase. Either give the List an explicit `.frame(height: ...)` you
  compute from row count, or compose the inset look with a `VStack` and
  custom `Section` / `Row` views that size to content.
