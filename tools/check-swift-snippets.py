#!/usr/bin/env python3
"""Typecheck every ```swift block in the plugin against the installed macOS SDK.

Each block is wrapped in a template that matches its shape (file, view
builder, statement body, modifier chain, view struct) and typechecked on its
own with `swiftc -typecheck`.

Snippets lean on names from surrounding code (`$query`, `ContentView`,
`toolbarButton`). An unresolved name stops the type checker before it reaches
the Apple API call that follows, so the tool stubs unresolved names and
retries:
  `$name`      -> a generic `Binding` whose type is inferred from the call site
  `Name`       -> a placeholder `View` struct
  `name.`      -> a placeholder view (or `NSView` in AppKit statements)
  `name(`      -> a no-op function
  `name`       -> a generic value inferred from the call site

Result per block:
  PASS  compiles as written.
  SOFT  compiles only with stubs, or the remaining errors sit on lines that
        use a stub. The Apple API calls the checker could reach are fine.
  FAIL  API misuse (wrong label, missing member, unavailable on macOS, wrong
        argument order) on a line without stubs, or any error in a block that
        needed no stubs. These are the bugs this tool exists to catch.

Skip a block on purpose (a deliberately broken anti-pattern example) by
putting `<!-- swift-check: skip -->` on the line directly above the fence.

Usage: tools/check-swift-snippets.py [--target 26.0] [--verbose] [paths...]
Exit code 1 when any block FAILs.
"""

import argparse
import concurrent.futures
import os
import pathlib
import re
import subprocess
import sys
import tempfile

REPO = pathlib.Path(__file__).resolve().parent.parent
FENCE = re.compile(r"(?P<pre>[^\n]*)\n```swift[ \t]*\n(?P<body>.*?)\n```", re.S)
SKIP_MARKER = "<!-- swift-check: skip -->"
UNRESOLVED = re.compile(r"cannot find (?:type )?'([^']+)' in scope")
DIAGNOSTIC = re.compile(r"^[^:]+:(\d+):\d+: error: (.*)$")
MAX_STUB_ROUNDS = 6

# Errors that mean "wrong wrapper template", not "wrong API". When the first
# template produces one of these, the next candidate template is tried.
STRUCTURAL_ERROR = re.compile(
    r"expressions are not allowed at the top level|cannot be used with result builder"
    r"|^expected |consecutive statements|consecutive declarations|missing return"
    r"|unexpected non-void return|cannot convert return expression|cannot conform to 'View'"
    r"|property wrappers are not yet supported|only valid on methods"
)

# API misuse. Reported as a failure unless the line also uses a stub.
HARD_ERROR = re.compile(
    r"has no member|incorrect argument label|extra argument|missing argument"
    r"|unavailable in macOS|only available in macOS|must precede argument"
    r"|has been renamed|has been removed|is not a member type"
)

HELPERS = """
import SwiftUI
import AppKit

@MainActor func __binding<T>() -> Binding<T> { fatalError() }
@MainActor func __value<T>() -> T { fatalError() }

// SwiftPM synthesizes `Bundle.module` for targets with resources.
extension Bundle { static var module: Bundle { .main } }
"""

# Common receiver names. AppKit and SwiftUI snippets use the same names for
# different types, so each template family gets its own set.
SWIFTUI_PLACEHOLDERS = """
@MainActor var view: some View { Text("") }
@MainActor var content: some View { Text("") }
@MainActor var button: some View { Button("") {} }
@MainActor var sheet: some View { Text("") }
@MainActor var ns: Namespace.ID { Namespace().wrappedValue }
@MainActor var namespace: Namespace.ID { Namespace().wrappedValue }
"""

APPKIT_PLACEHOLDERS = """
@MainActor let view = NSView()
@MainActor let button = NSButton()
@MainActor let window = NSWindow()
@MainActor let contentView = NSView()
@MainActor let scrollView = NSScrollView()
@MainActor let splitViewController = NSSplitViewController()
@MainActor let toolbar = NSToolbar()
@MainActor let slider = NSSlider()
@MainActor let menu = NSMenu()
@MainActor let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
"""

APPKIT_TEMPLATES = {"statements"}

TEMPLATES = {
    "file": "{body}\n",
    "view": "@MainActor @ViewBuilder func __snippet() -> some View {{\n{body}\n}}\n",
    "statements": "@MainActor final class __Host: NSObject {{\nfunc __snippet() {{\n{body}\n}}\n}}\n",
    "modifiers": "@MainActor @ViewBuilder func __snippet() -> some View {{\nEmptyView()\n{body}\n}}\n",
    "view-struct": "struct __Snippet: View {{\n{members}\nvar body: some View {{\n{body}\n}}\n}}\n",
}

