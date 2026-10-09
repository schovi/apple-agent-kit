# Command palette (⌘K)

Spotlight is the system version. Raycast / Linear / Superhuman are the app-level pattern. On macOS 26 a credible palette is ~40 lines of SwiftUI.

## Geometry

- Width 640, max-height 480, top offset 96 from window edge.
- Panel radius 16 (md). Items radius 12 (sm) — concentric (16 outer − 4 panel padding).
- Input height 44, item height 44, icon 18.
- Material role: `hud` over a scrim (light 0.08 / dark 0.32).

## Keyboard model — non-negotiable

| Key | Behavior |
|---|---|
| `⌘K` | Toggle palette. |
| `Esc` | Close, restore focus to trigger. |
| `↑` / `↓` | Move selection. Wrap at ends. |
| `⏎` | Run selected. Close. |
| any char | Append to query. Selection resets to top match. |
| `Tab` | Trapped — focus stays inside the panel until close. |

## SwiftUI recipe

```swift
struct ContentView: View {
    @State private var isPaletteOpen = false
    var body: some View {
        AppRoot()
            .overlay(alignment: .top) {
                if isPaletteOpen {
                    CommandPalette(isOpen: $isPaletteOpen)
                        .padding(.top, 96)
                        .transition(.scale(scale: 0.96).combined(with: .opacity))
                }
            }
            .overlay {
                Button("Toggle Palette") {
                withAnimation(.spring(response: 0.24, dampingFraction: 0.85)) {
                    isPaletteOpen.toggle()
                }
                }
                .keyboardShortcut("k", modifiers: .command)
                .hidden()
            }
    }
}

struct CommandPalette: View {
    @Binding var isOpen: Bool
    @State private var query = ""
    @State private var selected = 0
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField("Type a command…", text: $query)
                .textFieldStyle(.plain)
                .font(.title3)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .focused($inputFocused)
                .onKeyPress(.upArrow)   { selected = max(0, selected - 1); return .handled }
                .onKeyPress(.downArrow) { selected = min(filtered.count - 1, selected + 1); return .handled }
                .onKeyPress(.return)    { run(filtered[selected]); return .handled }
                .onKeyPress(.escape)    { isOpen = false; return .handled }

            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(Array(filtered.enumerated()), id: \.element.id) { index, cmd in
                        CommandRow(command: cmd, isSelected: index == selected)
                            .onTapGesture { selected = index; run(cmd) }
                    }
                }
            }
            .frame(maxHeight: 360)
        }
        .padding(8)
        .frame(width: 640)
        .frame(maxHeight: 480)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
        .onAppear { inputFocused = true }
    }
    // ...filtered, run, CommandRow elided for brevity.
}
```

## What to avoid

- **`.searchable` is the wrong tool.** That places a search field in the toolbar; the palette is its own modal surface. Use a `TextField` inside the overlay.
- **Glass-on-glass (A1).** If the underlying app already shows a glassy toolbar, the scrim breaks the stacking. Do not omit the scrim.
- **Skipping focus restore.** When the palette closes, focus must return to the element that opened it.
- **Reordering the keyboard model.** The five keys above are what users have learned across Spotlight / Raycast / Linear. Do not invent new ones.
- **Multi-step input.** The palette runs a command in one step. If your action needs more input, run the command, then open a sheet.

## AppKit fallback

For AppKit codebases: use an `NSPanel` with style mask including `.utilityWindow`, `.titled`, and `.nonactivatingPanel` so it floats over the key window without stealing key. Apply the `.hudWindow` `NSVisualEffectView.Material`. Capture `⌘K` with `NSEvent.addLocalMonitorForEvents(matching: .keyDown)` filtering for `modifierFlags.contains(.command)` and `charactersIgnoringModifiers == "k"`.

## Sources

Sources and maintainer provenance live in the apple-agent-kit repository's `docs/resources.md`.
