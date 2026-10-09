# Popover

Anchored floating panel. Regular glass with an optional arrow.

## SwiftUI

```swift
button
    .popover(isPresented: $isShown, arrowEdge: .bottom) {
        VStack(alignment: .leading, spacing: 2) {
            PopoverRow(icon: "star",              label: "Favorite")
            PopoverRow(icon: "arrow.down.circle", label: "Download")
            PopoverRow(icon: "trash",             label: "Delete")
        }
        .padding(8)
        .frame(minWidth: 220)
    }
```

`arrowEdge` is the edge the arrow points *from* the anchor. On macOS,
omit it to let the system pick. Use `attachmentAnchor:` when you need
to anchor to a custom point inside the source view.

## AppKit

```swift
let popover = NSPopover()
popover.behavior = .transient            // .applicationDefined for sticky
popover.contentSize = NSSize(width: 220, height: 180)
popover.contentViewController = PopoverContent()
popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
```

`behavior = .transient` dismisses on outside click; `.semitransient`
keeps it open when the user clicks back into the app.

## Geometry

- min-width 220, max-width 360
- radius 16 (`md`)
- padding 8 (`controlGap`)
- item min-height 28, padding 10/8, radius 12 (`sm`)
- anchor offset 8

## Glass is automatic

The popover surface is system-rendered Regular glass on macOS 26.
Never add `.glassEffect` to the popover content — that nests glass
(A1) and breaks the system treatment.

## Caveats

- Inside the popover, content stays solid. Glass behind text inside
  the popover is A2.
- For destructive items use `.foregroundStyle(.red)` on a row that
  represents a `.destructive` role; for SwiftUI `Menu` use `Button("...", role: .destructive)`.
- Popover dismisses on Escape and click-outside; do not intercept
  unless the popover is performing an irreversible action.
