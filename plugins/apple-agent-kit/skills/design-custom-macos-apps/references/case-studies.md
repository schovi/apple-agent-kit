# Case studies

Lessons from shipping Mac apps that handled custom design and the macOS 26 (Tahoe) Liquid Glass change. Each entry gives the lesson, what the source says, and the evidence limit.

Sources were checked in October 2026. Re-check a source before you quote it as current.

## How to use these

- Use a case study as **precedent for a decision**, not as proof that the decision is right.
- These apps do not show what most developers or users prefer. They are a small, visible, opinionated sample.
- Do not claim a custom look caused an app's success. Utility, reliability, accessibility, pricing, and interaction quality all matter, and these sources do not separate them.
- Developer posts and changelogs describe intent and appearance. They rarely name APIs. Do not infer exact API adoption from them.

## Things (Cultured Code)

**Lesson:** a custom product layout and platform materials can coexist.

- For OS 26, Things added "a touch of glass in the sidebar", "new glassy buttons", and a Magic Plus button with a "liquid nature". It also rounded windows and controls and widened spacing.
- Brent Simmons (NetNewsWire) notes the Things toolbar is "not an NSToolbar", so its chrome is custom.

**Limits:** the post never says "Liquid Glass" and does not describe a full material adoption. It does not say which APIs were used.

Source: https://culturedcode.com/things/blog/2025/09/things-for-os-26/ (2025-09-15)

## Bear

**Lesson:** distinguish a similar appearance from full material adoption. Theme systems and system materials can pull in different directions.

- Bear refreshed its toolbar "to match the new OS style" and made the sidebar "blend naturally with Tahoe", while keeping its "clean, minimal essence".
- In a community thread about a sidebar that stays dark with light themes, a reply says: "On macOS 26, we opted for a UI similar to Liquid Glass but without adopting it entirely."
- Users in the same thread ask for per-theme sidebar control.

**Limits:** the blog post does not mention themes. The thread reply is not marked as staff on the page. Treat it as likely, not confirmed, developer intent.

Sources:
- https://blog.bear.app/2025/09/bear-is-now-com-paw-tible-with-new-oses-with-adapted-glassy-look/ (2025-09-17)
- https://community.bear.app/t/sidebar-is-always-dark/18818 (thread from 2026-02)

## Craft

**Lesson:** surrounding controls can change while the content experience stays the focus.

- In its OS 27 update, Craft adjusted components "to let the refractions of the glass shine" and placed Mac sidebars "directly on the window surface, letting the document in the center shine".

**Limits:** the post is about macOS 27, not 26. The blog has no OS 26 post. It does not say outright that the document view stayed unchanged.

Source: https://www.craft.do/blog/craft-update-3-6-5 (2026-09)

## Fantastical (Flexibits)

**Lesson:** specialized domain UI can sit inside platform materials. Adoption decisions can also be revised.

- For OS 26, Fantastical moved to "glass toolbars and menus" across platforms.
- For macOS 27, a Mac refresh "brings back the sidebar look that users know and love".

**Limits:** neither post discusses the calendar grid itself. The reason for the sidebar change is not stated beyond user familiarity.

Sources:
- https://flexibits.com/blog/2025/09/apple-os-26-updates-starring-fantastical-4-1-and-cardhop-2-4/ (2025-09-15)
- https://flexibits.com/blog/2026/09/apples-latest-dropped-and-so-did-fantastical-4-2-cardhop-2-5/ (2026-09-14)

## Rogue Amoeba (SoundSource, Audio Hijack)

**Lesson:** selective adoption can put clarity first. Accept or reject platform conventions one at a time, with a reason for each.

- SoundSource 6 rejected the Tahoe control-centre direction as "less compact and less legible", including sliders that hide knobs until hover. "The actual glass part of Liquid Glass is something we're mostly steering clear of."
- It accepted concentric shapes ("a refreshing aspect") and, reluctantly, the squircle icon shape.
- Stated principle: work "harmoniously alongside Apple's designs, but they don't need to match exactly".
- Audio Hijack 4 (2022, before Liquid Glass) simplified its sidebar so the UI stays "deferential to each session's audio grid".

**Limits:** one developer's design rationale. It does not report user outcomes.

Sources:
- https://weblog.rogueamoeba.com/2026/05/07/soundsource-6-design-stories/ (2026-05-07)
- https://weblog.rogueamoeba.com/2022/09/09/the-design-of-audio-hijack-4/ (2022-09-09)

## DaisyDisk and CleanShot

**Lesson:** compatibility announcements, new icons, and visual refreshes do not prove in-app API adoption.

- DaisyDisk shipped Tahoe compatibility fixes and "dark and liquid glass icons".
- CleanShot shipped an "updated app icon for macOS Tahoe" and a "sleek new interface for macOS Tahoe" with no detail.

**Limits:** neither source names glass toolbars, glass effects, or APIs. Do not cite either app as an example of in-app Liquid Glass.

Sources:
- https://daisydiskapp.com/blog/daisydisk-4-32-released/ (2025-09-26)
- https://daisydiskapp.com/blog/daisydisk-4-33/ (2026-01-03)
- https://cleanshot.com/changelog (4.8.3, 2025-09-10; 4.8.5, 2025-12-02)

## NetNewsWire

**Lesson:** standard components can still need substantial work after an OS change. "Native" is not automatically cheaper.

- Brent Simmons: "NetNewsWire has a very stock Mac UI, and Liquid Glass adoption last year was a lot of work. Using stock Mac UI didn't save us much — in fact, we had more work to do compared to the apps with more custom UI."
- An experiment to remove glass elements he dislikes would cost the use of `NSToolbar`. He says it is not shipping that way.

**Limits:** no specific components or bugs are listed. One app, one developer's account.

Source: https://inessential.com/2026/09/22/that-about-wraps-it-up-for.html (2026-09-22)

## Apple references

- Designing for macOS: https://developer.apple.com/design/human-interface-guidelines/designing-for-macos
- Adopting Liquid Glass: https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass
- Applying Liquid Glass to custom views (SwiftUI): https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views
- Build an AppKit app with the new design, WWDC25 session 310: https://developer.apple.com/videos/play/wwdc2025/310/
- `ButtonStyle`: https://developer.apple.com/documentation/swiftui/buttonstyle
- SwiftUI accessibility fundamentals: https://developer.apple.com/documentation/swiftui/accessibility-fundamentals
- SwiftUI focus: https://developer.apple.com/documentation/swiftui/focus
- `NSTextInputClient`: https://developer.apple.com/documentation/appkit/nstextinputclient
- `NSGlassEffectView` (macOS 26.0+): https://developer.apple.com/documentation/appkit/nsglasseffectview
