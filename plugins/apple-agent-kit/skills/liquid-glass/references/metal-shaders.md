# Metal shaders for Liquid Glass (native)

`.glassEffect` covers the common case: any time you want a system-rendered
floating surface (toolbar, sidebar, popover, sheet, HUD), the Apple-provided
material is what you reach for. It samples the real backdrop, picks up the
right vibrancy, auto-degrades on `reduceTransparency`, and shares sampling
when grouped in a `GlassEffectContainer`.

This file is for the 5% of cases where that isn't enough:

- **Hero surfaces.** An onboarding card with chromatic dispersion. A
  marketing splash where the brand identity is the lensing itself.
- **Brand transitions.** A button-to-detail morph that needs custom
  refraction during the spring.
- **Effects Apple won't ship.** SDF-based liquid metaball merges, true
  Snell's-law refraction, head-tracked specular — none are in
  `.glassEffect`'s vocabulary.

The Apple APIs that let you reach in are `View.layerEffect(_:maxSampleOffset:isEnabled:)`
and `View.colorEffect(_:isEnabled:)`. Both run a Metal fragment shader as
part of the SwiftUI render pass. Cost is one offscreen pass per surface
plus shader execution; the surface bypasses Apple's `glassEffect`
optimizations (shared sampling, automatic accessibility degradation),
so use sparingly and own the fallback path yourself.

## When to use which

| Modifier | Input | Output | Use it for |
|---|---|---|---|
| `colorEffect(_:)`              | Per-pixel position + sampled color from the view itself | Replacement color | Hue shifts, posterize, dithering, contrast remap on the view's own content. No backdrop sampling. |
| `layerEffect(_:maxSampleOffset:)` | Per-pixel position + a `layer` argument that lets the shader sample arbitrary offsets | Replacement color | Refraction, blur, displacement — anything that needs to "look at" other pixels in the surface bounds. |
| `distortionEffect(_:maxSampleOffset:)` | Per-pixel destination position | A *source* position to read from | Pure geometric distortion (warp, swirl, lens) where the input pixel maps to a different location. Same cost class as `layerEffect`. |

Liquid Glass refraction needs to sample offset pixels along the edge —
that's `layerEffect`. Pure tint transforms inside the surface are
`colorEffect`. Edge-warp without lighting is `distortionEffect`.

## A minimal lens refraction shader

The smallest useful shader for a hero glass surface: an SDF-based lens
that displaces inner pixels toward the surface center proportionally to
edge distance, producing the "thicker glass in the middle" look without
needing a real backdrop sample.

```metal
// Shaders.metal — see the "SwiftPM packaging gotchas" section below.
// SwiftPM does NOT compile .metal files during `swift build` / `swift run`;
// you need a build-script step to call `xcrun metal` + `xcrun metallib`
// and drop the artifact into Bundle.module. The SwiftUI call site must
// resolve via `ShaderLibrary.bundle(.module).lensRefract(...)`, not the
// default form — see below.

#include <metal_stdlib>
#include <SwiftUI/SwiftUI.h>
using namespace metal;

[[ stitchable ]] half4 lensRefract(float2 position,
                                   SwiftUI::Layer layer,
                                   float2 size,
                                   float strength) {
    float2 uv     = position / size;
    float2 center = float2(0.5, 0.5);
    float2 toCenter = uv - center;

    // Signed distance to a centered rounded-rect of half-extents 0.45.
    // r = corner radius in uv. Negative inside, positive outside.
    float r = 0.18;
    float2 q = abs(toCenter) - (float2(0.45, 0.45) - r);
    float  d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;

    // Edge-weighted refraction: strongest near d ≈ 0 (the rim),
    // fading toward both inside and outside.
    float rim       = exp(-pow(d * 24.0, 2.0));
    float2 offset   = -normalize(toCenter + 1e-5) * rim * strength;

    return layer.sample(position + offset * size);
}
```

Then in SwiftUI:

```swift
import SwiftUI

struct LensHero: View {
    var body: some View {
        Image("hero")
            .resizable()
            .scaledToFill()
            .frame(width: 320, height: 320)
            .clipShape(.rect(cornerRadius: 28))
            .layerEffect(
                // .bundle(.module) — NOT the implicit `ShaderLibrary.default`.
                // See "SwiftPM packaging gotchas" below.
                ShaderLibrary.bundle(.module).lensRefract(
                    .float2(320, 320),
                    .float(0.045)
                ),
                maxSampleOffset: CGSize(width: 32, height: 32)
            )
    }
}
```

