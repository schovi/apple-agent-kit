# App icon (native)

When the user asks for an icon, point them at **Icon Composer** and the squircle grid. Do not generate `.icns` files or improvise PNGs.

## Tool

Apple's [Icon Composer](https://developer.apple.com/icon-composer/) ships the `.icon` asset Xcode consumes for macOS 26 and iOS 26. It produces all sizes, all variants (light / dark / tinted), and the Liquid-Glass-aware treatment from one document.

## Canvas and safe area

- Canvas: **1024 × 1024**.
- Safe area: **820 × 820** centered. Squircle clip eats the corners — content outside this square is at risk.
- Do not pre-clip with `cornerRadius`. The system applies the continuous-curvature squircle.

## Layered model

| Layer | Content |
|---|---|
| Background | Color / gradient / soft scene. No glyphs. |
| Foreground (primary) | Glyph or mark. Centered. |
| Foreground (accent, optional) | Small overlay element inside safe area. |

System applies the inner shadow and Liquid-Glass highlight. Do not paint your own shadow into the asset.

## Variants

All three required in the `.icon` document:

- **Light** — color version on light desktop / home screen.
- **Dark** — adapted for dark mode (don't ship inverted RGB).
- **Tinted** — foreground only; system paints the background.

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
