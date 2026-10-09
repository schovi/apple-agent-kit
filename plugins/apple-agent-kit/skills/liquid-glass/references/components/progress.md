# Progress

Determinate or indeterminate progress indicator. Solid surface.

## SwiftUI

### Linear determinate

```swift
ProgressView("Uploading…", value: bytesUploaded, total: bytesTotal)
    .progressViewStyle(.linear)
```

### Linear indeterminate

```swift
ProgressView("Loading…")
    .progressViewStyle(.linear)
```

### Circular determinate

```swift
ProgressView(value: 0.42)
    .progressViewStyle(.circular)
    .controlSize(.regular)              // .mini | .small | .regular | .large
```

### Circular indeterminate (spinner)

```swift
ProgressView()
    .progressViewStyle(.circular)
    .controlSize(.small)
```

### Tinted

```swift
ProgressView(value: progress)
    .tint(.green)
```

`tint(_:)` reliably colors determinate progress. Indeterminate spinners
inherit the system accent — accept the fallback rather than overriding.

## AppKit

```swift
let bar = NSProgressIndicator()
bar.style = .bar                         // .bar | .spinning
bar.isIndeterminate = false
bar.minValue = 0
bar.maxValue = 1
bar.doubleValue = 0.42
```

Spinner:

```swift
let spinner = NSProgressIndicator()
spinner.style = .spinning
spinner.isIndeterminate = true
spinner.startAnimation(nil)
```

## Geometry

- linear height 4, capsule, min-width 120
- circular sizes 16 / 24 / 32 (mini, small / regular, large)
- stroke 2

## Caveats

- Never put `.glassEffect` behind a progress indicator (A2 — text /
  numeric value next to it stays readable only on solid).
- For long-running tasks, pair determinate progress with an ETA in
  footnote style. Indeterminate spinners should not run longer than
  ~2 seconds without status feedback.
- Don't reimplement the spinner with a `Circle().rotationEffect`
  loop — the system spinner respects `accessibilityReduceMotion`.
