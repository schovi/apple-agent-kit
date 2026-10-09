# File management

Document-based apps help people create, edit, and save documents. On Mac, people use Finder; on iOS / iPadOS / visionOS, the Files app. The expectations Mac users carry into your app come from Pages, Keynote, Preview, and Photos.

## Creating and opening files

- **Use app menus and keyboard shortcuts.** File > New (⌘N), File > Open (⌘O). Include an Add (+) button to create new in-UI for non-document apps.
- **If you need a custom file browser, respect the platform's file system layout.** Open to a relevant default (Documents, iCloud, last location) but let people navigate elsewhere.

## Saving work

- **Autosave periodically and on close / app switch.** Avoid explicit Save as the only way.
- **Hide file extensions by default**, but let people view them. Reflect the choice consistently.
- **Prompt for name / location on the first save** of a new document.
- **Prefer a format pop-up in the Save sheet** to multiple "Save As" menu items.

## The autosave dot

Users can disable autosave via Desktop & Dock settings ("Ask to keep changes when closing documents"). Behavior:

- **Autosave OFF** — show unsaved state: **dot on the close button** and next to the doc name in the Window menu. Prompt to save on close / quit / logout / restart.
- **Autosave ON** — do **not** show the dot. The dot implies user action is needed; autosave handles it.
- Either way, you can append "Edited" to the title bar; remove on save.

## Duplicate, not Save As

**Prefer Duplicate** to Save As / Export / Copy To / Save To — it preserves a clear relationship between source and copy. File > Duplicate (⌘D conventional, but conflicts with Cut/Copy contexts — check before assigning).

## Quick Look

- **Quick Look viewer** — lets users preview a file type even when your app can't open it. Implement for attached / interacted-with files your app doesn't natively support.
- **Quick Look generator** — if your app emits custom file types, ship a generator so Finder / Files / Spotlight can preview them.

## Custom file management (macOS)

- **Use the default file browser** unless you have a strong reason.
- **Make custom open UI convenient** — "open recent" alongside "open", filter criteria, multi-select. You can customize the Open button title (e.g. "Insert").
- **Provide a save interface** for name / format / location changes. Default title "Untitled" until renamed. Default save location should be logical. Provide a format picker if you support multiple formats.
- **Extend Save dialog with a custom accessory view** if useful (Mail's "include attachments" option is the canonical example).

## Finder Sync extensions

If your app syncs local + remote files, use a Finder Sync extension to:

- Display badges in Finder indicating sync status.
- Add custom contextual menu items for file / folder actions (favoriting, password-protection).
- Add custom toolbar buttons for global actions (initiate sync).

## SwiftUI

```swift
@main
struct MyDocumentApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MyDocument()) { file in
            DocumentView(document: file.$document)
        }
    }
}
```

`DocumentGroup` handles New / Open / Save / Duplicate / Versions / autosave / file extensions automatically. Override individual menu items via `.commands { ... }` only when you have a reason.

The document model API depends on the deployment target:

- **macOS 27+**: conform to the `Document` protocol (`ReadableDocument` + `WritableDocument`). `FileDocument` and `ReferenceFileDocument` are deprecated; do not use them in new code. Register every edit with the undo manager: SwiftUI uses the undo stack to detect changes, so autosave silently stops without it.
- **macOS 14–26**: `FileDocument` (value type) or `ReferenceFileDocument` (class).

For the `Document` protocol's exact signatures, load Apple's `building-document-based-swiftui-applications` skill (bundled with Xcode 27) instead of guessing.

## AppKit

`NSDocument` subclass + `NSDocumentController` for document-based apps. Handles the same surface with more knobs.

## Sources

- Apple HIG — File management: <https://developer.apple.com/design/human-interface-guidelines/file-management>

## See also

- `menu-bar.md` — File menu items.
- `keyboard-shortcuts.md` — ⌘N / ⌘O / ⌘S / ⌘D conventions.
