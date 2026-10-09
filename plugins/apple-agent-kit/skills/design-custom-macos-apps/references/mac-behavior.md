# Preserve Mac behavior

Custom appearance must not remove behavior Mac users expect. Walk this list for every surface you customize. Details live in the sibling skill `macos-app-design`; this file says what to check and where.

## Match conventions to the window type

| Window type | Expected | Not expected |
|---|---|---|
| Document app | File menu, New / Open / Save / Duplicate, autosave, Window menu, tabs, restoration | n/a |
| Single-window app (library, shoebox) | Full menu bar, Find, Settings, Cmd-W closes window without quitting data | Document Save flow |
| Menu bar extra / popover | Escape closes, focus lands in the popover, Settings entry, Quit entry when there is no Dock icon | File menu, Cmd-N, multi-window, document restoration |
| Utility panel / HUD | Floats, does not steal key status unless it takes input, Escape closes | Full menu bar of its own |

Do not force document-window conventions onto a menu bar utility or a popover.

## Checklist

### Menus and shortcuts

- Required menu order and standard items: `macos-app-design/references/menu-bar.md`.
- Every primary action has a menu item and a shortcut. No overrides of system shortcuts: `macos-app-design/references/keyboard-shortcuts.md`.
- Settings opens with Cmd-, (SwiftUI `Settings` scene). Find uses Cmd-F / Cmd-G when content is searchable.
- Cmd-W closes the window. Cmd-Q quits. Neither loses data silently.

### Windows

- Window activation, resizing, minimum size, full screen: `macos-app-design/references/windows-and-full-screen.md`.
- Traffic lights stay visible and aligned with a custom title area: `macos-app-design/references/window-chrome.md`.
- Multiple windows and restoration where the app type needs them: `macos-app-design/references/multi-window.md`.
- A draggable window region remains. With a hidden title bar use `NSWindow.isMovableByWindowBackground`, `mouseDownCanMoveWindow`, or SwiftUI `WindowDragGesture` (check availability for the deployment target).

### Keyboard and focus

- Tab and Shift-Tab reach every control when Keyboard navigation is on (System Settings > Keyboard). Read `NSApplication.isFullKeyboardAccessEnabled` in AppKit if behavior depends on it.
- Focus is visible on every focusable element, including styled controls. If a custom style hides the system ring, draw your own.
- Return triggers the default action (`.keyboardShortcut(.defaultAction)`). Escape cancels or closes (`.cancelAction`, `onExitCommand`).
- Focus, selection, hover, and inactive-window states look different from each other.
- SwiftUI tools: `@FocusState`, `.focusable()`, `.focusSection()`, `.onKeyPress` (check availability), `.onMoveCommand`.

### Lists and selection

- Arrow keys move selection. Shift extends, Cmd toggles, Cmd-A selects all, type-select jumps by name where it fits.
- Use `List(selection:)`, `Table`, `NSTableView`, `NSOutlineView` for list-shaped data before building a custom list.
- Delete key removes selected items when deletion is safe and undoable.

### Text, clipboard, undo

- Text fields support platform selection, Services, spelling, input methods, and the standard Edit menu.
- Copy and paste work on selected content, in useful types (plain text plus a rich or custom type).
- Every user edit is undoable via the window's `UndoManager`, with readable action names.
- Context menus offer the same actions as the toolbar and menus for the clicked item.

### Files, drag, preview

- Use standard open and save panels (`fileImporter`, `fileExporter`, `NSOpenPanel`, `NSSavePanel`): `macos-app-design/references/file-management.md`.
- Drag content in and out where content can live outside the app (`Transferable`, `draggable`, `dropDestination`).
- Space bar Quick Look for file-backed items when useful.

### System primitives

- Alerts, confirmation dialogs, and tooltips use system components, not restyled ones: `macos-app-design/references/system-primitives.md`.

### Menu bar extras

- Template image, popover sizing, and quit behavior: `macos-app-design/references/menu-bar-extra.md`.
