# Badge

Small solid status pill — capsule, 20 tall — for counts, status, and
labels. Sits on content surfaces or trailing edges of list rows.
Never on a glass surface (defeats its contrast purpose).

## SwiftUI — numeric badges on navigation

```swift
NavigationLink("Inbox", value: Mailbox.inbox)
    .badge(unread)                       // numeric or text

TabView { ... }
    .badge(notificationCount)
```

`.badge(_:)` accepts an `Int` (zero hides the badge) or `Text` (custom
label like "Beta", "12+").

## SwiftUI — inline status pill

For a status pill anywhere else, compose with `Capsule`:

```swift
struct StatusBadge: View {
    enum Kind { case info, success, warning, danger, counter, neutral }

    let kind: Kind
    let label: LocalizedStringKey

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .frame(minHeight: 20, minWidth: 20)
            .foregroundStyle(foreground)
            .background(Capsule().fill(background))
    }

    private var background: Color {
        switch kind {
        case .info:    return .blue.opacity(0.16)
        case .success: return .green.opacity(0.18)
        case .warning: return .orange.opacity(0.20)
        case .danger:  return .red.opacity(0.18)
        case .counter: return .red
        case .neutral: return .gray.opacity(0.20)
        }
    }

    private var foreground: Color {
        switch kind {
        case .info:    return .blue
        case .success: return .green
        case .warning: return .orange
        case .danger:  return .red
        case .counter: return .white
        case .neutral: return .primary
        }
    }
}
```

## AppKit

`NSTextField` styled as a pill:

```swift
let label = NSTextField(labelWithString: "12+")
label.font = .systemFont(ofSize: 11, weight: .semibold)
label.textColor = .systemRed
label.backgroundColor = NSColor.systemRed.withAlphaComponent(0.18)
label.drawsBackground = true
label.wantsLayer = true
label.layer?.cornerRadius = 10
label.layer?.cornerCurve = .continuous
```

## Geometry

- min-height 20, min-width 20
- padding 8 / 2
- capsule
- font caption1 (12 / 600)
- icon size 12

## Caveats

- Counters that overflow ("99+") follow Apple's convention — don't
  paint a tooltip on top of a counter.
- Don't put a badge inside a glass surface — the pill's solid-on-solid
  contrast is the whole point.
- VoiceOver: `.accessibilityLabel("12 unread")` on a numeric badge so
  the count is read in context.
