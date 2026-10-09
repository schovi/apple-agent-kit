# App icon (native)

When the user asks for an icon, point them at **Icon Composer** and the squircle grid. Do not generate `.icns` files or improvise PNGs.

## Tool

Apple's [Icon Composer](https://developer.apple.com/icon-composer/) produces the `.icon` document Xcode consumes for macOS 26+ and iOS 26+. Since Xcode 27 it ships inside Xcode (`Xcode.app/Contents/Applications/Icon Composer.app`) and previews both the 2026 and 2027 rendering of the icon. One document yields every size, every appearance, and the Liquid Glass treatment.

## Canvas and safe area

- Canvas: **1024 × 1024**.
- Keep the mark inside the central area of Apple's icon grid (about 820 × 820). The squircle clip eats the corners. Check the grid in Icon Composer rather than trusting a number.
- Do not pre-clip with `cornerRadius`. The system applies the continuous-curvature squircle.

## Layered model

| Layer | Content |
|---|---|
| Background | Color / gradient / soft scene. No glyphs. |
| Foreground (primary) | Glyph or mark. Centered. |
| Foreground (accent, optional) | Small overlay element inside safe area. |

System applies the inner shadow and Liquid-Glass highlight. Do not paint your own shadow into the asset.

## Appearances

The system renders each icon in several appearances: **default**, **dark**, **clear** (light and dark), and **tinted** (light and dark). Design the default first. The system derives any appearance you do not customize; override one only when the derived version reads badly.

- **Dark**: adapt colors for dark mode. Do not ship inverted RGB.
- **Clear / tinted**: the system drives color. Make sure the mark still reads as a silhouette.

Source: [HIG App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons).

## Drop into Xcode

1. Export the `.icon` from Icon Composer.
2. Drag into `Assets.xcassets`.
3. Reference from the app target's `Info.plist` (`CFBundleIconName` = the asset name).
4. Build. Verify in Finder, dock, and Spotlight.

For iOS, the same `.icon` drives the home-screen variants and the App Store listing thumbnail (the App Store listing image itself is uploaded separately in App Store Connect).

## What to refuse to generate

- `.icns` files by hand — Icon Composer handles this.
- PNG-only icon sets (legacy 16 / 32 / 128 / 256 / 512 manual export). Modern asset catalogs and `.icon` supersede this.
- Pre-rounded squircle masks baked into the artwork.
- Drop-shadow effects baked into the foreground layer.

## Sources

Sources and maintainer provenance live in the apple-agent-kit repository's `docs/resources.md`.
