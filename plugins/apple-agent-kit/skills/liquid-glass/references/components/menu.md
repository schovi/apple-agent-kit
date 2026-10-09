# Menu

Pull-down or context menu — list of actions with optional separators
and keyboard shortcut hints. Regular glass on macOS 26 (system-applied).

## SwiftUI — pull-down

```swift
Menu {
    Button("New", systemImage: "plus") {}
        .keyboardShortcut("n")
    Button("Open…", systemImage: "folder") {}
        .keyboardShortcut("o")
    Divider()
    Button("Export tokens", systemImage: "arrow.down.circle") {}
        .keyboardShortcut("e", modifiers: [.command, .option])
    Divider()
    Button("Move to Trash", systemImage: "trash", role: .destructive) {}
        .keyboardShortcut(.delete, modifiers: .command)
} label: {
    Label("File", systemImage: "doc")
}
```

## SwiftUI — context menu

```swift
row.contextMenu {
    Button("Rename", systemImage: "pencil") {}
    Button("Duplicate", systemImage: "doc.on.doc") {}
    Divider()
    Button("Delete", systemImage: "trash", role: .destructive) {}
}
```

Add `.contextMenu(forSelectionType:)` when the menu depends on a
multi-row selection in a `List`.

## AppKit

```swift
let menu = NSMenu()
let item = NSMenuItem(title: "New", action: #selector(makeNew), keyEquivalent: "n")
item.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
menu.addItem(item)
menu.addItem(.separator())
let destructive = NSMenuItem(title: "Move to Trash", action: #selector(trash), keyEquivalent: String(NSDeleteCharacter))
menu.addItem(destructive)
```

For pull-down on a button:

```swift
let pull = NSPopUpButton(frame: .zero, pullsDown: true)
pull.menu = menu
```

## Geometry

- min-width 200, max-width 320
- radius 12 (`sm`)
- padding 6
- item min-height 28, padding 10/4, radius 12
- separator height 1

## Caveats

- `role: .destructive` makes SwiftUI tint the row red and (on macOS)
  may relocate it to the bottom of the menu — accept the placement.
- Submenus: nest `Menu { ... }` inside another `Menu` or use
  `NSMenuItem.submenu`. Do not exceed two levels.
- Keyboard shortcuts must be unique within a menu; SwiftUI will
  print a runtime warning if you collide.
- Don't restyle the menu surface itself. Glass is automatic.
