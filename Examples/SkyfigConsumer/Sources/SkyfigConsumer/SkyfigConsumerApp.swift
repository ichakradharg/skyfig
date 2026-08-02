import SwiftUI
import Skyfig

@main
struct SkyfigConsumerApp: App {
    var body: some Scene {
        WindowGroup {
            ConsumerTabShell()
        }
    }
}

private struct ConsumerTabShell: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomePreview()
            }

            Tab("Library", systemImage: "square.grid.2x2.fill") {
                TabPlaceholder(
                    title: "Library",
                    symbol: "books.vertical.fill",
                    message: "A package consumer can reuse the same generated tokens across every tab."
                )
            }

            Tab("Activity", systemImage: "bell.fill") {
                TabPlaceholder(
                    title: "Activity",
                    symbol: "bell.badge.fill",
                    message: "Notifications, badges, and surfaces inherit the same design-system values."
                )
            }

            Tab("Profile", systemImage: "person.crop.circle.fill") {
                TabPlaceholder(
                    title: "Profile",
                    symbol: "person.crop.circle.fill",
                    message: "The profile experience uses the same public token API as the rest of the app."
                )
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                TabPlaceholder(
                    title: "Search",
                    symbol: "magnifyingglass",
                    message: "The fifth tab uses the dedicated iOS search role and its floating presentation."
                )
            }
        }
        .tint(SkyfigTokens.Colors.accent.color(for: colorScheme))
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

    private var accent: Color {
        SkyfigTokens.Colors.accent.color(for: colorScheme)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.xl) {
                    heroCard
                    typeScale
                    elevationAndCorners
                    tokenStrip
                }
                .padding(SkyfigTokens.Spacing.lg)
            }
            .background(secondarySurface)
            .navigationTitle("Skyfig")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundStyle(accent)
                        .accessibilityLabel("Skyfig home")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: SkyfigTokens.Spacing.md) {
                        Button("Preview") {}
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(accent)

                        Button(action: {}) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .frame(width: 28, height: 28)
                                .background(accent, in: Circle())
                                .foregroundStyle(surface)
                        }
                        .accessibilityLabel("Add item")
                    }
                }
                #else
                ToolbarItem {
                    Image(systemName: "square.grid.2x2.fill")
                        .foregroundStyle(accent)
                        .accessibilityLabel("Skyfig home")
                }
                ToolbarItem {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 28, height: 28)
                            .background(accent, in: Circle())
                            .foregroundStyle(surface)
                    }
                    .accessibilityLabel("Add item")
                }
                #endif
            }
        }
        .tint(accent)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.md) {
            Label("Design system preview", systemImage: "paintpalette.fill")
                .font(SkyfigTokens.Typography.body.font)
                .foregroundStyle(accent)

            Text("Typed tokens, ready for your app.")
                .font(SkyfigTokens.Typography.headline.font)
                .tracking(SkyfigTokens.Typography.headline.letterSpacing)
                .lineSpacing(SkyfigTokens.Typography.headline.lineSpacing)
                .foregroundStyle(primaryText)

            Text("This app imports Skyfig as a package and uses its generated SwiftUI tokens for every visual value on this screen.")
                .font(SkyfigTokens.Typography.body.font)
                .lineSpacing(SkyfigTokens.Typography.body.lineSpacing)
                .foregroundStyle(secondaryText)

            Button("Explore tokens") {}
                .buttonStyle(.borderedProminent)
                .tint(accent)
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
                .font(SkyfigTokens.Typography.body.font)
                .foregroundStyle(secondaryText)

            Text("Headline token")
                .font(SkyfigTokens.Typography.headline.font)
                .foregroundStyle(primaryText)

            Text("Body token with generated line-height support.")
                .font(SkyfigTokens.Typography.body.font)
                .lineSpacing(SkyfigTokens.Typography.body.lineSpacing)
                .foregroundStyle(secondaryText)
        }
        .padding(SkyfigTokens.Spacing.lg)
        .background(surface)
        .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
    }

    private var tokenStrip: some View {
        HStack(spacing: SkyfigTokens.Spacing.sm) {
            tokenSwatch("Accent", accent)
            tokenSwatch("Surface", surface)
            tokenSwatch("Text", primaryText)
        }
    }

    private var elevationAndCorners: some View {
        HStack(spacing: SkyfigTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) {
                Image(systemName: "square.on.square")
                    .foregroundStyle(accent)
                Text("Elevation")
                    .font(SkyfigTokens.Typography.body.font)
                    .foregroundStyle(primaryText)
                Text("Card shadow token")
                    .font(.caption)
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
                Image(systemName: "roundedcorner")
                    .foregroundStyle(accent)
                Text("Corners")
                    .font(SkyfigTokens.Typography.body.font)
                    .foregroundStyle(primaryText)
                Text("Card and control radii")
                    .font(.caption)
                    .foregroundStyle(secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SkyfigTokens.Spacing.md)
            .background(surface)
            .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
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
                .font(.caption)
                .foregroundStyle(secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TabPlaceholder: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let symbol: String
    let message: String

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
                        .font(SkyfigTokens.Typography.headline.font)
                        .foregroundStyle(text)

                    VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) {
                        Text("Token-powered \(title.lowercased())")
                            .font(SkyfigTokens.Typography.body.font)
                            .foregroundStyle(SkyfigTokens.Colors.accent.color(for: colorScheme))
                        Text(message)
                            .font(SkyfigTokens.Typography.body.font)
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
            .background(background)
            .navigationTitle(title)
        }
    }

    private func tokenRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(SkyfigTokens.Typography.body.font)
                .foregroundStyle(text)
            Spacer()
            Text(value)
                .font(SkyfigTokens.Typography.body.font)
                .foregroundStyle(secondaryText)
        }
        .padding(SkyfigTokens.Spacing.md)
    }
}
