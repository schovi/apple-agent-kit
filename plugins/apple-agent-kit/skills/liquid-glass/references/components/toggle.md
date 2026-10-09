# Toggle

Boolean switch. System-rendered. Used in form rows, settings panels,
inspectors. Solid track, never glass.

## SwiftUI

```swift
Form {
    Section("Notifications") {
        Toggle("Email updates", isOn: $emailUpdates)
        Toggle("Push", isOn: $push)
        Toggle("Mixed-state", isOn: $mixed)
    }
}
```

`Toggle` inside `Form` auto-aligns the label and switch; that's the
default style for macOS 26 settings.

### `.switch` style

```swift
Toggle("Compact view", isOn: $compact)
    .toggleStyle(.switch)
```

`.switch` is the default on macOS for `Toggle`. `.checkbox` is
available when the row reads like a checkbox list.

### Mixed state

```swift
Toggle(isOn: Binding(
    get: { selection.allOn },
    set: { selection.setAll($0) }
)) {
    Text("Select all")
}
```

Indeterminate state must use `NSButton.allowsMixedState = true` with
`.state = .mixed` in AppKit, or a custom binding in SwiftUI.

## AppKit

```swift
let toggle = NSSwitch()
toggle.target = self
toggle.action = #selector(switchChanged(_:))
toggle.state = .on
```

## Geometry

- track 38 × 22 capsule
- knob 18 capsule, inset 2
- label gap 12 (`groupGap`)
- toggle animation: 240 ms (`base`) standard easing

## Caveats

- Always pair a `Toggle` with a label. Naked switches are an
  accessibility failure (no VoiceOver target).
- Don't custom-color the track. Apple's tint (green on macOS, system
  accent on iOS) is part of the recognition pattern.
- Inside a form, the toggle stays solid. Anti-pattern A2: glass behind
  a form row.
