# Stepper

Paired plus / minus increment buttons. In a toolbar they share one
glass capsule via `GlassEffectContainer`. In a form they stay solid.

## SwiftUI — form variant

```swift
LabeledContent("Sessions") {
    Stepper(value: $sessions, in: 0...99) {
        Text("\(sessions)")
            .monospacedDigit()
    }
    .labelsHidden()
}
```

`Stepper` does the heavy lifting: hold-to-repeat, bounds, accessibility
labels, VoiceOver value-change announcements. Don't reimplement.

Alternative custom callbacks:

```swift
Stepper("Sessions", onIncrement: { sessions += 1 },
                    onDecrement: { sessions -= 1 })
```

Use this only when value isn't a plain `Int` / `Double` (e.g. `Date`
adjustments where you want full control).

## SwiftUI — toolbar variant (shared glass capsule)

```swift
.toolbar {
    ToolbarItemGroup {
        GlassEffectContainer(spacing: 4) {
            HStack(spacing: 4) {
                Button { sessions -= 1 } label: {
                    Image(systemName: "minus").frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .disabled(sessions == 0)

                Button { sessions += 1 } label: {
                    Image(systemName: "plus").frame(width: 28, height: 28)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
            }
        }
    }
}
```

The container merges both buttons into one shared glass sampling pass.
Inside a single `ToolbarItemGroup`, `ToolbarSpacer` is not needed.

## AppKit

```swift
let stepper = NSStepper()
stepper.minValue = 0
stepper.maxValue = 99
stepper.valueWraps = false
stepper.autorepeat = true
stepper.target = self
stepper.action = #selector(stepperChanged(_:))
```

Pair with `NSTextField` for the value:

```swift
let value = NSTextField(labelWithString: "\(stepper.integerValue)")
value.alignment = .center
```

## Geometry

- button size 28 (toolbar) / 22 (form)
- button radius capsule (toolbar) / 12 (form)
- gap between buttons 4 (toolbar) / 0 with shared border (form)
- icon size 14

## Forbidden

- Glass under the value (A2).
- Custom hold-to-repeat behavior — `Stepper` and `NSStepper` both
  handle this; reimplementing breaks accessibility.

## Caveats

- VoiceOver reads the current value and step amount automatically.
  Don't override with `.accessibilityLabel` unless you also reproduce
  the value rotor.
- For ranges with steps that aren't 1, pass `step: 0.5` (or whatever)
  to `Stepper(value:in:step:)`. The system updates the announcement.
