#if canImport(SwiftUI)
import SwiftUI
import Skyfig

@main
struct SkyfigShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            ShowcaseView()
        }
    }
}

private struct ShowcaseView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let shadow = SkyfigTokens.Shadows.card.layers[0]

        VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.lg) {
                VStack(alignment: .leading, spacing: SkyfigTokens.Spacing.sm) {
                    Text("Skyfig")
                        .font(SkyfigTokens.Typography.headline.font)
                        .tracking(SkyfigTokens.Typography.headline.letterSpacing)
                    Text("Figma variables, reviewed in Git, typed for SwiftUI.")
                        .font(SkyfigTokens.Typography.body.font)
                        .foregroundStyle(SkyfigTokens.Colors.Text.secondary.color(for: colorScheme))
                }

                HStack(spacing: SkyfigTokens.Spacing.sm) {
                    swatch("Accent", token: SkyfigTokens.Colors.accent)
                    swatch("Surface", token: SkyfigTokens.Colors.Surface.secondary)
                }
            }
            .padding(SkyfigTokens.Spacing.xl)
            .background(SkyfigTokens.Colors.Surface.primary.color(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
            .overlay {
                RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card)
                    .stroke(
                        SkyfigTokens.Colors.accent.color(for: colorScheme).opacity(0.35),
                        lineWidth: SkyfigTokens.BorderWidths.thin
                    )
            }
            .shadow(
                color: shadow.color.color(for: colorScheme),
                radius: shadow.blur,
                x: shadow.x,
                y: shadow.y
            )
        }
        .padding(SkyfigTokens.Spacing.xl)
        .foregroundStyle(SkyfigTokens.Colors.Text.primary.color(for: colorScheme))
        .background(SkyfigTokens.Colors.Surface.secondary.color(for: colorScheme))
        .frame(minWidth: 520, minHeight: 300)
    }

    private func swatch(_ title: String, token: SkyfigColorToken) -> some View {
        Text(title)
            .font(SkyfigTokens.Typography.body.font)
            .padding(.horizontal, SkyfigTokens.Spacing.md)
            .padding(.vertical, SkyfigTokens.Spacing.sm)
            .background(token.color(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.control))
    }
}
#else
@main
enum SkyfigShowcaseApp {
    static func main() {
        print("SkyfigShowcase requires SwiftUI.")
    }
}
#endif