DECLARATION = re.compile(
    r"^(import |@main|(public |private |fileprivate |final |open )*(struct|class|enum|extension|protocol|func|actor|typealias) )"
)
PROPERTY = re.compile(r"^(@\w+(\([^)]*\))?\s+)+(private |public |fileprivate )?(var|let) ")


def first_code_line(body):
    for line in body.splitlines():
        stripped = line.strip()
        if stripped and not stripped.startswith("//"):
            return stripped
    return ""


def candidate_templates(body):
    first = first_code_line(body)
    appkit = re.search(r"\bNS[A-Z]\w+|addSubview|\bdelegate\b|#selector", body)
    if DECLARATION.match(first) or re.search(r"^(struct|class|extension|enum|final class) \w", body, re.M):
        return ["file"]
    if PROPERTY.match(first):
        return ["view-struct", "file"]
    if first.startswith("."):
        return ["modifiers"]
    if appkit or re.match(r"^(let|var|guard|if|for|switch|try|_ =)\b", first) or re.match(r"^[\w.\[\]?]+\s*[+\-]?=\s", first):
        return ["statements", "view"]
    return ["view", "statements"]


def strip_placeholders(body):
    """Turn prose placeholders like `{ ... }` into code the parser accepts."""
    body = re.sub(r"^\s*\.\.\.\s*$", "", body, flags=re.M)
    body = re.sub(r"\{\s*\.\.\.\s*\}", "{ }", body)
    body = re.sub(r"\(\s*\.\.\.\s*\)", "()", body)
    return body


def split_members(body):
    """Hoist leading property declarations out of a view-struct snippet."""
    members, rest, hoisting = [], [], True
    for line in body.splitlines():
        stripped = line.strip()
        if hoisting and (PROPERTY.match(stripped) or not stripped or stripped.startswith("//")):
            members.append(line)
        else:
            hoisting = False
            rest.append(line)
    return "\n".join(members), "\n".join(rest) or "EmptyView()"


class Stubs:
    def __init__(self, appkit):
        self.appkit = appkit
        self.declarations = []
        self.names = set()
        # Declared stand-ins (types, receivers, functions) can cause their own
        # label or member errors; generic `__binding()` / `__value()` cannot.
        self.declared = set()

    def add(self, name, body):
        """Declare a stub for `name`, rewriting `body` where needed. Returns the new body."""
        self.names.add(name)
        if name == "self":
            return body
        if name.startswith("$"):
            self.names.add(name[1:])
            return re.sub(re.escape(name) + r"\b", "__binding()", body)
        if name[0].isupper():
            self.declared.add(name)
            self.declarations.append(
                f"struct {name}: View, Identifiable, Hashable, Codable {{ var id = 0; init() {{}}; "
                f"init(_ arguments: Any...) {{}}; var body: some View {{ EmptyView() }} }}"
            )
            return body
        if re.search(rf"(?<![.\w$]){re.escape(name)}\s*\.", body):
            placeholder = "NSView()" if self.appkit else "EmptyView()"
            keyword = "let" if self.appkit else "var"
            value = f" = {placeholder}" if self.appkit else f": some View {{ {placeholder} }}"
            self.declared.add(name)
            self.declarations.append(f"@MainActor {keyword} {name}{value}")
            return body
        if re.search(rf"(?<![.\w$]){re.escape(name)}\s*\(", body):
            self.declared.add(name)
            self.declarations.append(f"@MainActor func {name}(_ arguments: Any...) {{}}")
            return body
        return re.sub(rf"(?<![.\w$]){re.escape(name)}\b(?!\s*:)", "__value()", body)


def render(template, body, stubs):
    prelude = HELPERS + (APPKIT_PLACEHOLDERS if template in APPKIT_TEMPLATES else SWIFTUI_PLACEHOLDERS)
    prelude += "\n".join(stubs.declarations) + "\n"
    if template == "view-struct":
        members, rest = split_members(body)
        return prelude + TEMPLATES[template].format(members=members, body=rest)
    return prelude + TEMPLATES[template].format(body=body)