`maxSampleOffset` is the budget you give Apple's compositor: it pre-grows
the source layer by that much so your shader's offsets don't sample
outside it. Pick the smallest value that covers your shader's worst-case
displacement — under-sizing produces cropped edges, over-sizing wastes
GPU memory.

## Adding dispersion and specular

Chromatic dispersion: sample R, G, B at slightly different offsets so
the edge color-fringes the way real glass does.

```metal
half3 dispersed(SwiftUI::Layer layer, float2 base, float2 offset) {
    half r = layer.sample(base + offset * 1.04).r;
    half g = layer.sample(base + offset).g;
    half b = layer.sample(base + offset * 0.96).b;
    return half3(r, g, b);
}
```

Specular highlight: add a Fresnel-style term to the shader output. The
Manav Kaushal write-up gives the canonical head-relative formulation;
in practice a fixed light direction works for static hero surfaces.

```metal
float fresnel  = pow(1.0 - dot(normalize(toCenter), float2(0.0, 1.0)), 3.0);
half3 highlight = half3(fresnel * 0.35);
return half4(dispersed(layer, position, offset) + highlight, 1.0);
```

For the production-grade math (full Snell's law with index-of-refraction,
SDF combinators for the liquid metaball merge, head-tracking via
`UIDeviceOrientation`), follow Victor Baro's two-part article series
linked in Sources below.

## SwiftPM packaging gotchas

Two non-obvious traps when shipping Metal shaders inside a Swift Package
target. Both are silent failures — the build succeeds, the runtime
renders the surface as transparent pixels, no error logged.

### `swift build` does not compile `.metal` files

SwiftPM compiles Swift sources and copies declared resources verbatim.
`.metal` files declared as `.process("Shaders.metal")` in
`Package.swift` land in the resource bundle as **raw source**, not as a
compiled `default.metallib`. `ShaderLibrary` has nothing to look up and
returns an invalid `Shader`. `.layerEffect` then renders the surface
fully transparent.

Fix: compile the shader yourself in a build-script step. After
`swift build`, call:

```bash
arch=$(uname -m)
bundle=".build/${arch}-apple-macosx/debug/<Target>_<Target>.bundle"

xcrun -sdk macosx metal    -c Sources/<Target>/Shaders.metal -o Shaders.air
xcrun -sdk macosx metallib    Shaders.air                    -o "${bundle}/default.metallib"
rm -f Shaders.air
```

The kit's showcase wires this into `examples/macos-native-swift/scripts/build.sh`
and `scripts/run.sh` execs the binary directly afterward instead of
calling `swift run` (which would re-trigger the resource copy and
overwrite the metallib).

On **Xcode 26+**, the Metal Toolchain ships as a downloadable
component:

```bash
xcodebuild -downloadComponent MetalToolchain
```

Run this once on any machine that needs to build shader-bearing
targets via SwiftPM. The Xcode-managed build (open the package via
`xed Package.swift`) handles compilation transparently; the gotcha is
specifically when building from the CLI.

### Use `ShaderLibrary.bundle(.module)`, not `ShaderLibrary.default`

`ShaderLibrary.default` (the implicit form invoked by writing
`ShaderLibrary.lensRefract(...)`) reads `default.metallib` from the
**main app bundle**. SwiftPM resources go into `Bundle.module` — a
**separate** metallib per target. The implicit form silently fails to
find the function and `.layerEffect` paints transparent.

Use the explicit form:

```swift
content.layerEffect(
    ShaderLibrary.bundle(.module).lensRefract(args),
    maxSampleOffset: ...
)
```

The dynamic-member-lookup form chains off the `ShaderLibrary`
returned by `.bundle(_:)`. Same call shape as the default form, just
scoped to the right bundle.

### Symptoms to recognize

