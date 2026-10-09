# Accessibility — generic WCAG for any Mac app

Every Mac app needs the WCAG mapping below regardless of whether it uses Liquid Glass. For glass-specific accessibility (the system's auto-degradation under `reduceTransparency` / `increaseContrast` / `reduceMotion`) see `liquid-glass/references/accessibility.md`.

## What you MUST add

### Accessibility labels (WCAG 4.1.2 — name, role, value)

Every interactive element needs an accessible name. Icon-only buttons fail this if you forget.

```swift
// SwiftUI
Button { } label: {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete")
.accessibilityHint("Removes the selected item")  // optional, when behavior is non-obvious
```

```swift
// AppKit
let button = NSButton(image: NSImage(named: "trash")!, target: nil, action: nil)
button.setAccessibilityLabel("Delete")
```

Compose with `accessibilityElement(children: .combine)` when a custom control aggregates multiple subviews:

```swift
HStack {
    Image(systemName: "person.crop.circle")
    Text("Account")
}
.accessibilityElement(children: .combine)
.accessibilityAddTraits(.isButton)
```

**Review finding `HIG — accessibility`:** icon-only `Button` / `NSButton` without `accessibilityLabel` / `setAccessibilityLabel`.

### Focus visibility (WCAG 2.4.7 — focus visible)

The system draws focus rings on standard controls automatically. For custom hit areas, declare focus state and reflect it visually:

```swift
@FocusState private var isFocused: Bool

Button("Run") { }
    .focused($isFocused)
    .overlay(
        RoundedRectangle(cornerRadius: 8)
            .strokeBorder(.tint, lineWidth: isFocused ? 2 : 0)
    )
```

AppKit uses `acceptsFirstResponder`, `becomeFirstResponder()`, and `drawFocusRingMask()` on `NSView` subclasses. Do not disable the focus ring on a custom control without replacing it.

**Review finding `HIG — accessibility`:** custom hit area with no focus reflection.

### Touch / click targets (WCAG 2.5.5 — target size)

44×44 pt minimum hit area for any interactive element. If the visual size is smaller (e.g. a 22pt icon), pad to reach 44.

```swift
Button { } label: {
    Image(systemName: "ellipsis")
        .frame(width: 44, height: 44)        // hit area
}
```

### Color is never the only signal (WCAG 1.4.1 — use of color)

Selection, error, and warning states pair a hue change with an icon, weight change, or shape:

```swift
HStack {
    Image(systemName: isError ? "exclamationmark.triangle" : "checkmark.circle")
        .foregroundStyle(isError ? .red : .green)
    Text(message)
}
```

### Contrast (WCAG 1.4.3 — contrast)

Text contrast must meet AA: 4.5:1 for body, 3:1 for large text (≥18pt, or ≥14pt bold). System foreground colors on system backgrounds clear this by default; **don't tint text to a custom hue without checking**.

### Motion (WCAG 2.3.3 — animation from interactions)

Honor `@Environment(\.accessibilityReduceMotion)`. Spring animations collapse to crossfades; parallax disables; auto-play stops on first interaction.

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? .none : .spring()) {
    expanded.toggle()
}
```

## System primitives ARE accessible

`Button`, `Toggle`, `Picker`, `TextField`, `Slider`, `Menu`, `Alert`, `Sheet` — all carry correct roles, focus rings, and labels by default. **Use them.** Don't reach for a `Rectangle().onTapGesture { }` and rebuild what the system gives you free. See `system-primitives.md`.

## Accessibility Inspector

Before shipping, run every scene through **Xcode > Open Developer Tool > Accessibility Inspector**. It catches missing labels, broken focus order, and contrast failures. Also enable **VoiceOver** (⌘F5) and walk the app — if you can't reach an action by keyboard or hear it announced, ship a fix.

## Sources

- Apple — Accessibility Inspector: <https://developer.apple.com/accessibility/>
- Apple — NSAccessibility (AppKit): <https://developer.apple.com/documentation/appkit/nsaccessibility>
- WCAG 2.2 — <https://www.w3.org/TR/WCAG22/>

## See also

- `liquid-glass/references/accessibility.md` — glass-specific auto-degradation.
- `system-primitives.md` — system controls carry accessibility for you.
- `keyboard-shortcuts.md` — keyboard parity with mouse-driven actions.
- `light-dark-and-accessibility.md` — appearance and contrast.
