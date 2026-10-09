import SwiftUI

struct Inspector: View {
    let section: SectionID

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
                inspectorGroup(label: "Section",
                               value: section.label)
                inspectorGroup(label: "Renderer",
                               value: "SwiftUI · .glassEffect()")
                inspectorGroup(label: "Variant",
                               value: section == .clearVariant ? "Clear" : "Regular")
                inspectorGroup(label: "Outer radius",
                               value: "28 pt (concentric to toolbar pill)")
                inspectorGroup(label: "Surface rule",
                               value: surfaceRule(for: section))
                inspectorGroup(label: "Accessibility",
                               value: "reduceTransparency · increaseContrast · reduceMotion (system-driven)")
                inspectorGroup(label: "Source spec",
                               value: "liquid-glass plugin reference")
            }
            .padding(Tokens.Spacing.screenMarginRegular)
        }
        .navigationTitle("Inspector")
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func surfaceRule(for section: SectionID) -> String {
        switch section {
        case .materials, .shape, .spacing, .typography, .motion:
            return "Foundational tokens; renderer-agnostic."
        case .buttons, .controls, .inputsOverlays:
            return "Floating layer; Regular glass on capsule."
        case .formsLists, .surfaces:
            return "Content layer; SOLID — glass forbidden."
        case .sheet:
            return "Modal surface; Regular glass auto on partial detent."
        case .commandPalette:
            return "Floating launcher; hud role over scrim; ⌘K toggle."
        case .morphing:
            return "Animated identity; one GlassEffectContainer + @Namespace."
        case .scrollEdgeEffects:
            return "Boundary treatment; only where chrome overlaps."
        case .shaderHero:
            return "Metal shader (.layerEffect); one per pane; owns reduce-transparency fallback."
        case .rules, .antiPatterns:
            return "Reference documentation."
        case .clearVariant:
            return "Clear glass; requires dim layer behind."
        }
    }

    @ViewBuilder
    private func inspectorGroup(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.06 * 11)
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.primary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: Tokens.Radius.sm, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Tokens.Radius.sm, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08))
                )
        }
    }
}
