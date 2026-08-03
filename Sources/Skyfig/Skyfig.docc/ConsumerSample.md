# Explore the iOS consumer sample

Skyfig includes a small iOS 26+ app that consumes the package across a real application boundary. It is an integration sample, not part of the Skyfig library target.

## Open the sample

Open `Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj` in Xcode. Select an iOS 26 iPhone or iPad simulator, then run the `SkyfigConsumer` scheme.

The project generates the standard iOS launch screen. This is required for modern iPhone presentation: it lets the app fill the available display rather than appearing letterboxed in legacy compatibility mode. Verify that the sample extends through the safe-area background on the selected simulator.

The sample uses a local Swift package reference while Skyfig is unreleased. That lets the repository's CI prove the app can import the public `Skyfig` library before an app team adopts a tagged package version. Replace the local reference with the released GitHub package requirement when publishing the sample externally.

## What to look for

The sample has five tabs: Home, Library, Activity, Profile, and Search. The Search tab uses SwiftUI's dedicated search role, allowing iOS to provide its native tab-bar treatment. The adaptive tab style keeps the familiar tab bar on iPhone and uses iPad's floating tab bar/sidebar presentation. Every tab uses generated colors, typography, spacing, corner radii, borders, and elevation shadows from ``SkyfigTokens``.

The app bar on the Home tab includes a token-styled add button. Its content uses flexible stacks and widths so the same screen adapts to iPhone and iPad without a separate tablet token set. The iPad target supports portrait and landscape orientations; rotate the simulator to verify the adaptive layout.

## Continuous integration

The iOS consumer build runs when package runtime, generated-token, or consumer-sample files change. It verifies that the public package dependency and SwiftUI API compile for iOS 26 without starting a simulator.

The `SkyfigConsumerUITests` target confirms all five tabs exist and that each tab presents its expected token-driven content. Run it locally from Xcode or on a dedicated macOS CI runner. GitHub-hosted CI intentionally limits itself to the reliable iOS compile check; hosted simulator test runners can stall before a test starts. Documentation-only changes do not start an iOS build.

To run the tests in Xcode, select the **SkyfigConsumer** scheme and an iPhone or iPad simulator, then choose **Product > Test**. From the repository root, `Scripts/test-consumer-ui.sh` runs both devices; pass `iphone` or `ipad` to run only one.
