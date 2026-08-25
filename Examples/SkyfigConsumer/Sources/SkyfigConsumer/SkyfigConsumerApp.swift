import Skyfig
import SwiftUI

@main
struct SkyfigConsumerApp: App {
    var body: some Scene {
        WindowGroup {
            ConsumerTabShell()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    SkyfigTokens.Colors.Surface.secondary
                        .color(for: .light)
                        .ignoresSafeArea()
                )
                .ignoresSafeArea()
        }
    }
}

private struct ConsumerTabShell: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selection: Destination = .overview

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                NavigationSplitView {
                    List {
                        ForEach(Destination.allCases) { destination in
                            Button {
                                selection = destination
                            } label: {
                                Label(destination.title, systemImage: destination.systemImage)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier(destination.title)
                            .listRowBackground(
                                selection == destination
                                    ? SkyfigTokens.Colors.Fill.selected.color(for: colorScheme)
                                    : Color.clear
                            )
                        }
                    }
                    .navigationTitle("Skyfig")
                    .frame(minWidth: SkyfigTokens.Metrics.Ipad.sidebarWidth)
                } detail: {
                    destinationView
                }
            } else {
                compactTabs
            }
        }
        .tint(SkyfigTokens.Colors.Action.primary.color(for: colorScheme))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SkyfigTokens.Colors.Surface.secondary.color(for: colorScheme))
    }

    private var compactTabs: some View {
        GeometryReader { _ in
            TabView {
                ForEach(Destination.allCases) { destination in
                    Tab(destination.title, systemImage: destination.systemImage) {
                        destinationView(for: destination)
                    }
                }
            }
            .tabViewStyle(.automatic)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SkyfigTokens.Colors.Surface.secondary.color(for: colorScheme))
        }
    }

    @ViewBuilder private var destinationView: some View {
        destinationView(for: selection)
    }

    @ViewBuilder private func destinationView(for destination: Destination) -> some View {
        switch destination {
        case .overview: HomePreview()
        case .components: ComponentsShowcase()
        case .content: ContentShowcase()
        case .planning: PlanningShowcase()
        case .accessibility: AccessibilityMotionShowcase()
        }
    }

    private enum Destination: String, CaseIterable, Identifiable {
        case overview, components, content, planning, accessibility

        var id: Self { self }
        var title: String { rawValue.capitalized }
        var systemImage: String {
            switch self {
            case .overview: "square.grid.2x2.fill"
            case .components: "switch.2"
            case .content: "list.bullet"
            case .planning: "calendar"
            case .accessibility: "accessibility"
            }
        }
    }
}

private struct HomePreview: View {
    @Environment(\.colorScheme) private var colorScheme

    private var surface: Color {
        SkyfigTokens.Colors.Surface.primary.color(for: colorScheme)
    }

    private var secondarySurface: Color {
        SkyfigTokens.Colors.Surface.secondary.color(for: colorScheme)
    }

    private var primaryText: Color {
        SkyfigTokens.Colors.Text.primary.color(for: colorScheme)
    }

    private var secondaryText: Color {
        SkyfigTokens.Colors.Text.secondary.color(for: colorScheme)
    }

    private var actionPrimary: Color {
        SkyfigTokens.Colors.Action.primary.color(for: colorScheme)
    }

    private var actionOnPrimary: Color {
        SkyfigTokens.Colors.Action.onPrimary.color(for: colorScheme)
    }

    private var success: Color {
        SkyfigTokens.Colors.Status.success.color(for: colorScheme)
    }

