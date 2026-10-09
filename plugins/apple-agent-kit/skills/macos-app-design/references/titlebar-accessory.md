# Titlebar accessory

Custom view in the principal toolbar slot — typically a segmented
control, breadcrumb, or path bar. Inherits the toolbar's glass; the
accessory itself adds nothing.

## SwiftUI

```swift
DetailView()
    .toolbar {
        ToolbarItem(placement: .principal) {
            Picker("View mode", selection: $mode) {
                ForEach(ViewMode.allCases) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 320)
        }

        ToolbarSpacer(.flexible)

        ToolbarItem(placement: .primaryAction) {
            Button("New", systemImage: "plus") {}
                .buttonStyle(.glassProminent)
        }
        .sharedBackgroundVisibility(.hidden)
    }
```

`ToolbarSpacer(.flexible)` splits the principal accessory from the
primary action so they don't share one capsule.

`.sharedBackgroundVisibility(.hidden)` on the primary item prevents
the merged-capsule treatment and keeps the tint distinct.

## AppKit

```swift
let accessory = NSTitlebarAccessoryViewController()
accessory.view = pathBarView
accessory.layoutAttribute = .top
accessory.isHidden = false
window.addTitlebarAccessoryViewController(accessory)
```

For a path bar with breadcrumbs:

```swift
let pathControl = NSPathControl()
pathControl.pathStyle = .standard
pathControl.url = currentURL
accessory.view = pathControl
```

## Geometry

- min-height 32 (matches toolbar item height)
- max-width 360
- inner padding 4 / 0 (toolbar provides outer padding)

## Forbidden

- `.glassEffect` on the accessory itself — the toolbar already
  applies the shared glass (A1).
- Body text in the accessory. It is navigation, not content.
- Two accessories in `.principal` — only one principal slot.

## Caveats

- The accessory shrinks ahead of the primary action when the window
  narrows. Test at the minimum window width.
- AppKit only: when the accessory needs to disappear in compact
  windows, set `accessory.isHidden = true` from a window-resize
  observer.
