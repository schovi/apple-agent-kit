# Install for Claude Code

This installs the **native Apple** plugin.

## Marketplace install (recommended)

Inside Claude Code:

```
/plugin marketplace add schovi/apple-agent-kit
/plugin install apple-agent-kit@apple-agent-kit
```

Or from the shell:

```bash
claude plugin marketplace add schovi/apple-agent-kit --sparse .claude-plugin plugins/apple-agent-kit
```

## Local development

Run the plugin straight out of this repo:

```bash
claude --plugin-dir ./plugins/apple-agent-kit
```

Then:

```
/apple-agent-kit:liquid-glass Build a SwiftUI app with NavigationSplitView, a glass toolbar, and an inspector.
```

## How this plugin is laid out

`plugins/apple-agent-kit/` contains `.claude-plugin/plugin.json` (which Claude Code reads) and `.codex-plugin/plugin.json` (which Codex reads). Both manifests point at the same `skills/liquid-glass` directory. Claude Code additionally reads `agents/`; Codex ignores that folder.

## Subagents shipped with the plugin

- `apple-app-reviewer` — read-only review of generated SwiftUI / AppKit.
- `liquid-glass-implementer` — token-strict implementer.

Both reference the canonical `liquid-glass` skill.

## Update

```
/plugin marketplace update apple-agent-kit
/plugin install apple-agent-kit@apple-agent-kit
```

After local skill edits, re-run `/reload-plugins`.
