// Hand-maintained token values.
// Mirrors plugins/apple-agent-kit/skills/liquid-glass/references/tokens.md.

import SwiftUI

/// Liquid Glass design tokens.
///
/// Mirrors the native Liquid Glass token reference.
extension Tokens {
    enum Radius {
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 28
        static let capsule: CGFloat = 9999
    }
    enum Spacing {
        static let controlGap: CGFloat = 8
        static let groupGap: CGFloat = 12
        static let panelGap: CGFloat = 16
        static let screenMarginCompact: CGFloat = 16
        static let screenMarginRegular: CGFloat = 24
        static let sectionGap: CGFloat = 32
    }
    enum Duration {
        static let instant: Double = 80 / 1000.0  // seconds
        static let fast: Double = 160 / 1000.0  // seconds
        static let base: Double = 240 / 1000.0  // seconds
        static let slow: Double = 360 / 1000.0  // seconds
        static let sheet: Double = 420 / 1000.0  // seconds
    }
    enum Weight {
        static let regular: Int = 400
        static let medium: Int = 500
        static let semibold: Int = 600
        static let bold: Int = 700
    }
    enum TypeScale {
        static let caption2Size: CGFloat = 11
        static let caption2LineHeight: CGFloat = 13
        static let caption2Weight: Int = 400
        static let caption1Size: CGFloat = 12
        static let caption1LineHeight: CGFloat = 16
        static let caption1Weight: Int = 400
        static let footnoteSize: CGFloat = 13
        static let footnoteLineHeight: CGFloat = 18
        static let footnoteWeight: Int = 400
        static let subheadlineSize: CGFloat = 15
        static let subheadlineLineHeight: CGFloat = 20
        static let subheadlineWeight: Int = 400
        static let calloutSize: CGFloat = 16
        static let calloutLineHeight: CGFloat = 21
        static let calloutWeight: Int = 400
        static let bodySize: CGFloat = 17
        static let bodyLineHeight: CGFloat = 22
        static let bodyWeight: Int = 400
        static let headlineSize: CGFloat = 17
        static let headlineLineHeight: CGFloat = 22
        static let headlineWeight: Int = 600
        static let title3Size: CGFloat = 20
        static let title3LineHeight: CGFloat = 25
        static let title3Weight: Int = 600
        static let title2Size: CGFloat = 22
        static let title2LineHeight: CGFloat = 28
        static let title2Weight: Int = 700
        static let title1Size: CGFloat = 28
        static let title1LineHeight: CGFloat = 34
        static let title1Weight: Int = 700
        static let largeTitleSize: CGFloat = 34
        static let largeTitleLineHeight: CGFloat = 41
        static let largeTitleWeight: Int = 700
    }
    /// Numeric material values are retained for clients that need them. Native code should prefer
    /// `.glassEffect(.regular)` / `.glassEffect(.clear)` over these numerics;
    /// they are exposed so multi-target apps can read the same source.
    enum Glass {
        static let regularBlur: CGFloat = 40
        static let regularSaturation: Int = 180
        static let clearBlur: CGFloat = 28
        static let clearSaturation: Int = 160
    }
    /// Performance budget — caps on live-blurred surfaces per pane (B1).
    enum Budget {
        static let recommended: Int = 3
        static let busyTransient: Int = 5
        static let max: Int = 6
    }
    /// Rendering tiers retained for clients that use a tier label in telemetry.
    enum Tier: String, CaseIterable {
        case T0, T1, T2, T3
        static let `default`: Tier = .T1
    }
}
