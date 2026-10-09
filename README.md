# Apple Agent Kit

An agent plugin for building Mac apps that feel like Mac apps. Install it into Claude Code or Codex, then ask for SwiftUI or AppKit work. iOS coverage is on the roadmap.

## Skills

| Skill | Use it for |
|---|---|
| `macos-app-design` | HIG conformance: menu bar order, multi-window, keyboard shortcuts, file management, system primitives, app icon, accessibility. macOS 14+ |
| `liquid-glass` | The macOS 26+ Liquid Glass material via the real `glassEffect` / `NSGlassEffectView` / `ConcentricRectangle` APIs. Anti-patterns, performance budget, Metal shaders |
| `design-custom-macos-apps` | A distinctive custom UI that keeps Mac behavior: customization levels, glass strategy, maintenance cost, review checklist, case studies |
| `ios-app-design` | Placeholder |

Subagents (Claude Code only): `apple-app-reviewer` (read-only review), `liquid-glass-implementer`, `liquid-glass-shader-implementer`.

## Install

### Claude Code

```bash
claude plugin marketplace add schovi/apple-agent-kit --sparse .claude-plugin plugins/apple-agent-kit
/plugin install apple-agent-kit@apple-agent-kit
```

```text
/apple-agent-kit:macos-app-design Build a SwiftUI sidebar app with NavigationSplitView and a correct menu bar.
/apple-agent-kit:liquid-glass Apply Liquid Glass to the inspector.
/apple-agent-kit:design-custom-macos-apps Plan a branded menu bar utility that still supports macOS 14.
```

### Codex

```bash
codex plugin marketplace add schovi/apple-agent-kit --sparse .agents/plugins plugins/apple-agent-kit
```

```text
$macos-app-design Build a SwiftUI sidebar app with NavigationSplitView and a correct menu bar.
$liquid-glass Add Liquid Glass to the toolbar of this app.
$design-custom-macos-apps Review this custom canvas for keyboard and VoiceOver support.
```

Details: `docs/install-claude.md`, `docs/install-codex.md`.

## Position

Liquid Glass shipped with documented readability problems ([NN/g](https://www.nngroup.com/articles/liquid-glass/), [Infinum](https://infinum.com/blog/apples-ios-26-liquid-glass-sleek-shiny-and-questionably-accessible/)). The kit treats accessibility as the default: glass stays off content layers, system accessibility settings are never overridden, and every icon-only control gets a name and visible focus.

A glass surface inside an otherwise non-native app still feels wrong. That is why `macos-app-design` exists next to `liquid-glass`.

## Showcase

```bash
examples/macos-native-swift/scripts/run.sh     # build and launch (macOS 26+, Xcode 26+)
examples/macos-native-swift/scripts/xcode.sh   # open in Xcode
```

The showcase compiles a Metal shader. On Xcode 26+ install the Metal Toolchain once: `xcodebuild -downloadComponent MetalToolchain`.

## Layout

```
plugins/apple-agent-kit/
├── skills/
│   ├── liquid-glass/              macOS 26+ glass material
│   ├── macos-app-design/          HIG / Mac craft
│   ├── design-custom-macos-apps/  custom UI that keeps Mac behavior
│   └── ios-app-design/            placeholder
└── agents/                        reviewer + implementers
examples/macos-native-swift/       SwiftUI showcase
docs/                              install guides + source dossier
```

## Not

- Not Apple-official, Apple-certified, or Apple-endorsed.
- Not a polyfill. Liquid Glass needs macOS 26+; older systems get a coherent non-glass design.

## Contributing

See `AGENTS.md`. It applies to humans too.

## License

MIT. See `LICENSE`.
