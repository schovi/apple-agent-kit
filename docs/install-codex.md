# Install for Codex

This installs the **native Apple** plugin.

## Marketplace install (recommended)

```bash
codex plugin marketplace add schovi/apple-agent-kit --sparse .agents/plugins plugins/apple-agent-kit
```

Open Codex and run:

```
/plugins
```

Install **Apple Agent Kit**.

## Repo-local skill install (no plugin)

If you want the skill in a single repo without committing a plugin install, copy the canonical skill into the repo's local skill scan path:

```bash
mkdir -p .agents/skills
cp -R path/to/apple-agent-kit/plugins/apple-agent-kit/skills/liquid-glass .agents/skills/
```

Codex scans `.agents/skills` from the current directory up to the repo root.

## Usage

```text
$liquid-glass Build a SwiftUI sidebar app with NavigationSplitView and a Liquid Glass toolbar.
$liquid-glass Audit this SwiftUI view for Liquid Glass anti-patterns.
$liquid-glass Port this AppKit toolbar to use NSGlassEffectView.
```

You can also invoke it implicitly. Codex selects the skill from its description when the user asks for "Liquid Glass macOS app", "macOS 26 Tahoe UI", "SwiftUI glass effect", or similar.

## How this plugin is laid out

`plugins/apple-agent-kit/` contains `.codex-plugin/plugin.json` (which Codex reads) and `.claude-plugin/plugin.json` (which Claude Code reads). Both manifests point at the same `skills/` directory.

## Update

After the upstream repo changes, refresh the marketplace:

```bash
codex plugin marketplace update apple-agent-kit
```

Then reinstall the plugin.
