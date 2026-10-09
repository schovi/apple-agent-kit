# Menu bar — required structure and per-menu standards

Mac users rely on the menu bar to learn what an app does and find the commands they need. A consistent menu bar is the single biggest "feels like Mac" signal after drag-and-drop. Distilled from Apple HIG, "The menu bar" chapter.

## Anatomy — required menu order

When present in the menu bar, the following menus appear in this exact order:

1. **YourAppName** (short version of the app name)
2. **File**
3. **Edit**
4. **Format**
5. **View**
6. **App-specific menus**, if any
7. **Window**
8. **Help**

The Apple menu sits on the leading side (system-owned, never modify). Menu bar extras sit on the trailing side (see `menu-bar-extra.md`).

## Best practices

- **Support the default system-defined menus and ordering.** People expect menus and items in a familiar order. In many cases the system implements the standard items so you don't have to — Edit > Copy works out of the box for standard `TextField` / `NSTextView`.
- **Always show the same set of menu items.** Visibility teaches what the app supports. If an item isn't actionable in the current state, **disable** it — don't hide it.
- **Use menu item images sparingly.** From macOS 27, AppKit hides most menu item images by default and decides visibility from system configuration. Add an image only where it carries meaning (a color, a document type). Force it with `NSMenuItem.preferredImageVisibility = .visible` (macOS 27+) or SwiftUI `.labelStyle(.titleAndIcon)`. Use system SF Symbols for standard items.
- **Support the standard keyboard shortcuts** for the standard items. Define custom shortcuts only when necessary. See `keyboard-shortcuts.md`.
- **Prefer short, one-word menu titles.** If you need more than one word, use title-style capitalization.

## App menu

Lists items that apply to the app as a whole. The menu bar shows your app name in bold.

| Menu item | Action | Guidance |
|---|---|---|
| About YourAppName | Displays About window with copyright/version. | Prefer ≤16 characters. Don't include a version number in the menu title. |
| Settings… | Opens settings (macOS) / Settings page (iPadOS). | Use only for app-level settings. Document-specific settings go in File. |
| Optional app-specific items | Custom app-level settings. | List after Settings, same group. |
| Services | Submenu of services from system + other apps. | macOS only. |
| Hide YourAppName | Hides app + windows. | Same short name as About. |
| Hide Others | Hides all other apps. | |
| Show All | Shows all other apps behind yours. | |
| Quit YourAppName | Quits. Option → "Quit and Keep Windows". | Same short name. |

Display About first, with a separator after it so it sits alone.

## File menu

Commands that manage files / documents. Rename or eliminate if your app handles no files.

| Menu item | Action | Guidance |
|---|---|---|
| New Item | Creates a new document / file / window. | For "Item", use a term that names the type (Event, Calendar, Note). |
| Open… | Opens selected item or presents picker. | Ellipsis if more input required. |
| Open Recent | Submenu of recent docs + "Clear Menu". | Use filenames, not paths. Most recent first. |
| Close | Closes window / document. Option → Close All. | Tab windows: "Close Tab" replaces "Close"; consider adding "Close Window" too. |
| Close Tab | Closes current tab. Option → Close Other Tabs. | |
| Close File | Closes current file + all its windows. | Support if multiple views per file. |
| Save | Saves current document. | Autosave automatically. Prompt for name / location on first save. Prefer a format pop-up in the Save sheet over multiple "Save As" items. |
| Save All | Saves all open documents. | |
| Duplicate | Duplicates, leaves both open. Option → "Save As". | **Prefer Duplicate** to Save As / Export / Copy To / Save To — clearer relationship. |
| Rename… | Renames current doc. | |
| Move To… | Move document to new location. | |
| Export As… | Prompts for name / location / format; original stays open. | Reserve for formats your app doesn't typically handle. |
| Revert To | Submenu of recent versions + version browser (when autosave on). | |
| Page Setup… | Paper size, orientation. | Include if you need per-document print params. Global / frequent params belong in the Print panel. |
| Print… | Standard Print panel. | |

## Edit menu

Top-level items, in order:

- **Undo** — clarify target: "Undo Paste and Match Style", "Undo Typing".
- **Redo** — same pattern.
- **Cut**, **Copy**, **Paste**, **Paste and Match Style**, **Delete** — use **Delete** (not Erase / Clear) to match the Delete key.
- **Select All**
- **Find** — submenu: Find, Find and Replace, Find Next, Find Previous, Use Selection for Find, Jump to Selection.
- **Spelling and Grammar** — submenu: Show Spelling and Grammar, Check Document Now, Check Spelling While Typing, Check Grammar With Spelling, Correct Spelling Automatically.
- **Substitutions** — Show Substitutions, Smart Copy/Paste, Smart Quotes, Smart Dashes, Smart Links, Data Detectors, Text Replacement.
- **Transformations** — Make Uppercase, Make Lowercase, Capitalize.
- **Speech** — Start Speaking, Stop Speaking.
- **Start Dictation** — system adds automatically.
- **Emoji & Symbols** — system adds automatically.

