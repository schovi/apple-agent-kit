# Slider

Continuous value control. Solid track, 22 pt thumb. In toolbar
contexts the thumb picks up a glass treatment automatically.

## SwiftUI

```swift
Slider(value: $volume, in: 0...1) {
    Text("Volume")
} minimumValueLabel: {
    Image(systemName: "speaker.wave.1")
} maximumValueLabel: {
    Image(systemName: "speaker.wave.3")
}
```

### Neutral value (macOS 26)

```swift
Slider(value: $balance, neutralValue: 0.5, in: 0...1)
```

`neutralValue:` defines the resting point. The fill renders from the
neutral point outward, useful for pan / balance / tone controls.

### Stepped

```swift
Slider(value: $rating, in: 0...5, step: 1)
```

### Toolbar variant — thumb gets glass

```swift
.toolbar {
    ToolbarItem(placement: .principal) {
        Slider(value: $opacity, in: 0...1)
            .frame(width: 200)
    }
}
```

When `Slider` sits inside `.toolbar`, the system styles the thumb as
a glass capsule. Don't add `.glassEffect` yourself.

## AppKit

```swift
let slider = NSSlider(value: 0.5, minValue: 0, maxValue: 1, target: self, action: #selector(sliderChanged(_:)))
slider.allowsTickMarkValuesOnly = false
slider.numberOfTickMarks = 0
slider.controlSize = .regular
```

For vertical orientation:

```swift
slider.isVertical = true
slider.frame.size = NSSize(width: 22, height: 200)
```

## Geometry

- track height 4, capsule
- thumb 22 × 22 capsule
- min-width 120
- label gap 12

## Caveats

- Never put `.glassEffect` on the track. Glass behind a value the
  user is reading is A2.
- The slider's neutral fill is drawn by the system — do not paint a
  custom layer on top.
- Continuous binding: use `.onChange(of: value)` rather than
  observing the binding setter; it dedupes redundant updates.
