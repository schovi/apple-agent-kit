# Worked scenarios

Three briefs and the decisions this skill should produce. Use them as patterns, not templates. Verify API availability against the real deployment target.

## 1. Distinctive menu bar utility, supports older macOS

**Brief:** a clipboard-history utility. Menu bar only, no Dock icon. Deployment target macOS 14. Strong brand color and a playful feel.

| Surface | Level | Decision |
|---|---|---|
| Status item | 1 | Template image, `MenuBarExtra` with `.menuBarExtraStyle(.window)` |
| History list | 2 | `List(selection:)` with styled rows. Keep arrow-key selection and type-select |
| Row actions (pin, delete) | 2 | Real `Button`s with `ButtonStyle`. Visible on the selected row, plus context menu and shortcuts. Not hover-only |
| Settings | 1 | SwiftUI `Settings` scene, standard `Form` |
| Brand | n/a | Identity through accent color, one typeface choice for the header, icon style. Not through materials |

**Behavior:** focus lands in the search field when the panel opens. Return pastes the selection. Escape closes. Cmd-, opens Settings. A Quit item is in the panel because there is no Dock icon or app menu. No File menu, no Cmd-N, no document restoration.

**Glass:** standard adoption. The system draws the panel. Add no second background or glass layer inside it. If one floating control group is wanted on macOS 26, gate it with `#available(macOS 26, *)` and fall back to the plain styled row on 14 and 15. Never fake glass on 14.

**Verify:** run on macOS 14 and 26. Check Reduce Transparency, Increase Contrast, keyboard-only use, VoiceOver row reading.

## 2. Dense professional app where readability wins

**Brief:** a log and metrics analyzer. Long sessions, many rows, keyboard-heavy users. Deployment target macOS 15.

| Surface | Level | Decision |
|---|---|---|
| Sidebar, toolbar | 1 | `NavigationSplitView` and system toolbar. Let macOS 26 glass apply on its own |
| Log table | 1 to 2 | `Table` (or `NSTableView` for very large row counts) with styled cells. Compact `.controlSize`, monospaced digits |
| Severity | 2 | Icon plus text plus color. Never color alone |
| Inspector | 1 | Inspector column with standard form rows |
| Charts | 2 | Swift Charts with token colors. Opaque background |

**Glass:** restrained surfaces. No glass on rows, cards, charts, or the inspector body. The content layer stays opaque and calm. See the Rogue Amoeba case study for the same trade-off.

**Behavior:** full keyboard navigation in the table, Cmd-F find, Cmd-C copies selected rows as text, context menus on rows, inactive-window selection styling, column sort and resize persisted.

**Maintenance:** lowest-cost path, but still re-verify after each macOS release (see NetNewsWire).

**Verify:** scroll and live-resize with 100,000 rows in Instruments on the slowest supported Mac. Increase Contrast with severity colors. Long localized column headers.

## 3. Custom canvas with keyboard and accessibility support

**Brief:** a node-graph editor for audio processing. Nodes, ports, and connections on an infinite canvas. Deployment target macOS 14.

| Surface | Level | Decision |
|---|---|---|
| Canvas | 3 | Custom view. Task benefit: spatial wiring of a signal graph has no standard control |
| Node titles, parameter fields | 1 | Real `TextField` / `NSTextField` overlays. No custom text engine |
| Floating canvas toolbar | 2 | Real buttons. Glass on macOS 26 via a shared gated modifier, `Material` fallback |
| Inspector, menus, Settings | 1 | Standard |

**What the team owns for the canvas:**

- **Selection:** click, Shift and Cmd extend, marquee, Cmd-A, Escape clears.
- **Keyboard:** Tab and Shift-Tab move between nodes. Arrow keys move the selection (Shift for larger steps). A menu command connects ports, so connecting does not need dragging. Delete removes. Cmd-+ / Cmd-- / Cmd-0 zoom.
- **Focus:** a visible focus ring on the focused node, distinct from selection.
- **Accessibility:** expose each node and connection as an element. SwiftUI: `accessibilityChildren` or one view per node with labels. AppKit: `NSAccessibilityElement` per node with frame, role, label, and press action. Describe connections in words ("Gain output connected to Filter input").
- **Undo:** every edit through `UndoManager`, grouped per gesture, with action names.
- **Clipboard:** copy and paste nodes as a custom type plus a text representation.
- **Input:** trackpad pinch and scroll, mouse wheel, pointer cursors over ports.
- **Performance:** cull off-screen nodes. Profile with 1,000 nodes during drag and zoom.

**Glass:** selective. Glass only on the floating toolbar and transient HUDs over the canvas. The canvas stays calm.

**Tests:** unit tests for the graph model, selection, and undo. Tests that the accessibility element list matches the graph. A UI test that builds a small graph with the keyboard only.