    private var warning: Color {
        SkyfigTokens.Colors.Status.warning.color(for: colorScheme)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.xl) {
                    heroCard
                    typeScale
                    TypographyShowcaseSection(samples: AppleTypographyCatalog.home)
                    elevationAndCorners
                    ShadowShowcaseSection()
                    tokenStrip
                    semanticStatusStrip
                }
                .padding(SkyfigTokens.Spacing.lg)
            }
                .background(secondarySurface.ignoresSafeArea())
            .navigationTitle("Skyfig")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundStyle(actionPrimary)
                        .accessibilityLabel("Skyfig home")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: SkyfigTokens.Spacing.md) {
                        Button("Preview") {}
                            .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                            .foregroundStyle(actionPrimary)

                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                                .frame(width: 28, height: 28)
                                .background(actionPrimary, in: Circle())
                                .foregroundStyle(actionOnPrimary)
                        }
                        .accessibilityLabel("Add item")
                    }
                }
                #else
                ToolbarItem {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundStyle(actionPrimary)
                        .accessibilityLabel("Skyfig home")
                }
                ToolbarItem {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                            .frame(width: 28, height: 28)
                            .background(actionPrimary, in: Circle())
                            .foregroundStyle(actionOnPrimary)
                    }
                    .accessibilityLabel("Add item")
                }
                #endif
            }
        }
        .tint(actionPrimary)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.md) {
            Label("Design system preview", systemImage: "paintpalette.fill")
                .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                .foregroundStyle(actionPrimary)

            Text("Typed tokens, ready for your app.")
                .font(SkyfigTokens.Typography.headline.font(relativeTo: .title))
                .tracking(SkyfigTokens.Typography.headline.letterSpacing)
                .lineSpacing(SkyfigTokens.Typography.headline.lineSpacing)
                .foregroundStyle(primaryText)

            Text(
                "This app imports Skyfig as a package and uses its generated SwiftUI "
                    + "tokens for every visual value on this screen."
            )
                .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                .lineSpacing(SkyfigTokens.Typography.body.lineSpacing)
                .foregroundStyle(secondaryText)

            Button("Explore tokens") {}
                .buttonStyle(.borderedProminent)
                .tint(actionPrimary)
        }
        .padding(SkyfigTokens.Spacing.lg)
        .background(surface)
        .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
        .shadow(
            color: SkyfigTokens.Shadows.card.layers[0].color.color(for: colorScheme),
            radius: SkyfigTokens.Shadows.card.layers[0].blur,
            x: SkyfigTokens.Shadows.card.layers[0].x,
            y: SkyfigTokens.Shadows.card.layers[0].y
        )
    }

    private var typeScale: some View {
        VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) {
            Text("Typography")
                .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                .foregroundStyle(secondaryText)

            Text("Headline token")
                .font(SkyfigTokens.Typography.headline.font(relativeTo: .title))
                .foregroundStyle(primaryText)

            Text("Body token with generated line-height support.")
                .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                .lineSpacing(SkyfigTokens.Typography.body.lineSpacing)
                .foregroundStyle(secondaryText)
        }
        .padding(SkyfigTokens.Spacing.lg)
        .background(surface)
        .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
    }

    private var tokenStrip: some View {
        HStack(spacing: SkyfigTokens.Spacing.sm) {
            tokenSwatch("Action", actionPrimary)
            tokenSwatch("Surface", surface)
            tokenSwatch("Text", primaryText)
        }
    }

    private var elevationAndCorners: some View {
        HStack(spacing: SkyfigTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) {
                Image(systemName: "square.on.square")
                    .foregroundStyle(actionPrimary)
                Text("Elevation")
                    .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                    .foregroundStyle(primaryText)
                Text("Card shadow token")
                    .font(SkyfigTokens.Typography.body.font(relativeTo: .caption))
                    .foregroundStyle(secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SkyfigTokens.Spacing.md)
            .background(surface)
            .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
            .shadow(
                color: SkyfigTokens.Shadows.card.layers[0].color.color(for: colorScheme),
                radius: SkyfigTokens.Shadows.card.layers[0].blur,
                x: SkyfigTokens.Shadows.card.layers[0].x,
                y: SkyfigTokens.Shadows.card.layers[0].y
            )

            VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) {
                Image(systemName: "rectangle.on.rectangle")
                    .foregroundStyle(actionPrimary)
                Text("Corners")
                    .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                    .foregroundStyle(primaryText)
                Text("Card and control radii")
                    .font(SkyfigTokens.Typography.body.font(relativeTo: .caption))
                    .foregroundStyle(secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SkyfigTokens.Spacing.md)
            .background(surface)
            .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
        }
    }

    private var semanticStatusStrip: some View {
        HStack(spacing: SkyfigTokens.Spacing.sm) {
            tokenSwatch("Success", success)
            tokenSwatch("Warning", warning)
        }
    }

    private func tokenSwatch(_ name: String, _ color: Color) -> some View {
        VStack(spacing: SkyfigTokens.Spacing.xs) {
            RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control)
                .fill(color)
                .frame(height: 56)
                .overlay {
                    RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control)
                        .stroke(secondaryText.opacity(0.2), lineWidth: SkyfigTokens.BorderWidths.thin)
                }
            Text(name)
                .font(SkyfigTokens.Typography.body.font(relativeTo: .caption))
                .foregroundStyle(secondaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name) color token")
    }
}