If the demo card renders blank when reduce-transparency is OFF but
the gradient + text comes back when reduce-transparency is ON, you
have one of the above. Diagnose by replacing the shader body with
`return half4(1.0, 0.0, 0.0, 1.0);` and rebuilding — solid red means
the wiring is correct (the bug is elsewhere); still blank means
the shader isn't being invoked (the gotchas above).

## Performance budget

Shaders bypass the B1 live-blur count (a custom shader isn't a
`CABackdropLayer`) but they cost more per surface than `.glassEffect`
because Apple's shared-sampling optimization doesn't apply.

Rule of thumb for the native auditor:

- **One shader-driven hero surface per top-level pane** (sidebar,
  content, inspector). Multiple shader surfaces compete for offscreen
  texture allocations.
- **Never wrap a `.glassEffect` view in a shader** — the system
  glassEffect already snapshots; layering a shader on top samples a
  snapshot of a snapshot. Pick one or the other.
- **Fall back when `accessibilityReduceTransparency` is true.** Unlike
  `.glassEffect`, custom shaders do not auto-degrade. Branch on
  `@Environment(\.accessibilityReduceTransparency)` and skip the
  effect, or replace it with a static gradient.
- **Profile in Instruments → Metal System Trace.** The `layerEffect`
  pass shows up as a custom render pass. Frame budget on M1 is around
  4 ms for one full-screen `layerEffect` at 1× pixel scale.

## Accessibility — own the fallback

```swift
struct ShaderGlass<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let content: () -> Content

    var body: some View {
        if reduceTransparency {
            content()
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 28))
        } else {
            content()
                .clipShape(.rect(cornerRadius: 28))
                .layerEffect(ShaderLibrary.bundle(.module).lensRefract(.float(0.045)),
                             maxSampleOffset: CGSize(width: 32, height: 32))
        }
    }
}
```

Same branch should consider `accessibilityReduceMotion` if the shader
animates.

## Anti-patterns

- **`.layerEffect` mid-chain.** Like `.glassEffect`, it should be the
  last visual modifier. Falls under A14.
- **Shader on top of `.glassEffect`.** Double-sampling. Pick one. Folds
  conceptually into A1 (glass-on-glass) even though the inner surface
  isn't technically glass.
- **No reduce-transparency fallback.** Shaders do not auto-degrade.
  Mirrors A9.
- **Animating shader arguments without `withAnimation`.** Same trap as
  A18 for glass morph.

These do not get new audit IDs — they are extensions of existing IDs
the `apple-app-reviewer` already flags.

## When NOT to use a shader

If you find yourself reaching for a shader to replicate something
`.glassEffect` already does (tinted regular glass, capsule corner
refraction, default vibrancy), stop. The system primitive will look
better, run faster, and auto-degrade correctly. Shaders earn their
place when the system primitive *can't express the effect at all* —
brand-specific chromatic dispersion, SDF metaball merges, head-tracked
specular.

## Sources

- [Victor Baro — Implementing a Refractive Glass Shader in Metal](https://medium.com/@victorbaro/implementing-a-refractive-glass-shader-in-metal-3f97974fbc24) — strongest single source on refraction math.
- [Victor Baro — SDF in Metal: Adding the Liquid to the Glass](https://medium.com/@victorbaro/sdf-in-metal-adding-the-liquid-to-the-glass-69abd57e2151) — SDF combinators for metaball merge.
- [Hacking with Swift — How to add Metal shaders to SwiftUI views using layer effects](https://www.hackingwithswift.com/quick-start/swiftui/how-to-add-metal-shaders-to-swiftui-views-using-layer-effects) — the SwiftUI ↔ Metal glue.
- [twostraws/Inferno](https://github.com/twostraws/Inferno) — production shader library; lift patterns from there.
- [Manav Kaushal — Engineering behind Apple's Liquid Glass](https://medium.com/@manavkaushal756/engineering-behind-apple-liquid-glass-ui-fb51b1d599ad) — Fresnel + head-relative reflectance lighting model.
- [JuniperPhoton — Adopting Liquid Glass: experiences and pitfalls](https://juniperphoton.substack.com/p/adopting-liquid-glass-experiences) — the three-offscreen-texture cost baseline.
- [OverShifted/LiquidGlass](https://github.com/OverShifted/LiquidGlass) — open-source OpenGL reference outside the Apple stack; useful for understanding the underlying math.
