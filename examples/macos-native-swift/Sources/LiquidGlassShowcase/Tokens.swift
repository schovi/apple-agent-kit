import SwiftUI

// Tokens namespace declaration + showcase-only helpers.
//
// Numeric values live in TokenValues.swift and mirror the native token
// reference. Easing helpers below stay hand-written because they wrap
// SwiftUI Animation factories (logic, not values).

enum Tokens { }

extension Tokens {
    enum Easing {
        // Curves come from the native token reference. Each helper returns a ready
        // SwiftUI Animation so call sites can write `.animation(Tokens.Easing.standard(duration: ...))`
        // instead of redeclaring control points.
        static func standard(duration: Double) -> Animation {
            .timingCurve(0.2, 0, 0, 1, duration: duration)
        }
        static func decelerate(duration: Double) -> Animation {
            .timingCurve(0, 0, 0, 1, duration: duration)
        }
        static func accelerate(duration: Double) -> Animation {
            .timingCurve(0.3, 0, 1, 1, duration: duration)
        }
        static let spring = Animation.spring(
            response: 0.42,
            dampingFraction: 0.65,
            blendDuration: 0
        )
    }
}

// Concentric helper — child = parent − inset.
func concentricRadius(parent: CGFloat, inset: CGFloat) -> CGFloat {
    max(0, parent - inset)
}

// Material roles — where the surface lives, not how it looks.
// Each role names the closest real Apple API for SwiftUI and AppKit.
// `liveBlur` decides whether the
// surface counts against the B1 performance budget.
enum MaterialRole: String, CaseIterable, Identifiable {
    case sidebar, toolbar, menu, popover, hud, sheet, header
    case windowBackground, content

    var id: String { rawValue }

    var liveBlur: Bool {
        switch self {
        case .windowBackground, .content: return false
        default: return true
        }
    }

    // SwiftUI rule-of-thumb. The real call site picks the right API; this
    // string documents the canonical choice for amateur copy-paste.
    var swiftuiHint: String {
        switch self {
        case .sidebar: return "NavigationSplitView sidebar (Glass.regular auto)"
        case .toolbar: return ".toolbar { ... } (Glass.regular auto)"
        case .menu: return "Menu / .contextMenu (system-applied)"
        case .popover: return ".popover(isPresented:arrowEdge:) (system-applied)"
        case .hud: return ".overlay(alignment:) + .glassEffect(.regular, in: .capsule)"
        case .sheet: return ".sheet { ... .presentationDetents([...]) } (system-applied)"
        case .header: return ".background(.regularMaterial) on sticky header"
        case .windowBackground: return "Color(nsColor: .windowBackgroundColor)"
        case .content: return "Color(nsColor: .controlBackgroundColor)"
        }
    }

    var appkitMaterial: String {
        switch self {
        case .sidebar: return ".sidebar"
        case .toolbar: return ".titlebar"
        case .menu: return ".menu"
        case .popover: return ".popover"
        case .hud: return ".hudWindow"
        case .sheet: return ".sheet"
        case .header: return ".headerView"
        case .windowBackground: return ".windowBackground"
        case .content: return "solid NSColor (no effect view)"
        }
    }
}
