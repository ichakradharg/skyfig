# Explore the iOS consumer sample

Skyfig includes a small iOS 26+ app that consumes the package across a real application boundary. It is an integration sample, not part of the Skyfig library target.

## Open the sample

Open `Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj` in Xcode. Select an iOS 26 iPhone or iPad simulator, then run the `SkyfigConsumer` scheme.

The project generates the standard iOS launch screen. This is required for modern iPhone presentation: it lets the app fill the available display rather than appearing letterboxed in legacy compatibility mode. Verify that the sample extends through the safe-area background on the selected simulator.

The sample uses a local Swift package reference while Skyfig is unreleased. That lets the repository's CI prove the app can import the public `Skyfig` library before an app team adopts a tagged package version. Replace the local reference with the released GitHub package requirement when publishing the sample externally.

## What to look for

The sample has five tabs: Home, Library, Activity, Profile, and Search. The Search tab uses SwiftUI's dedicated search role, allowing iOS to provide its native tab-bar treatment. The adaptive tab style keeps the familiar tab bar on iPhone and uses iPad's floating tab bar/sidebar presentation. Every tab uses generated colors, typography, spacing, corner radii, borders, and elevation shadows from ``SkyfigTokens``.

The five screens collectively showcase all 11 standard Apple text styles: Large Title, Title 1–3, Headline, Body, Callout, Subheadline, Footnote, Caption 1, and Caption 2. Each generated token is applied with the corresponding SwiftUI text style, so the preview responds to all standard and accessibility Dynamic Type sizes without fixed-height text containers. The Home screen also renders single-layer and ordered multi-layer drop shadows plus an inner shadow, matching the structures covered by the Figma fixtures.

The app bar on the Home tab includes a token-styled add button. Its content uses flexible stacks and widths so the same screen adapts to iPhone and iPad without a separate tablet token set. The iPad target supports portrait and landscape orientations; rotate the simulator to verify the adaptive layout.

## Continuous integration

The iOS consumer job runs when package runtime, generated-token, or consumer-sample files change. It builds the public package boundary and runs `SkyfigConsumerUITests` against named iPhone and iPad simulators. The tests confirm all five tabs exist, all 11 Apple text styles and three inferred shadow structures are reachable, and the Home screen remains usable at an accessibility text size. Documentation-only changes do not start an iOS job.

To run the tests in Xcode, select the **SkyfigConsumer** scheme and an iPhone or iPad simulator, then choose **Product > Test**. From the repository root, `Scripts/test-consumer-ui.sh` runs both devices; pass `iphone` or `ipad` to run only one.

Pixel-stable screenshot comparison is separate from UI tests and runs only on the dedicated `skyfig-visual` Mac runner. The repository’s `Docs/VISUAL_REGRESSION.md` guide covers baseline setup; a team-owned fork should configure and operate its own runner. The initial screenshot set is light-only; dark-mode visual review remains separate.
