# Multi-window

Scene architecture, not material. Each window declares its own
`.toolbar` and `.glassEffect` chrome; sharing one toolbar across
windows is A13.

## Scene picker

| Scene                  | Behavior                                  | Use for                                                          |
| ---------------------- | ----------------------------------------- | ---------------------------------------------------------------- |
| `WindowGroup`          | Multiple instances; Cmd-N opens a new one | Documents, notes, multi-instance editors                          |
| `Window`               | Single instance; reopens on re-invoke     | Preferences, About, Library, Welcome                              |
| `DocumentGroup`        | `WindowGroup` specialized for documents   | File-based apps (Pages, Numbers)                                  |
| `MenuBarExtra`         | Status-bar scene                          | Menu-bar utilities (see `menu-bar-extra.md`)                      |

AppKit equivalent: one `NSWindowController` subclass per window
kind, instantiated per document or per Cmd-N invocation.

## SwiftUI recipe — typed window

```swift
@main
struct NotesApp: App {
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup(id: "note", for: Note.ID.self) { $noteID in
            NoteEditor(noteID: noteID)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note") { openWindow(id: "note") }
                    .keyboardShortcut("n", modifiers: .command)
            }
        }

        Window("Preferences", id: "preferences") {
            PreferencesView()
        }
        .keyboardShortcut(",", modifiers: .command)
    }
}
```

`openWindow(id:value:)` and `dismissWindow(id:value:)` are the
SwiftUI primitives for programmatic open / close. They replace the
NSApp dance of pre-26 code.

## AppKit recipe — window controller

```swift
final class NoteWindowController: NSWindowController {
    convenience init(note: Note) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 720, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.contentViewController = NSHostingController(rootView: NoteEditor(note: note))
        self.init(window: window)
        window.windowController = self        // retain via the window
    }
}
```

To open a new window: `NoteWindowController(note: note).showWindow(self)`.

For Cmd-N when no windows are visible, implement:

```swift
func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
    if !hasVisibleWindows { openWelcomeOrNew() }
    return true
}
```

## State restoration

Mac users expect "Reopen windows when logging back in" and "Restore
last session." The system primitives:

- **SwiftUI** — `@SceneStorage("key")` for per-window state;
  `@AppStorage("key")` for app-level. `WindowGroup(for: ID.self)`
  restores documents automatically when the scene is annotated.
- **AppKit** — `NSWindow.isRestorable = true`,
  `NSWindow.restorationClass = MyRestorationClass.self`. Implement
  `NSWindowController.encodeRestorableState(with:)` and
  `restoreState(with:)`.

Restoration is not optional. An app that opens to a blank state on
every launch reads as broken on macOS.

## Closed-window handling

- Default macOS behavior: app stays running when the last window
  closes. Honor it.
- For utilities that make no sense without a window:
  ```swift
  // SwiftUI
  .terminationPolicy(.afterLastWindowCloses)
  ```
  ```swift
  // AppKit
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
  ```

## Per-window toolbar (don't share)

Each window scene declares its own `.toolbar`. Sharing one toolbar
modifier across scenes triggers A13. The kit's pattern:

```swift
WindowGroup("Note", for: Note.ID.self) { $noteID in
    NoteEditor(noteID: noteID)
        .toolbar {
            ToolbarItem(placement: .principal) { Text(noteTitle) }
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Share") { share() }
                Button("Pin")   { pin() }
            }
        }
}
```

Each window opens with its own toolbar instance. Cross-window
toolbar coordination is via `.focusedSceneValue(_:_:)` on the focused
scene, not by sharing modifier state.

## Anti-patterns

- **Document state as singleton (`@StateObject` at the app root).**
  Opening a second window of the same document shares mutation. Use
  `@SceneStorage` or scene-rooted `@StateObject`.
- **No restoration.** Opening to a blank state every launch.
- **App-modal sheets blocking all windows.** A sheet is
  window-modal. App-modal blocking belongs in `NSAlert.runModal()`
  and only for genuinely critical errors.
- **Hard-coded window origins.** The system cascades new windows;
  let it.
- **Cmd-W overriding system semantics.** ⌘W closes the focused
  window. Apps that override this to close a tab break OS muscle
  memory.

## Sources

Sources and maintainer provenance live in the apple-agent-kit repository's `docs/resources.md`.
