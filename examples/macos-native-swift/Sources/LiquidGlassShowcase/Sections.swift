import SwiftUI

// MARK: - Section scaffolding

struct SectionHeader: View {
    let eyebrow: String
    let title: String
    let lede: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eyebrow.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(0.08 * 11)
                .foregroundStyle(.tertiary)
            Text(title)
                .font(.title2.bold())
            Text(lede)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Materials

struct MaterialsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Foundations",
                title: "Materials",
                lede: "Two variants: Regular (default, auto-legible) and Clear (more transparent — requires a dim layer for contrast). The native APIs are .glassEffect(.regular, in: ...) and .glassEffect(.clear, in: ...)."
            )

            GlassEffectContainer(spacing: Tokens.Spacing.panelGap) {
                HStack(spacing: Tokens.Spacing.panelGap) {
                    MaterialCard(label: "Regular",
                                 detail: ".glassEffect(.regular, in: rect)",
                                 backdrop: .photo)
                    MaterialCard(label: "Regular · tinted",
                                 detail: ".glassEffect(.regular.tint(.indigo))",
                                 backdrop: .tinted)
                }
            }

            Text("Clear variant is shown separately at the bottom — mixing variants in one group is an anti-pattern.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

enum Backdrop {
    case photo, tinted
}

struct MaterialCard: View {
    let label: String
    let detail: String
    let backdrop: Backdrop

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backdropView
            VStack(alignment: .leading, spacing: 4) {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.02 * 11)
                Text(detail)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(Tokens.Spacing.panelGap)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous))
            .padding(Tokens.Spacing.panelGap)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous))
    }

    @ViewBuilder
    private var backdropView: some View {
        switch backdrop {
        case .photo:
            ZStack {
                LinearGradient(colors: [Color(red: 0.29, green: 0.23, blue: 0.45),
                                         Color(red: 0.12, green: 0.10, blue: 0.18)],
                               startPoint: .top, endPoint: .bottom)
                RadialGradient(colors: [Color.pink.opacity(0.8), .clear],
                               center: .init(x: 0.25, y: 0.3), startRadius: 0, endRadius: 220)
                RadialGradient(colors: [Color.blue.opacity(0.7), .clear],
                               center: .init(x: 0.8, y: 0.7), startRadius: 0, endRadius: 240)
            }
        case .tinted:
            LinearGradient(colors: [.blue, .purple],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Shape

struct ShapeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Foundations",
                title: "Shape",
                lede: "Fixed radii: 12, 16, 24, 28. Capsule = height / 2. Concentric: child = parent − inset. ConcentricRectangle() resolves its radius from the nearest .containerShape."
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: Tokens.Spacing.panelGap) {
                RadiusSwatch(name: "sm", radius: Tokens.Radius.sm)
                RadiusSwatch(name: "md", radius: Tokens.Radius.md)
                RadiusSwatch(name: "lg", radius: Tokens.Radius.lg)
                RadiusSwatch(name: "xl", radius: Tokens.Radius.xl)
                RadiusSwatch(name: "capsule", radius: 9999)
            }

            ConcentricDemo()
        }
    }
}

struct RadiusSwatch: View {
    let name: String
    let radius: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            LinearGradient(colors: [Color(red: 0.78, green: 0.83, blue: 1.0),
                                     Color(red: 1.0, green: 0.85, blue: 0.92)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 72)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08))
                )
            Text(name).font(.subheadline.weight(.semibold))
            Text(radius == 9999 ? "height / 2" : "\(Int(radius)) pt")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(Tokens.Spacing.panelGap)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.md, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.md, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
    }
}

