import SwiftUI

struct ContentView: View {
    @State private var selection: SectionID = .materials
    @State private var viewMode: ViewMode = .tokens
    @State private var query: String = ""
    @State private var isSheetPresented = false
    @State private var inspectorVisible = true

    var body: some View {
        NavigationSplitView {
            Sidebar(selection: $selection)
        } content: {
            DetailView(
                section: selection,
                onOpenSheet: { isSheetPresented = true }
            )
            .frame(minWidth: 520)
            .navigationTitle("Liquid Glass — macOS 26 Showcase")
            .searchable(text: $query, placement: .toolbar, prompt: "Search tokens…")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("View mode", selection: $viewMode) {
                        ForEach(ViewMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                ToolbarSpacer(.flexible)
                ToolbarItem {
                    Menu {
                        Button("Toggle appearance", systemImage: "circle.lefthalf.filled") {}
                        Button("Export tokens", systemImage: "arrow.down.circle") {}
                        Button("Add to favorites", systemImage: "star") {}
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                // ToolbarSpacer(.fixed) splits the Menu from the primary actions so
                // they don't share one glass capsule. sharedBackgroundVisibility(.hidden)
                // on each prominent item is the documented opt-out from the shared
                // background, guaranteeing the capsules render cleanly and keep
                // their tint colors distinct.
                ToolbarSpacer(.fixed)
                ToolbarItem {
                    Button {
                        // Share action placeholder.
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.pink)
                }
                .sharedBackgroundVisibility(.hidden)
                ToolbarSpacer(.fixed)
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isSheetPresented = true
                    } label: {
                        Label("New", systemImage: "plus")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.blue)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        } detail: {
            Inspector(section: selection)
                .frame(minWidth: 240, idealWidth: 260, maxWidth: 320)
        }
        .sheet(isPresented: $isSheetPresented) {
            NewEntrySheet(isPresented: $isSheetPresented)
        }
    }
}

enum ViewMode: String, CaseIterable, Identifiable {
    case tokens, components, motion
    var id: Self { self }
    var label: String {
        switch self {
        case .tokens: return "Tokens"
        case .components: return "Components"
        case .motion: return "Motion"
        }
    }
}

struct DetailView: View {
    let section: SectionID
    let onOpenSheet: () -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: Tokens.Spacing.sectionGap) {
                    ForEach(SectionID.allCases) { id in
                        Group {
                            switch id {
                            case .materials: MaterialsSection()
                            case .shape: ShapeSection()
                            case .spacing: SpacingSection()
                            case .typography: TypographySection()
                            case .motion: MotionSection()
                            case .buttons: ButtonsSection()
                            case .controls: ControlsSection()
                            case .inputsOverlays: InputsOverlaysSection()
                            case .formsLists: FormsListsSection()
                            case .surfaces: SurfacesSection()
                            case .sheet: SheetSection(onOpen: onOpenSheet)
                            case .commandPalette: CommandPaletteSection()
                            case .morphing: MorphingSection()
                            case .scrollEdgeEffects: ScrollEdgeEffectsSection()
                            case .shaderHero: ShaderHeroSection()
                            case .rules: RulesSection()
                            case .antiPatterns: AntiPatternsSection()
                            case .clearVariant: ClearVariantSection()
                            }
                        }
                        .id(id)
                    }

                    Text("Inspired by Apple's Liquid Glass, not Apple-endorsed. Tokens follow the plugin reference.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, Tokens.Spacing.sectionGap)
                }
                .padding(Tokens.Spacing.screenMarginRegular)
            }
            .scrollContentBackground(.hidden)
            .background(Color(nsColor: .controlBackgroundColor))
            .onChange(of: section) { _, new in
                withAnimation(Tokens.Easing.standard(duration: Tokens.Duration.base)) {
                    proxy.scrollTo(new, anchor: .top)
                }
            }
        }
    }
}

struct NewEntrySheet: View {
    @Binding var isPresented: Bool
    @State private var title: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.panelGap) {
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 36, height: 5)
                .frame(maxWidth: .infinity)

            Text("New entry")
                .font(.title2.bold())

            Text("Sheet rides Regular glass with the spring easing (420 ms). On macOS 26, Liquid Glass is applied automatically when presentationDetents includes a partial-height detent.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Untitled", text: $title)
                .textFieldStyle(.roundedBorder)
                .controlSize(.large)

            HStack(spacing: Tokens.Spacing.groupGap) {
                Spacer()
                Button("Cancel", role: .cancel) { isPresented = false }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                Button("Save") { isPresented = false }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
            }
        }
        .padding(Tokens.Spacing.screenMarginRegular)
        .frame(minWidth: 480, idealWidth: 560)
        .presentationDetents([.medium, .large])
    }
}
