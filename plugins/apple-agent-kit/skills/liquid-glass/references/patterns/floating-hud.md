# Floating HUD

Free-floating Regular-glass control surface over media or canvas.
Capsule (single row) or 16-radius (multi-row).

## SwiftUI

```swift
mediaView
    .overlay(alignment: .bottom) {
        GlassEffectContainer(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(actions) { action in
                    Button {
                        action.run()
                    } label: {
                        Image(systemName: action.icon)
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    .help(action.label)
                }
            }
            .padding(6)
        }
        .padding(.bottom, 16)
    }
```

Hover-to-show:

```swift
@State private var showsHUD = false

mediaView
    .onHover { showsHUD = $0 }
    .overlay(alignment: .bottom) {
        hud
            .opacity(showsHUD ? 1 : 0)
            .animation(.easeInOut(duration: 0.16), value: showsHUD)
    }
```

Use `fast` (160 ms) standard easing for fade-out so it doesn't
compete with playback.

## AppKit

```swift
let container = NSGlassEffectContainerView()
container.translatesAutoresizingMaskIntoConstraints = false
contentView.addSubview(container)

for action in actions {
    let button = NSButton(image: action.icon, target: self, action: action.selector)
    button.bezelStyle = .glass
    button.bezelColor = nil               // let the container choose
    container.addSubview(button)
}

NSLayoutConstraint.activate([
    container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
    container.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
])
```

## Geometry

- container radius: capsule (single row) / 16 (multi-row)
- container padding: 6
- item size: 40
- gap: 4
- margin from window edge: 16 (`screenMarginCompact`)

## Forbidden

- HUD over a form or text-heavy view (A2).
- Nested HUDs (A1).
- Custom shadow or border (A3).

## Caveats

- On Reduced Transparency the HUD falls back automatically. Do not
  hand-roll a substitute.
- The HUD must clear focusable content beneath it; otherwise the
  invisible click target hides controls. Constrain to the HUD's
  bounds with `.allowsHitTesting(true)` and don't expand to the
  whole `.overlay`.
- For pan / zoom canvas tools, anchor the HUD to a screen corner
  (e.g. `alignment: .bottomTrailing`) so it doesn't follow the
  zoom transform.