struct ConcentricDemo: View {
    var body: some View {
        HStack(alignment: .center, spacing: Tokens.Spacing.panelGap) {
            // Parent has containerShape with radius 28; child uses ConcentricRectangle
            // which automatically reads parent radius and insets by 8.
            RoundedRectangle(cornerRadius: Tokens.Radius.xl, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.78, green: 0.83, blue: 1.0),
                                              Color(red: 1.0, green: 0.85, blue: 0.92)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 120, height: 120)
                .containerShape(RoundedRectangle(cornerRadius: Tokens.Radius.xl, style: .continuous))
                .overlay(
                    ConcentricRectangle()
                        .fill(Color(nsColor: .windowBackgroundColor))
                        .padding(8)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text("Parent 28, inset 8, child 20.")
                    .font(.subheadline)
                Text("ConcentricRectangle() reads radius from .containerShape so insets stay parallel.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Tokens.Spacing.panelGap)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.md, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.md, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
    }
}

// MARK: - Spacing

struct SpacingSection: View {
    private let rows: [(String, CGFloat)] = [
        ("controlGap", Tokens.Spacing.controlGap),
        ("groupGap", Tokens.Spacing.groupGap),
        ("panelGap", Tokens.Spacing.panelGap),
        ("screenMargin (regular)", Tokens.Spacing.screenMarginRegular),
        ("sectionGap", Tokens.Spacing.sectionGap),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Foundations",
                title: "Spacing",
                lede: "One scale: 8 · 12 · 16 · 24 · 32. Apply by role — control gap, group gap, panel gap, screen margin, section gap."
            )
            VStack(spacing: Tokens.Spacing.controlGap) {
                ForEach(rows, id: \.0) { row in
                    HStack(spacing: Tokens.Spacing.panelGap) {
                        Text(row.0)
                            .font(.subheadline.weight(.semibold))
                            .frame(width: 180, alignment: .leading)
                        Capsule()
                            .fill(LinearGradient(colors: [.blue, .purple],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: row.1, height: 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(Int(row.1)) pt")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: Tokens.Radius.sm, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
            }
        }
    }
}

// MARK: - Typography

struct TypographySection: View {
    private let scale: [(String, Font, String)] = [
        ("caption2", .system(size: 11), "11 / 13 / 400"),
        ("caption1", .system(size: 12), "12 / 16 / 400"),
        ("footnote", .system(size: 13), "13 / 18 / 400"),
        ("subheadline", .system(size: 15), "15 / 20 / 400"),
        ("callout", .system(size: 16), "16 / 21 / 400"),
        ("body", .system(size: 17), "17 / 22 / 400"),
        ("headline", .system(size: 17, weight: .semibold), "17 / 22 / 600"),
        ("title3", .system(size: 20, weight: .semibold), "20 / 25 / 600"),
        ("title2", .system(size: 22, weight: .bold), "22 / 28 / 700"),
        ("title1", .system(size: 28, weight: .bold), "28 / 34 / 700"),
        ("largeTitle", .system(size: 34, weight: .bold), "34 / 41 / 700"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Foundations",
                title: "Typography",
                lede: "Falls through to the system font. Eleven steps from caption2 (11) to largeTitle (34)."
            )
            VStack(spacing: Tokens.Spacing.controlGap) {
                ForEach(scale, id: \.0) { row in
                    HStack(alignment: .firstTextBaseline, spacing: Tokens.Spacing.panelGap) {
                        Text(row.0)
                            .font(.system(.caption, design: .monospaced).weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 110, alignment: .leading)
                        Text("Glass refraction at scroll edges.")
                            .font(row.1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(row.2)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: Tokens.Radius.sm, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
            }
        }
    }
}

// MARK: - Motion

struct MotionSection: View {
    private let chips: [(String, Double, String)] = [
        ("instant", Tokens.Duration.instant, "80 ms · standard"),
        ("fast",    Tokens.Duration.fast,    "160 ms · standard"),
        ("base",    Tokens.Duration.base,    "240 ms · standard"),
        ("slow",    Tokens.Duration.slow,    "360 ms · standard"),
        ("sheet",   Tokens.Duration.sheet,   "420 ms · spring"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Foundations",
                title: "Motion",
                lede: "Hover any chip to play its duration and easing. Sheet uses spring; everything else uses the standard curve."
            )
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: Tokens.Spacing.controlGap) {
                ForEach(chips, id: \.0) { chip in
                    MotionChip(name: chip.0, duration: chip.1, detail: chip.2)
                }
            }
        }
    }
}

struct MotionChip: View {
    let name: String
    let duration: Double
    let detail: String
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name).font(.subheadline.weight(.semibold))
            Text(detail).font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
            Capsule()
                .fill(LinearGradient(colors: [.blue, .purple],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 6)
                .scaleEffect(x: isHovering ? 1 : 0.25, y: 1, anchor: .leading)
                .animation(name == "sheet" ? Tokens.Easing.spring : Tokens.Easing.standard(duration: duration),
                           value: isHovering)
                .padding(.top, 6)
        }
        .padding(Tokens.Spacing.panelGap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.sm, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.sm, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
        .onHover { isHovering = $0 }
    }
}

// MARK: - Buttons

struct ButtonsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Components",
                title: "Buttons",
                lede: "Capsule shape, 44 pt minimum height. Use .glassProminent for the primary action and .glass for secondary actions; .borderless for ghost. Subheadline weight 600."
            )
            ComponentCard(title: "Glass · GlassProminent · Borderless") {
                HStack(spacing: Tokens.Spacing.controlGap) {
                    Button("Continue") {}
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                    Button("Secondary") {}
                        .buttonStyle(.glass)
                        .controlSize(.large)
                    Button("Ghost") {}
                        .buttonStyle(.borderless)
                        .controlSize(.large)
                }
            }
            ComponentCard(title: "Icon button · 44pt capsule") {
                HStack(spacing: Tokens.Spacing.controlGap) {
                    ForEach(["plus", "square.and.arrow.up", "ellipsis"], id: \.self) { name in
                        Button {
                        } label: {
                            Image(systemName: name)
                                .font(.system(size: 18))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.glass)
                        .buttonBorderShape(.capsule)
                        .labelStyle(.iconOnly)
                    }
                }
            }
            ComponentCard(title: "Toolbar pill · GlassEffectContainer groups items") {
                GlassEffectContainer(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach([
                            ("arrowshape.turn.up.left", "Reply"),
                            ("arrowshape.turn.up.right", "Forward"),
                            ("archivebox", "Archive"),
                            ("trash", "Delete"),
                        ], id: \.0) { item in
                            Button {
                            } label: {
                                Image(systemName: item.0)
                                    .font(.system(size: 18))
                                    .frame(width: 40, height: 40)
                            }
                            .buttonStyle(.glass)
                            .buttonBorderShape(.capsule)
                            .help(item.1)
                        }
                    }
                    .padding(6)
                }
            }
        }
    }
}

