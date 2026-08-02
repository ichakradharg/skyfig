# Explore the iOS consumer sample

Skyfig includes a small iOS 26+ app that consumes the package across a real application boundary. It is an integration sample, not part of the Skyfig library target.

## Open the sample

Open `Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj` in Xcode. Select an iOS 26 iPhone or iPad simulator, then run the `SkyfigConsumer` scheme.

The sample uses a local Swift package reference while Skyfig is unreleased. That lets the repository's CI prove the app can import the public `Skyfig` library before an app team adopts a tagged package version. Replace the local reference with the released GitHub package requirement when publishing the sample externally.

## What to look for

The sample has five tabs: Home, Library, Activity, Profile, and Search. The Search tab uses SwiftUI's dedicated search role, allowing iOS to provide its native tab-bar treatment. Every tab uses generated colors, typography, spacing, corner radii, borders, and elevation shadows from ``SkyfigTokens``.

The app bar on the Home tab includes a token-styled add button. Its content uses flexible stacks and widths so the same screen adapts to iPhone and iPad without a separate tablet token set.

## Continuous integration

CI builds the `SkyfigConsumer` Xcode project against the iOS simulator SDK. This checks that the public package dependency and SwiftUI API compile for iOS 26. It is a build check, not an automated simulator interaction test.