private struct TabPlaceholder: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let symbol: String
    let message: String
    let typographySamples: [TypographySample]

    private var surface: Color {
        SkyfigTokens.Colors.Surface.primary.color(for: colorScheme)
    }

    private var background: Color {
        SkyfigTokens.Colors.Surface.secondary.color(for: colorScheme)
    }

    private var text: Color {
        SkyfigTokens.Colors.Text.primary.color(for: colorScheme)
    }

    private var secondaryText: Color {
        SkyfigTokens.Colors.Text.secondary.color(for: colorScheme)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.lg) {
                    Label(title, systemImage: symbol)
                        .font(SkyfigTokens.Typography.headline.font(relativeTo: .title))
                        .foregroundStyle(text)

                    VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) {
                        Text("Token-powered \(title.lowercased())")
                            .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                            .foregroundStyle(SkyfigTokens.Colors.Action.primary.color(for: colorScheme))
                        Text(message)
                            .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                            .lineSpacing(SkyfigTokens.Typography.body.lineSpacing)
                            .foregroundStyle(secondaryText)
                    }
                    .padding(SkyfigTokens.Spacing.lg)
                    .background(surface)
                    .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
                    .shadow(
                        color: SkyfigTokens.Shadows.card.layers[0].color.color(for: colorScheme),
                        radius: SkyfigTokens.Shadows.card.layers[0].blur,
                        x: SkyfigTokens.Shadows.card.layers[0].x,
                        y: SkyfigTokens.Shadows.card.layers[0].y
                    )

                    TypographyShowcaseSection(samples: typographySamples)

                    VStack(spacing: 0) {
                        tokenRow("Recently updated", "Today")
                        Divider().padding(.leading, SkyfigTokens.Spacing.lg)
                        tokenRow("Design-system status", "Ready")
                        Divider().padding(.leading, SkyfigTokens.Spacing.lg)
                        tokenRow("Open details", "›")
                    }
                    .background(surface)
                    .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
                }
                .padding(SkyfigTokens.Spacing.lg)
            }
            .background(background.ignoresSafeArea())
            .navigationTitle(title)
        }
    }

    private func tokenRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                .foregroundStyle(text)
            Spacer()
            Text(value)
                .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
                .foregroundStyle(secondaryText)
        }
        .padding(SkyfigTokens.Spacing.md)
    }
}

private struct TypographySample: Identifiable {
    let id: String
    let token: SkyfigTypographyToken
    let relativeTo: Font.TextStyle
    let purpose: String

    init(
        _ id: String,
        token: SkyfigTypographyToken,
        relativeTo: Font.TextStyle,
        purpose: String
    ) {
        self.id = id
        self.token = token
        self.relativeTo = relativeTo
        self.purpose = purpose
    }
}

private struct ShadowSample: Identifiable {
    let id: String
    let token: SkyfigShadowToken
    let purpose: String
}

private enum ShadowCatalog {
    static let samples = [
        ShadowSample(
            id: "Modal",
            token: SkyfigTokens.Shadows.modal,
            purpose: "Single drop layer with aliased fields"
        ),
        ShadowSample(
            id: "Floating panel",
            token: SkyfigTokens.Shadows.floatingPanel,
            purpose: "Two ordered drop layers"
        ),
        ShadowSample(
            id: "Search field",
            token: SkyfigTokens.Shadows.searchFieldInner,
            purpose: "Nested inner layer"
        ),
    ]
}