// MARK: - Controls

struct ControlsSection: View {
    @State private var density: Density = .regular
    @State private var query: String = ""
    @State private var showsPopover = false

    enum Density: String, CaseIterable, Identifiable {
        case compact, regular, large
        var id: Self { self }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Components",
                title: "Controls",
                lede: "Segmented picker rides Regular glass. Text fields are always solid — glass behind text reduces readability."
            )

            ComponentCard(title: "Segmented · 32 pt, 2-5 items") {
                Picker("Density", selection: $density) {
                    ForEach(Density.allCases) { d in
                        Text(d.rawValue.capitalized).tag(d)
                    }
                }
                .pickerStyle(.segmented)
                .controlSize(.regular)
            }

            ComponentCard(title: "Text field · 44 min, SOLID") {
                TextField("Type to search…", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
            }

            ComponentCard(title: "Popover · floating Regular glass") {
                Button {
                    showsPopover.toggle()
                } label: {
                    Label("Open menu", systemImage: "ellipsis.circle")
                }
                .buttonStyle(.glass)
                .popover(isPresented: $showsPopover, arrowEdge: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        PopoverRow(icon: "star", label: "Favorite")
                        PopoverRow(icon: "arrow.down.circle", label: "Download")
                        PopoverRow(icon: "trash", label: "Delete")
                    }
                    .padding(8)
                    .frame(minWidth: 220)
                }
            }
        }
    }
}

