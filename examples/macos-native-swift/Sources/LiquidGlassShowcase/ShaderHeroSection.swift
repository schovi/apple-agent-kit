import SwiftUI

// Hero surface that calls Apple's `.layerEffect` modifier with the
// `lensRefract` Metal shader from Shaders.metal. Documented end-to-end
// in plugins/apple-agent-kit/skills/liquid-glass/references/metal-shaders.md.
//
// What the section demonstrates:
//   - When to reach for `.layerEffect` instead of `.glassEffect` (only
//     when the system primitive can't express the effect).
//   - How to size `maxSampleOffset` to the worst-case displacement so
//     the compositor pre-grows the source layer correctly.
//   - The reduce-transparency fallback (custom shaders do NOT auto-degrade —
//     the implementer must branch on the environment value).
//
// This sits alongside the B1 budget — shader-driven heroes are capped at
// ONE per top-level pane. See references/performance-budget.md.

struct ShaderHeroSection: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Pattern",
                title: "Shader hero (.layerEffect)",
                lede: "Metal shader for hero surfaces where `.glassEffect` is insufficient. One per pane; owns its reduce-transparency fallback.",
            )

            HStack(alignment: .top, spacing: Tokens.Spacing.panelGap) {
                heroSurface
                explainer
            }
        }
    }

    private var heroSurface: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.20, green: 0.62, blue: 0.95),
                         Color(red: 0.55, green: 0.22, blue: 0.85)],
                startPoint: .topLeading,
                endPoint:   .bottomTrailing,
            )

            // High-frequency grid behind the title. Smooth gradients hide
            // displacement; sharp lines reveal it. The shader's rim bell
            // curve clearly bends each grid line as it crosses the rounded
            // rect's boundary, which is the whole point of the demo.
            GridPattern(step: 20)
                .stroke(Color.white.opacity(0.18), lineWidth: 0.8)

            VStack(alignment: .leading, spacing: 6) {
                Text("Liquid Glass")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Refracted, not blurred.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(width: 280, height: 280)
        .clipShape(.rect(cornerRadius: Tokens.Radius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.xl, style: .continuous)
                .stroke(Color.white.opacity(reduceTransparency ? 0.6 : 0.15), lineWidth: 1)
        )
        .modifier(LensRefractIfAvailable(strength: 0.08, enabled: !reduceTransparency))
    }

    private var explainer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(reduceTransparency ? "Shader bypassed (reduce-transparency)" : "Lens refraction active",
                  systemImage: reduceTransparency ? "eye.slash" : "wand.and.stars")
                .font(.callout.weight(.semibold))

            Text("`.layerEffect` runs the `lensRefract` Metal shader. The SDF rim displaces inner pixels toward the center proportionally to edge distance — the way real glass thickens visually toward the middle.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Reaches for the system primitive first: `.glassEffect` covers every floating chrome surface. Shaders earn their place when the brief names an effect the primitive can't express — dispersion, SDF metaball merge, head-tracked specular.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Budget: one shader-driven hero per pane (sits alongside B1, not inside it). Reduce-transparency must be handled by the implementer — custom shaders do not auto-degrade.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: 320, alignment: .leading)
    }
}

// Evenly-spaced grid in the view's bounds. Pure geometry so the lensRefract
// shader has something high-frequency to refract — smooth gradients hide
// the displacement.
private struct GridPattern: Shape {
    let step: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var x: CGFloat = step
        while x < rect.width {
            path.move(to:    CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
            x += step
        }
        var y: CGFloat = step
        while y < rect.height {
            path.move(to:    CGPoint(x: 0,          y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
            y += step
        }
        return path
    }
}

// Wrap the shader application in a ViewModifier so the explainer can
// label the fallback path without restating the geometry. When
// reduce-transparency is on, the modifier returns the input unchanged —
// matching the reference doc's "own the fallback" rule.
private struct LensRefractIfAvailable: ViewModifier {
    let strength: Float
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            // ShaderLibrary.bundle(.module) is required because SwiftPM
            // compiles Shaders.metal into Bundle.module, not the main
            // bundle. ShaderLibrary.default (the implicit form) only
            // finds shaders in the main bundle's default.metallib, so
            // it silently produces an invalid Shader and `.layerEffect`
            // renders the surface as transparent pixels.
            content.layerEffect(
                ShaderLibrary.bundle(.module).lensRefract(
                    .float2(280, 280),
                    .float(strength),
                ),
                maxSampleOffset: CGSize(width: 32, height: 32),
            )
        } else {
            content
        }
    }
}