private enum AppleTypographyCatalog {
    static let home = [
        TypographySample(
            "Large Title",
            token: SkyfigTokens.Typography.Apple.largeTitle,
            relativeTo: .largeTitle,
            purpose: "Prominent screen titles"
        ),
        TypographySample(
            "Title 1",
            token: SkyfigTokens.Typography.Apple.title1,
            relativeTo: .title,
            purpose: "Primary hierarchical headings"
        ),
    ]

    static let library = [
        TypographySample(
            "Title 2",
            token: SkyfigTokens.Typography.Apple.title2,
            relativeTo: .title2,
            purpose: "Second-level headings"
        ),
        TypographySample(
            "Title 3",
            token: SkyfigTokens.Typography.Apple.title3,
            relativeTo: .title3,
            purpose: "Third-level headings"
        ),
        TypographySample(
            "Headline",
            token: SkyfigTokens.Typography.Apple.headline,
            relativeTo: .headline,
            purpose: "Emphasized section headings"
        ),
    ]

    static let activity = [
        TypographySample(
            "Body",
            token: SkyfigTokens.Typography.Apple.body,
            relativeTo: .body,
            purpose: "Comfortable multi-line reading"
        ),
        TypographySample(
            "Callout",
            token: SkyfigTokens.Typography.Apple.callout,
            relativeTo: .callout,
            purpose: "Short supporting callouts"
        ),
    ]

    static let profile = [
        TypographySample(
            "Subheadline",
            token: SkyfigTokens.Typography.Apple.subheadline,
            relativeTo: .subheadline,
            purpose: "Supporting hierarchy"
        ),
        TypographySample(
            "Footnote",
            token: SkyfigTokens.Typography.Apple.footnote,
            relativeTo: .footnote,
            purpose: "Secondary and legal details"
        ),
    ]

    static let search = [
        TypographySample(
            "Caption 1",
            token: SkyfigTokens.Typography.Apple.caption1,
            relativeTo: .caption,
            purpose: "Primary annotations"
        ),
        TypographySample(
            "Caption 2",
            token: SkyfigTokens.Typography.Apple.caption2,
            relativeTo: .caption2,
            purpose: "Compact secondary annotations"
        ),
    ]
}

private struct TypographyShowcaseSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let samples: [TypographySample]

    private var surface: Color {
        SkyfigTokens.Colors.Surface.primary.color(for: colorScheme)
    }

    private var primaryText: Color {
        SkyfigTokens.Colors.Text.primary.color(for: colorScheme)
    }

    private var secondaryText: Color {
        SkyfigTokens.Colors.Text.secondary.color(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.md) {
            Text(dynamicTypeSize.isAccessibilitySize
                ? "Accessibility Dynamic Type"
                : "Apple Dynamic Type")
                .font(SkyfigTokens.Typography.Apple.caption1.font(relativeTo: .caption))
                .foregroundStyle(SkyfigTokens.Colors.Action.primary.color(for: colorScheme))

            ForEach(samples) { sample in
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.xs) {
                    Text(sample.id)
                        .font(sample.token.font(relativeTo: sample.relativeTo))
                        .foregroundStyle(primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(sample.purpose)
                        .font(SkyfigTokens.Typography.Apple.caption1.font(relativeTo: .caption))
                        .foregroundStyle(secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(sample.id), \(sample.purpose)")
                .accessibilityIdentifier("Typography.\(sample.id)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SkyfigTokens.Spacing.lg)
        .background(surface)
        .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
    }
}

private struct ShadowShowcaseSection: View {
    @Environment(\.colorScheme) private var colorScheme

    private var surface: Color {
        SkyfigTokens.Colors.Surface.primary.color(for: colorScheme)
    }

    private var primaryText: Color {
        SkyfigTokens.Colors.Text.primary.color(for: colorScheme)
    }

    private var secondaryText: Color {
        SkyfigTokens.Colors.Text.secondary.color(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.md) {
            Text("Inferred shadow structures")
                .font(SkyfigTokens.Typography.Apple.headline.font(relativeTo: .headline))
                .foregroundStyle(primaryText)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 150), spacing: SkyfigTokens.Spacing.md)],
                spacing: SkyfigTokens.Spacing.md
            ) {
                ForEach(ShadowCatalog.samples) { sample in
                    VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) {
                        shadowPreview(sample.token)
                            .frame(height: 72)

                        Text(sample.id)
                            .font(SkyfigTokens.Typography.Apple.callout.font(relativeTo: .callout))
                            .foregroundStyle(primaryText)
                        Text(sample.purpose)
                            .font(SkyfigTokens.Typography.Apple.caption1.font(relativeTo: .caption))
                            .foregroundStyle(secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(SkyfigTokens.Spacing.md)
                    .background(surface)
                    .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(sample.id), \(sample.purpose)")
                    .accessibilityIdentifier("Shadow.\(sample.id)")
                }
            }
        }
    }

    @ViewBuilder
    private func shadowPreview(_ token: SkyfigShadowToken) -> some View {
        if let inner = token.layers.first(where: { $0.kind == .inner }) {
            RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control)
                .fill(
                    surface.shadow(
                        .inner(
                            color: inner.color.color(for: colorScheme),
                            radius: inner.blur,
                            x: inner.x,
                            y: inner.y
                        )
                    )
                )
        } else {
            RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control)
                .fill(surface)
                .modifier(DropShadowLayers(token: token, colorScheme: colorScheme))
        }
    }
}