struct PopoverRow: View {
    let icon: String
    let label: String
    var body: some View {
        HStack {
            Image(systemName: icon).frame(width: 18)
            Text(label).font(.callout)
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .onHover { _ in }
    }
}

// MARK: - Surfaces

struct SurfacesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Components",
                title: "Content surfaces",
                lede: "Cards stay SOLID. Glass is reserved for the floating layer — titlebar, sidebar, toolbar, popover, sheet. Content lives below it."
            )

            ContentCardView(
                title: "Why cards aren't glass",
                copy: "Glass behind body text shimmers under scroll and pulls contrast below WCAG AA on busy backgrounds. macOS 26 keeps glass in the navigation layer and content in the content layer. Cards use radius 24 and padding 24 from the spec on a solid surface."
            )
            ContentCardView(
                title: "Concentric children",
                copy: "The card's children use radius 12 to stay concentric inside it (24 − 12 inset = 12). SwiftUI's ConcentricRectangle reads the parent .containerShape automatically."
            )
        }
    }
}

struct ContentCardView: View {
    let title: String
    let copy: String

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.groupGap) {
            Text(title).font(.title3.weight(.semibold))
            Text(copy)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Tokens.Radius.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
        .containerShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous))
    }
}

// MARK: - Sheet

struct SheetSection: View {
    let onOpen: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Components",
                title: "Sheet",
                lede: "Bottom-anchored modal that slides up with the spring easing. SwiftUI .sheet with .presentationDetents([.medium, .large]) gets Liquid Glass automatically."
            )
            Button("Open sheet", systemImage: "arrow.up.to.line") {
                onOpen()
            }
            .buttonStyle(.glass)
            .controlSize(.large)
        }
    }
}

// MARK: - Rules / Anti-patterns / Clear

struct RulesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Reference",
                title: "Where glass belongs",
                lede: "Glass in the functional / navigation layer. Solid in the content layer. One glass surface per layered region — never glass-on-glass."
            )
            ContentCardView(
                title: "Allowed",
                copy: "Titlebar + toolbar, sidebar, popover, menu, sheet, floating action button, primary action surfaces. The macOS 26 sidebar (NSSplitViewItem.sidebar) and toolbar (NSToolbar / SwiftUI .toolbar) pick up glass automatically."
            )
        }
    }
}

struct AntiPatternsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Reference",
                title: "Anti-patterns",
                lede: "These rules apply to native Liquid Glass surfaces."
            )
            ContentCardView(
                title: "Don't",
                copy: "Stack two glass surfaces. Put glass behind body text. Invent a blur, opacity, or radius outside the token table. Use a 12 pt radius on a 44 pt capsule. Mix Regular and Clear in one group. Ship without reduced-transparency, reduced-motion, or increased-contrast fallbacks. Claim Apple endorsement."
            )
        }
    }
}

struct ClearVariantSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            SectionHeader(
                eyebrow: "Foundations · advanced",
                title: "Clear variant",
                lede: "Clear is more transparent — only safe over rich media with a dim layer behind. The demo uses Clear alone; mixing variants in one group is an anti-pattern."
            )

            ZStack(alignment: .bottomLeading) {
                ZStack {
                    LinearGradient(colors: [Color(red: 0.29, green: 0.23, blue: 0.45),
                                             Color(red: 0.12, green: 0.10, blue: 0.18)],
                                   startPoint: .top, endPoint: .bottom)
                    RadialGradient(colors: [Color.pink.opacity(0.8), .clear],
                                   center: .init(x: 0.25, y: 0.3), startRadius: 0, endRadius: 220)
                    RadialGradient(colors: [Color.blue.opacity(0.7), .clear],
                                   center: .init(x: 0.8, y: 0.7), startRadius: 0, endRadius: 240)
                }

                // Required dim layer for Clear glass.
                Color.black.opacity(0.24)

                VStack(alignment: .leading, spacing: 4) {
                    Text("CLEAR")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.02 * 11)
                        .foregroundStyle(.white)
                    Text(".glassEffect(.clear, in: rect)")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(Tokens.Spacing.panelGap)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.clear, in: RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous))
                .padding(Tokens.Spacing.panelGap)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous))
        }
    }
}

// MARK: - Shared component card

struct ComponentCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(0.06 * 11)
                .foregroundStyle(.secondary)
            ZStack {
                LinearGradient(colors: [Color.pink.opacity(0.55), Color.blue.opacity(0.55)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                content()
                    .padding(Tokens.Spacing.controlGap)
            }
            .frame(minHeight: 88)
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md, style: .continuous))
        }
        .padding(Tokens.Spacing.panelGap)
        .background(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.lg, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
    }
}
