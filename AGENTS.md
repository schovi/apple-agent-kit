# Agent contributor instructions

You are an agent making changes to this repo. Read this before editing.

## What this repo is

A plug-and-play agent plugin for building Apple apps in Swift. One plugin, `plugins/apple-agent-kit/`, serves both Codex (`.codex-plugin/`) and Claude Code (`.claude-plugin/`). There is no build step and no Node toolchain.

The plugin is the **single source of truth**. Tokens, rules, anti-patterns, and API guidance live in the skill references. Nothing is generated.

## Layout

| Path | Purpose |
|---|---|
| `plugins/apple-agent-kit/skills/liquid-glass/` | macOS 26+ Liquid Glass material: APIs, tokens, anti-patterns A1–A24, budget B1, forbidden surfaces F1–F5, shaders |
| `plugins/apple-agent-kit/skills/macos-app-design/` | HIG conformance and Mac craft: menu bar, windows, shortcuts, file management, system primitives, icon, accessibility |
| `plugins/apple-agent-kit/skills/design-custom-macos-apps/` | Distinctive custom UI that keeps Mac behavior: customization levels, glass strategy, maintenance cost, review checklist, case studies |
| `plugins/apple-agent-kit/skills/ios-app-design/` | Placeholder stub |
| `plugins/apple-agent-kit/agents/` | Claude-only subagents. Codex ignores them |
| `examples/macos-native-swift/` | SwiftUI showcase that exercises the skills |
| `docs/` | Install guides and `resources.md` (source dossier for maintainers; not shipped with the plugin) |
| `.claude-plugin/marketplace.json`, `.agents/plugins/marketplace.json` | Marketplace catalogs. Both point at the plugin folder |

Edit only these paths plus `README.md`, `CHANGELOG.md`, and this file.

## Changing rules, tokens, or APIs

Order of operations:

1. **Skill reference** under `plugins/apple-agent-kit/skills/<skill>/references/`. Glass material goes to `liquid-glass`; HIG, Mac craft, and generic accessibility go to `macos-app-design`; custom-design workflow goes to `design-custom-macos-apps`.
2. **`SKILL.md`** of that skill, if the reference map or self-audit list changes.
3. **Agents** in `plugins/apple-agent-kit/agents/`, if an ID list or rule structure changed.
4. **Showcase** in `examples/macos-native-swift/`, if the change has a visible state. Token values live in `Sources/LiquidGlassShowcase/TokenValues.swift` (hand-maintained; mirrors `liquid-glass/references/tokens.md`).
5. **`docs/resources.md`**, for any new non-obvious claim: add the source.
6. **`CHANGELOG.md`**: one entry per shipped change, with paths touched.

## Audit ID taxonomy

Review findings use one ID space, partitioned by prefix:

- **A**: anti-patterns. A1–A10 are core glass rules; A11–A24 are macOS 26 gotchas.
- **B**: budget. B1 = live-blur surfaces per pane. New budget rules go to B2+.
- **F**: forbidden surfaces. F1–F5. F2 and F5 overlap with A2 and A1.
- **`HIG —`**: HIG and accessibility findings without a numbered ID.

When adding an ID, pick the prefix by category, never reuse a number, and update every list: `liquid-glass/SKILL.md`, `liquid-glass/references/anti-patterns.md`, `agents/apple-app-reviewer.md`, `agents/liquid-glass-implementer.md`.

## Validation

| If you touched | Run |
|---|---|
| `examples/macos-native-swift/` or any reference with Swift code | `examples/macos-native-swift/scripts/build.sh` |
| Plugin manifests or agents | `claude plugin validate plugins/apple-agent-kit` |
| IDs, file names, or API names | the drift sweep below |

The showcase compiles a Metal shader. On Xcode 26+ install the Metal Toolchain once: `xcodebuild -downloadComponent MetalToolchain`.

## Drift sweep

```bash
# ID lists stay consistent
git grep -nE "\bA(1[0-9]|2[0-9]|[1-9])\b|\bB[1-9]\b|\bF[1-9]\b" -- plugins

# No pointers to removed paths
git grep -nE "spec/|prompts/|audit/|npm run|design-system\.md" -- plugins examples docs

# Every file path a skill mentions exists
git grep -ohE "references/[a-z0-9/-]+\.md" -- plugins | sort -u
```

## Token discipline

Never invent a blur, saturation, or opacity value. Apple publishes none; the material is rendered live. Radius, spacing, and motion values come from `liquid-glass/references/tokens.md`. If a value is missing, add it there first, then mirror it in the showcase `TokenValues.swift`. Use the SwiftUI / AppKit material APIs; never hard-code a fake glass.

## Apple

Never claim any output is "Apple-official" or "Apple-certified". The plugin wraps real Apple APIs, but the kit is not endorsed. Never commit Apple fonts, UI-kit exports, or Apple-owned screenshots.

## Invocation

| Codex | Claude Code |
|---|---|
| `$liquid-glass …` | `/apple-agent-kit:liquid-glass …` |
| `$macos-app-design …` | `/apple-agent-kit:macos-app-design …` |
| `$design-custom-macos-apps …` | `/apple-agent-kit:design-custom-macos-apps …` |

## Subagent boundaries

- `apple-app-reviewer` is read-only (`disallowedTools: Write, Edit`). Keep it read-only.
- `liquid-glass-implementer` may write. Loads `liquid-glass` and `macos-app-design`.
- `liquid-glass-shader-implementer` may write. Loads `liquid-glass`.