private struct DropShadowLayers: ViewModifier {
    let token: SkyfigShadowToken
    let colorScheme: ColorScheme

    func body(content: Content) -> some View {
        token.layers.reduce(AnyView(content)) { view, layer in
            guard layer.kind == .drop else { return view }
            return AnyView(view.shadow(
                color: layer.color.color(for: colorScheme),
                radius: layer.blur,
                x: layer.x,
                y: layer.y
            ))
        }
    }
}

private struct ComponentsShowcase: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var selectedSegment = "Upcoming"
    @State private var isEnabled = true

    private var colors: ShowcaseColors { ShowcaseColors(colorScheme: colorScheme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.xl) {
                    ShowcaseHeader(
                        title: "Components",
                        detail: "State roles keep custom controls legible in light and dark appearance.",
                        symbol: SkyfigTokens.Symbols.Navigation.overview
                    )
                    componentButtons
                    searchAndSelection
                    controlStates
                }
                .frame(maxWidth: SkyfigTokens.Metrics.Layout.readableWidth)
                .padding(SkyfigTokens.Spacing.lg)
            }
            .background(colors.grouped.ignoresSafeArea())
            .navigationTitle("Components")
        }
    }

    private var componentButtons: some View {
        ShowcaseCard(title: "Button states") {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: SkyfigTokens.Spacing.md) { buttonRow }
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) { buttonRow }
            }
        }
    }

    @ViewBuilder private var buttonRow: some View {
        Button("Primary") {}
            .frame(minHeight: SkyfigTokens.Metrics.Button.height)
            .padding(.horizontal, SkyfigTokens.Metrics.Button.horizontalInset)
            .background(colors.primaryButton, in: Capsule())
            .foregroundStyle(colors.onPrimary)
        Button("Secondary") {}
            .frame(minHeight: SkyfigTokens.Metrics.Button.height)
            .padding(.horizontal, SkyfigTokens.Metrics.Button.horizontalInset)
            .background(colors.secondaryButton, in: Capsule())
            .foregroundStyle(colors.primaryText)
        Button("Delete", role: .destructive) {}
            .frame(minHeight: SkyfigTokens.Metrics.Button.height)
            .padding(.horizontal, SkyfigTokens.Metrics.Button.horizontalInset)
            .background(colors.destructiveButton, in: Capsule())
            .foregroundStyle(colors.onDestructive)
    }

    private var searchAndSelection: some View {
        ShowcaseCard(title: "Search and segmented control") {
            VStack(spacing: SkyfigTokens.Spacing.md) {
                HStack(spacing: SkyfigTokens.Spacing.sm) {
                    SkyfigTokens.Symbols.Component.search.view.foregroundStyle(colors.secondaryText)
                    TextField("Search tasks", text: $searchText)
                        .accessibilityLabel("Search tasks")
                }
                .padding(.horizontal, SkyfigTokens.Metrics.List.rowInset)
                .frame(minHeight: SkyfigTokens.Metrics.Search.height)
                .background(colors.searchBackground, in: RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
                .overlay(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control).stroke(colors.focus, lineWidth: SkyfigTokens.BorderWidths.focus))

                Picker("Schedule", selection: $selectedSegment) {
                    Text("Upcoming").tag("Upcoming")
                    Text("Done").tag("Done")
                }
                .pickerStyle(.segmented)
                .frame(minHeight: SkyfigTokens.Metrics.Segmented.height)
                .accessibilityLabel("Schedule filter")
            }
        }
    }

    private var controlStates: some View {
        ShowcaseCard(title: "Enabled, focused, and disabled") {
            Toggle("Allow reminders", isOn: $isEnabled)
                .tint(colors.action)
                .frame(minHeight: SkyfigTokens.Metrics.Control.minHitTarget)
            Button("Disabled action") {}
                .disabled(true)
                .frame(minHeight: SkyfigTokens.Metrics.Control.minHitTarget)
                .padding(.horizontal, SkyfigTokens.Metrics.Button.horizontalInset)
                .background(colors.primaryButton.opacity(SkyfigTokens.Opacities.disabled), in: Capsule())
                .foregroundStyle(colors.onPrimary)
        }
    }
}

