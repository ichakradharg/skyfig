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

    var body: some View {
        GeometryReader { _ in
            TabView {
                Tab("Home", systemImage: "house") {
                    HomePreview()
                }

                Tab("Library", systemImage: "square.grid.2x2") {
                    TabPlaceholder(
                        title: "Library",
                        symbol: "books.vertical",
                        message: "A package consumer can reuse the same generated tokens across every tab.",
                        typographySamples: AppleTypographyCatalog.library
                    )
                }

                Tab("Activity", systemImage: "bell") {
                    TabPlaceholder(
                        title: "Activity",
                        symbol: "bell.badge",
                        message: "Notifications, badges, and surfaces inherit the same design-system values.",
                        typographySamples: AppleTypographyCatalog.activity
                    )
                }

                Tab("Profile", systemImage: "person.crop.circle") {
                    TabPlaceholder(
                        title: "Profile",
                        symbol: "person.crop.circle",
                        message: "The profile experience uses the same public token API as the rest of the app.",
                        typographySamples: AppleTypographyCatalog.profile
                    )
                }

                Tab("Search", systemImage: "magnifyingglass", role: .search) {
                    TabPlaceholder(
                        title: "Search",
                        symbol: "magnifyingglass",
                        message: "The fifth tab uses the dedicated iOS search role and its floating presentation.",
                        typographySamples: AppleTypographyCatalog.search
                    )
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SkyfigTokens.Colors.Surface.secondary.color(for: colorScheme))
        }
        .tint(SkyfigTokens.Colors.Action.primary.color(for: colorScheme))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SkyfigTokens.Colors.Surface.secondary.color(for: colorScheme))
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