## Format menu

Exclude if no formatted text editing.

- **Font** submenu: Show Fonts, Bold, Italic, Underline, Bigger, Smaller, Show Colors, Copy Style, Paste Style.
- **Text** submenu: Align Left, Align Center, Justify, Align Right, Writing Direction, Show Ruler, Copy Ruler, Paste Ruler.

## View menu

Customizes the appearance of all windows (not navigation between windows — that's the Window menu).

Provide a View menu even if minimal (e.g. only Enter / Exit Full Screen).

Each show / hide title must reflect current state — "Show Toolbar" when hidden, "Hide Toolbar" when visible.

- Show / Hide Tab Bar
- Show All Tabs / Exit Tab Overview
- Show / Hide Toolbar
- Customize Toolbar
- Show / Hide Sidebar
- Enter / Exit Full Screen

## App-specific menus

Appear between View and Window. Examples: Safari uses History, Bookmarks; Mail uses Mailbox, Message.

- **Provide app-specific menus for custom commands.** Users look in the menu bar first. Excluding commands — even advanced ones — risks making them hard to find.
- **Reflect app hierarchy.** Mail: Mailbox → Message → Format.
- **Order from most general to most specialized.**

## Window menu

Navigate / organize / manage windows. Does not customize appearance (View) or close (File).

Provide even with one window — include Minimize and Zoom so Full Keyboard Access users can invoke them.

- **Minimize** — Option → Minimize All.
- **Zoom** — toggle between content-appropriate size and user-set size. Option → Zoom All. **Don't use Zoom for full screen.**
- **Show Previous Tab / Show Next Tab**
- **Move Tab to New Window**
- **Merge All Windows**
- **Enter / Exit Full Screen** — only if no View menu. Still provide separate Minimize and Zoom.
- **Bring All to Front** — Option → Arrange in Front (tiled).
- **Open window names** — list alphabetically; skip panels / modals.

## Help menu

Trailing end of the menu bar. Help Book format → system adds a search field automatically.

- Send YourAppName Feedback to Apple
- YourAppName Help
- Additional Item — use a separator. Keep total small. Link from inside help docs instead.

## Dynamic menu items

Items that change on modifier (Control, Option, Shift, Command).

- **Never the only way** to accomplish a task — they're hidden by default.
- **Primarily in menu bar menus** — avoid in contextual / Dock menus (harder to discover).
- **Single modifier key only.**

## Dock menu (macOS only)

Secondary-click on the app's Dock icon reveals a Dock menu with system items + custom items.

- **Label items succinctly, organize logically.**
- **Make custom Dock menu items available elsewhere.** Not everyone uses the Dock menu — also put commands in the menu bar or UI.
- **Prefer high-value custom items.** Dock menus are great for:
  - Listing currently / recently open windows (jump-to).
  - A few actions useful when the app isn't frontmost or has no open windows (Mail: Get New Mail, New Message).

## SwiftUI wiring

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note") { newNote() }
                    .keyboardShortcut("n", modifiers: .command)
            }
            CommandGroup(after: .toolbar) {
                Button("Toggle Inspector") { toggleInspector() }
                    .keyboardShortcut("i", modifiers: [.command, .option])
            }
        }
    }
}
```

`CommandGroup(replacing:)` and `CommandGroup(after:)` slot into the standard menus. Use `.disabled(...)` to dim items by state, never hide.

## AppKit wiring

`NSMenu` + `NSMenuItem` in the app's main menu nib / xib, or built programmatically in `applicationDidFinishLaunching`. Each `NSMenuItem` carries `keyEquivalent` + `keyEquivalentModifierMask`.

## Sources

- Apple HIG — The menu bar: <https://developer.apple.com/design/human-interface-guidelines/the-menu-bar>
- Apple HIG — Dock menus: <https://developer.apple.com/design/human-interface-guidelines/dock-menus>

## See also

- `keyboard-shortcuts.md` — what NOT to override; modifier conventions.
- `menu-bar-extra.md` — the trailing-side icon (status item).
- `file-management.md` — File menu details (autosave, Quick Look, Save dialog).
- `windows-and-full-screen.md` — Window menu rules and full-screen behavior.