private struct ContentShowcase: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedID: Int?
    private var colors: ShowcaseColors { ShowcaseColors(colorScheme: colorScheme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.xl) {
                    ShowcaseHeader(
                        title: "Content",
                        detail: "Rows, status states, and empty/error treatments share semantic roles.",
                        symbol: SkyfigTokens.Symbols.Status.success
                    )
                    ShowcaseCard(title: "Today") {
                        ForEach(1...3, id: \.self) { item in
                            Button {
                                selectedID = item
                            } label: {
                                HStack(spacing: SkyfigTokens.Spacing.md) {
                                    Image(
                                        systemName: item == 2
                                            ? "exclamationmark.circle.fill"
                                            : "checkmark.circle.fill"
                                    )
                                        .foregroundStyle(item == 2 ? colors.warning : colors.success)
                                    VStack(alignment: .leading) {
                                        Text(item == 2 ? "Review design handoff" : "Prepare weekly plan")
                                            .foregroundStyle(colors.primaryText)
                                        Text(item == 2 ? "Needs attention" : "Complete")
                                            .font(SkyfigTokens.Typography.Apple.caption1.font(relativeTo: .caption))
                                            .foregroundStyle(colors.secondaryText)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundStyle(colors.secondaryText)
                                }
                                .padding(.horizontal, SkyfigTokens.Metrics.List.rowInset)
                                .frame(minHeight: SkyfigTokens.Metrics.List.rowMinHeight)
                                .background(selectedID == item ? colors.selectedRow : colors.listRow)
                                .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: SkyfigTokens.Spacing.md) { stateCards }
                        VStack(spacing: SkyfigTokens.Spacing.md) { stateCards }
                    }
                }
                .frame(maxWidth: SkyfigTokens.Metrics.Layout.readableWidth)
                .padding(SkyfigTokens.Spacing.lg)
            }
            .background(colors.grouped.ignoresSafeArea())
            .navigationTitle("Content")
        }
    }

    @ViewBuilder private var stateCards: some View {
        stateCard("No saved filters", symbol: "tray", color: colors.secondaryText)
        stateCard("Sync failed", symbol: "exclamationmark.triangle.fill", color: colors.danger)
    }

    private func stateCard(_ title: String, symbol: String, color: Color) -> some View {
        VStack(spacing: SkyfigTokens.Spacing.sm) {
            Image(systemName: symbol).font(.title2).foregroundStyle(color)
            Text(title).foregroundStyle(colors.primaryText)
            Text("A semantic status role explains this state without copying colors.")
                .font(SkyfigTokens.Typography.Apple.caption1.font(relativeTo: .caption))
                .multilineTextAlignment(.center).foregroundStyle(colors.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(SkyfigTokens.Spacing.md)
        .background(colors.modal, in: RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
    }
}

private struct PlanningShowcase: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var panelVisible = true
    private var colors: ShowcaseColors { ShowcaseColors(colorScheme: colorScheme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.xl) {
                    ShowcaseHeader(
                        title: "Planning",
                        detail: "A readable detail column and optional iPad panel adapt without device breakpoints.",
                        symbol: SkyfigTokens.Symbols.Navigation.planning
                    )
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: SkyfigTokens.Metrics.Control.unbezeledGap) {
                            planningColumn
                            detailPanel
                        }
                        VStack(spacing: SkyfigTokens.Spacing.lg) {
                            planningColumn
                            detailPanel
                        }
                    }
                    .animation(panelVisible ? SkyfigTokens.Motion.Selection.standard.animation : nil, value: panelVisible)
                }
                .frame(maxWidth: SkyfigTokens.Metrics.Layout.readableWidth)
                .padding(SkyfigTokens.Spacing.lg)
            }
            .background(colors.grouped.ignoresSafeArea())
            .navigationTitle("Planning")
        }
    }

    private var planningColumn: some View {
        ShowcaseCard(title: "Sprint plan") {
            Label("Design review", systemImage: "person.2.fill").foregroundStyle(colors.primaryText)
            Text("Wednesday • 10:00 AM").foregroundStyle(colors.secondaryText)
            Button(panelVisible ? "Hide detail" : "Show detail") { panelVisible.toggle() }
                .frame(minHeight: SkyfigTokens.Metrics.Control.minHitTarget)
                .foregroundStyle(colors.action)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var detailPanel: some View {
        if panelVisible {
            VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.md) {
                Text("Detail panel").foregroundStyle(colors.primaryText)
                Text("This material-backed surface is constrained by content width, not a fixed device size.")
                    .foregroundStyle(colors.secondaryText)
            }
            .frame(maxWidth: SkyfigTokens.Metrics.Ipad.panelWidth, alignment: .leading)
            .padding(SkyfigTokens.Spacing.lg)
            .background(SkyfigTokens.Materials.Overlay.panel.material, in: RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
            .shadow(color: Color.black.opacity(SkyfigTokens.Opacities.overlay), radius: 12, y: 6)
        }
    }
}

private struct AccessibilityMotionShowcase: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var selected = false
    private var colors: ShowcaseColors { ShowcaseColors(colorScheme: colorScheme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.xl) {
                    ShowcaseHeader(
                        title: "Accessibility",
                        detail: "Dynamic Type, contrast roles, touch targets, and reduce-motion behavior are part of the component contract.",
                        symbol: SkyfigTokens.Symbols.Accessibility.text
                    )
                    ShowcaseCard(title: "Touch target and focus") {
                        Button {
                            selected.toggle()
                        } label: {
                            HStack {
                                SkyfigTokens.Symbols.Accessibility.motion.view
                                Text(selected ? "Motion preview selected" : "Select motion preview")
                            }
                            .frame(
                                minWidth: SkyfigTokens.Metrics.Control.minHitTarget,
                                minHeight: SkyfigTokens.Metrics.Control.minHitTarget
                            )
                            .padding(.horizontal, SkyfigTokens.Metrics.Control.bezelGap)
                        }
                        .foregroundStyle(colors.primaryText)
                        .background(
                            selected ? colors.selectedRow : colors.control,
                            in: RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control)
                                .stroke(colors.focus, lineWidth: SkyfigTokens.BorderWidths.focus)
                        )
                        .animation(
                            reduceMotion ? nil : SkyfigTokens.Motion.Feedback.standard.animation,
                            value: selected
                        )
                        Text(
                            reduceMotion
                                ? "Reduce Motion is active: the state updates without animation."
                                : "The selected state uses the generated motion token."
                        )
                            .font(SkyfigTokens.Typography.Apple.callout.font(relativeTo: .callout))
                            .foregroundStyle(colors.secondaryText)
                    }
                    ShowcaseCard(title: "Readable at larger text sizes") {
                        Text("This card uses scalable SwiftUI text styles and grows vertically instead of truncating.")
                            .font(SkyfigTokens.Typography.Apple.body.font(relativeTo: .body))
                            .foregroundStyle(colors.primaryText)
                        Text("Contrast-oriented foreground, action, status, and focus roles remain semantic rather than literal.")
                            .foregroundStyle(colors.secondaryText)
                    }
                }
                .frame(maxWidth: SkyfigTokens.Metrics.Layout.readableWidth)
                .padding(SkyfigTokens.Spacing.lg)
            }
            .background(colors.grouped.ignoresSafeArea())
            .navigationTitle("Accessibility")
        }
    }
}

