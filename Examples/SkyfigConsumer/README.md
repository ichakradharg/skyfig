# Skyfig consumer sample

This is a small iOS 26+ SwiftUI app that consumes the `Skyfig` library through a separate iOS app project. It demonstrates the generated `SkyfigTokens` API in a five-tab navigation interface, including the dedicated search tab, an app-bar add button, a design-system preview screen, and token-driven content in every tab. The adaptive tab style keeps the familiar tab bar on iPhone and uses iPad's floating tab bar/sidebar presentation.

## Run it

1. Open `Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj` in Xcode.
2. Select an iOS 26 iPhone or iPad simulator and run the `SkyfigConsumer` scheme.
3. Confirm that the app fills the display, including the area around the Dynamic Island or the iPad safe area. The project generates the standard iOS launch screen, so iOS treats it as a modern, full-screen app rather than letterboxing it in legacy compatibility mode.
4. Switch the simulator between light and dark appearance to see generated color tokens resolve automatically.

The sample temporarily uses a local package dependency so this repository can test the consumer boundary before Skyfig has a released version. After the first release, replace that dependency with the public GitHub package URL and version requirement used by your app.

## What it proves

- A separate package can import the public `Skyfig` library product.
- A SwiftUI app can use generated colors, typography, spacing, corner radii, borders, and elevation shadows across a full tab interface.
- The generated API remains the sole visual-value source; the sample has no copied token values.
