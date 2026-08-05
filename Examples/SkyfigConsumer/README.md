# Skyfig consumer sample

This is a small iOS 26+ SwiftUI app that consumes the `Skyfig` library through a separate iOS app project. It demonstrates the generated `SkyfigTokens` API in a five-tab navigation interface, including the dedicated search tab, an app-bar add button, a design-system preview screen, and token-driven content in every tab. The adaptive tab style keeps the familiar tab bar on iPhone and uses iPad's floating tab bar/sidebar presentation. The tabs collectively showcase all 11 standard Apple text styles using generated tokens and their matching SwiftUI Dynamic Type roles. The Home tab also shows the single-layer, ordered multi-layer, and inner-shadow structures exercised by the Figma fixtures.

## Run it

1. Open `Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj` in Xcode.
2. Select an iOS 26 iPhone or iPad simulator and run the `SkyfigConsumer` scheme.
3. Confirm that the app fills the display, including the area around the Dynamic Island or the iPad safe area. The project generates the standard iOS launch screen, so iOS treats it as a modern, full-screen app rather than letterboxing it in legacy compatibility mode.
4. Switch the simulator between light and dark appearance to see generated color tokens resolve automatically.
5. On iPad, rotate once to confirm that the adaptive tab layout continues to use the generated token values in every supported orientation.
6. Increase **Larger Text** through the accessibility sizes and confirm that each typography card expands vertically without clipping or horizontal truncation.

The sample temporarily uses a local package dependency so this repository can test the consumer boundary before Skyfig has a released version. After the first release, replace that dependency with the public GitHub package URL and version requirement used by your app.

## Automated UI checks

The `SkyfigConsumerUITests` target confirms that all five tabs are available, each presents its expected token-driven content, every Apple text style and inferred shadow structure is reachable, and the Home screen remains usable at an accessibility text size. Run these tests from Xcode by selecting the `SkyfigConsumer` scheme, choosing an iPhone or iPad simulator, and selecting **Product > Test** (Command-U).

From the repository root, the same tests can be run with:

```bash
Scripts/test-consumer-ui.sh          # iPhone and iPad
Scripts/test-consumer-ui.sh iphone   # iPhone only
Scripts/test-consumer-ui.sh ipad     # iPad only
```

The command uses the newest installed simulator runtime by default. Override a simulator name or runtime when your local Xcode setup differs:

```bash
SKYFIG_IPHONE_SIMULATOR="iPhone 17 Pro" SKYFIG_SIMULATOR_OS=26.0.1 \
  Scripts/test-consumer-ui.sh iphone
```

## Visual screenshot baselines

The UI tests prove navigation and expected content; they do not compare rendered pixels. The dedicated-Mac visual workflow records and verifies deterministic iPhone and iPad screenshots in light appearance. Follow the [consumer visual-regression guide](../../Docs/VISUAL_REGRESSION.md) to prepare the `skyfig-visual` runner, record reviewed baselines, and verify intended changes. Dark-mode screenshot review is intentionally deferred and remains a required manual accessibility and release-review step.

## What it proves

- A separate package can import the public `Skyfig` library product.
- A SwiftUI app can use generated semantic actions, status, text, and surface colors alongside typography, spacing, corner radii, borders, and elevation shadows across a full tab interface.
- Apple HIG typography tokens scale through SwiftUI from standard Dynamic Type sizes into accessibility sizes without selecting separate fixed-size tokens.
- The generated API remains the sole visual-value source; the sample has no copied token values.