private struct ShowcaseHeader: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let detail: String
    let symbol: SkyfigSymbolToken

    var body: some View {
        let colors = ShowcaseColors(colorScheme: colorScheme)
        HStack(alignment: .top, spacing: SkyfigTokens.Spacing.md) {
            symbol.view.foregroundStyle(colors.action)
            VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.xs) {
                Text(title)
                    .font(SkyfigTokens.Typography.Apple.title2.font(relativeTo: .title2))
                    .foregroundStyle(colors.primaryText)
                    .accessibilityIdentifier("Showcase.\(title)")
                Text(detail).font(SkyfigTokens.Typography.Apple.body.font(relativeTo: .body)).foregroundStyle(colors.secondaryText)
            }
        }
        .padding(SkyfigTokens.Spacing.lg)
        .background(SkyfigTokens.Materials.Content.thin.material, in: RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
    }
}

private struct ShowcaseCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        let colors = ShowcaseColors(colorScheme: colorScheme)
        VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.md) {
            Text(title).font(SkyfigTokens.Typography.Apple.headline.font(relativeTo: .headline)).foregroundStyle(colors.primaryText)
            content
        }
        .padding(SkyfigTokens.Spacing.lg)
        .background(colors.elevated, in: RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
    }
}

private struct ShowcaseColors {
    let colorScheme: ColorScheme
    var primaryText: Color { SkyfigTokens.Colors.Text.primary.color(for: colorScheme) }
    var secondaryText: Color { SkyfigTokens.Colors.Text.secondary.color(for: colorScheme) }
    var grouped: Color { SkyfigTokens.Colors.Surface.grouped.color(for: colorScheme) }
    var elevated: Color { SkyfigTokens.Colors.Surface.elevated.color(for: colorScheme) }
    var modal: Color { SkyfigTokens.Colors.Surface.modal.color(for: colorScheme) }
    var action: Color { SkyfigTokens.Colors.Action.primary.color(for: colorScheme) }
    var onPrimary: Color { SkyfigTokens.Colors.Action.onPrimary.color(for: colorScheme) }
    var onDestructive: Color { SkyfigTokens.Colors.Action.onDestructive.color(for: colorScheme) }
    var primaryButton: Color { SkyfigTokens.Colors.Component.Button.primaryBackground.color(for: colorScheme) }
    var secondaryButton: Color { SkyfigTokens.Colors.Component.Button.secondaryBackground.color(for: colorScheme) }
    var destructiveButton: Color { SkyfigTokens.Colors.Component.Button.destructiveBackground.color(for: colorScheme) }
    var searchBackground: Color { SkyfigTokens.Colors.Component.Search.background.color(for: colorScheme) }
    var control: Color { SkyfigTokens.Colors.Fill.control.color(for: colorScheme) }
    var listRow: Color { SkyfigTokens.Colors.Component.ListRow.background.color(for: colorScheme) }
    var selectedRow: Color { SkyfigTokens.Colors.Component.ListRow.selectedBackground.color(for: colorScheme) }
    var success: Color { SkyfigTokens.Colors.Status.success.color(for: colorScheme) }
    var warning: Color { SkyfigTokens.Colors.Status.warning.color(for: colorScheme) }
    var danger: Color { SkyfigTokens.Colors.Status.danger.color(for: colorScheme) }
    var focus: Color { SkyfigTokens.Colors.Focus.ring.color(for: colorScheme) }
}
