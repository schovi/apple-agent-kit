# Form rows

Forms are content. Glass behind a form is anti-pattern A2.

## SwiftUI

```swift
Form {
    Section("Notifications") {
        Toggle("Email updates", isOn: $email)
        Toggle("Push", isOn: $push)
    }
    Section("Display") {
        LabeledContent("Theme") {
            Picker("Theme", selection: $theme) {
                ForEach(Theme.allCases) { Text($0.label).tag($0) }
            }
            .labelsHidden()
            .pickerStyle(.menu)
        }
        LabeledContent("Density") {
            Slider(value: $density, in: 0...1)
                .frame(width: 200)
        }
    }
}
.formStyle(.grouped)
```

`.formStyle(.grouped)` is the macOS 26 grouped inset look. `.columns`
gives a two-column layout if you have many short rows.

Section header / footer:

```swift
Section {
    Toggle("Send anonymous diagnostics", isOn: $diagnostics)
} header: {
    Text("Privacy")
} footer: {
    Text("Diagnostics never include the content of your documents.")
}
```

Footer uses footnote scale automatically.

## AppKit

`NSGridView` is the modern replacement for `NSForm`:

```swift
let grid = NSGridView(views: [
    [NSTextField(labelWithString: "Email updates"), NSSwitch()],
    [NSTextField(labelWithString: "Push"),          NSSwitch()],
])
grid.columnSpacing = 12
grid.rowSpacing = 8
grid.column(at: 0).xPlacement = .trailing
```

For dynamic forms, drive `NSGridView` rows from a model.

## Geometry

- row gap 12 (`groupGap`)
- section gap 24 (`screenMarginRegular`)
- label / control gap 12

## Forbidden

- `.glassEffect(...)` anywhere inside the form.
- Custom backgrounds on individual rows. `Form { Section { ... } }`
  already groups visually on macOS 26.
- Glass on a sheet that already wraps a form — the sheet IS the glass;
  the form stays solid.

## Caveats

- Validation messages: place below the offending field at
  `.footnote` weight, leading-aligned.
- Disable the row's binding only when an explicit dependency is
  unmet; otherwise let the system disable controls based on
  `.disabled(...)` modifier.
- **Inside a `ScrollView`**: `Form` (like `List`) claims infinite
  intrinsic height and scrolls internally. That's correct for a
  Settings scene where the form *is* the scroll container; it's wrong
  inside a scrolling showcase card. Either give the form an explicit
  `.frame(height: ...)` you compute from row count, or compose the
  grouped-form look with a `VStack` of custom section / row views.