def typecheck(source, target, sdk):
    with tempfile.TemporaryDirectory() as directory:
        path = pathlib.Path(directory, "snippet.swift")
        path.write_text(source)
        result = subprocess.run(
            ["xcrun", "swiftc", "-typecheck", "-parse-as-library", "-swift-version", "5",
             "-target", f"arm64-apple-macos{target}", "-sdk", sdk, str(path)],
            capture_output=True, text=True,
        )
    errors = []
    for line in result.stderr.splitlines():
        match = DIAGNOSTIC.match(line)
        if match:
            errors.append((int(match.group(1)), match.group(2)))
    return list(dict.fromkeys(errors))


def classify(errors, source, stubs, placeholders):
    if not errors:
        return "PASS" if not stubs.names else "SOFT"
    lines = source.splitlines()
    excusing = stubs.declared | placeholders

    def uses_stub(line_number):
        text = lines[line_number - 1] if 0 < line_number <= len(lines) else ""
        return any(re.search(rf"(?<![\w$.]){re.escape(name)}\b", text) for name in excusing)

    for line_number, message in errors:
        if HARD_ERROR.search(message) and not uses_stub(line_number):
            return "FAIL"
    return "SOFT" if stubs.names else "FAIL"


def placeholder_names(template):
    """AppKit placeholders stand in for SwiftUI views when a snippet lands in the wrong family."""
    text = APPKIT_PLACEHOLDERS if template in APPKIT_TEMPLATES else ""
    return set(re.findall(r"(?:let|var) (\w+)", text))


def check_template(body, template, target, sdk):
    stubs = Stubs(appkit=template in APPKIT_TEMPLATES)
    for _ in range(MAX_STUB_ROUNDS):
        source = render(template, body, stubs)
        errors = typecheck(source, target, sdk)
        missing = [match.group(1) for _, message in errors if (match := UNRESOLVED.search(message))]
        missing = [name for name in dict.fromkeys(missing) if name not in stubs.names]
        if not missing:
            break
        for name in missing:
            body = stubs.add(name, body)
    messages = [message for _, message in errors]
    structural = any(STRUCTURAL_ERROR.search(message) for message in messages)
    return classify(errors, source, stubs, placeholder_names(template)), template, messages, structural


def check_block(block, target, sdk):
    """Use the first template that fits the snippet's shape.

    Fall back to the next candidate only when the current one produced
    structural errors (wrong wrapper), never to escape an API error.
    """
    body = strip_placeholders(block["body"])
    attempts = []
    for template in candidate_templates(body):
        status, template, messages, structural = check_template(body, template, target, sdk)
        attempts.append((status, template, messages))
        if status == "PASS" or not structural:
            return status, template, messages
    rank = {"PASS": 0, "SOFT": 1, "FAIL": 2}
    return min(attempts, key=lambda attempt: rank[attempt[0]])


def collect_blocks(paths):
    blocks = []
    for root in paths:
        files = [root] if root.is_file() else sorted(root.rglob("*.md"))
        for file in files:
            text = file.read_text()
            for match in FENCE.finditer("\n" + text):
                if match.group("pre").strip() == SKIP_MARKER:
                    continue
                line = text[: max(match.start("body") - 1, 0)].count("\n") + 1
                blocks.append({"file": file, "line": line, "body": match.group("body")})
    return blocks


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("paths", nargs="*", type=lambda value: pathlib.Path(value).resolve(), default=[REPO / "plugins"])
    parser.add_argument("--target", default="26.0", help="minimum macOS version (default 26.0)")
    parser.add_argument("--verbose", action="store_true", help="also list SOFT blocks")
    arguments = parser.parse_args()

    sdk = subprocess.run(["xcrun", "--sdk", "macosx", "--show-sdk-path"], capture_output=True, text=True, check=True).stdout.strip()
    blocks = collect_blocks(arguments.paths)
    with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count()) as pool:
        results = list(pool.map(lambda block: check_block(block, arguments.target, sdk), blocks))

    counts = {"PASS": 0, "SOFT": 0, "FAIL": 0}
    for block, (status, template, errors) in zip(blocks, results):
        counts[status] += 1
        if status == "FAIL" or (status == "SOFT" and arguments.verbose):
            print(f"{status} {block['file'].relative_to(REPO)}:{block['line']} [{template}]")
            for error in errors[:4]:
                print(f"    {error}")

    print(f"\n{len(blocks)} blocks: {counts['PASS']} pass, {counts['SOFT']} soft (needed stubs), {counts['FAIL']} fail")
    print(f"SDK: {pathlib.Path(sdk).name}, target macOS {arguments.target}")
    return 1 if counts["FAIL"] else 0


if __name__ == "__main__":
    sys.exit(main())
