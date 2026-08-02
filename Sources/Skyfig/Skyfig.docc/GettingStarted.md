# Getting started with Skyfig

Add Skyfig as a package dependency, import it into a SwiftUI target, and use ``SkyfigTokens`` rather than hard-coded visual values.

## Add the package

In Xcode, choose **File > Add Package Dependencies**, enter the Skyfig repository URL, and select a released version. Add the `Skyfig` library product to the application target.

In a Swift package manifest, declare the dependency and target product:

```swift
.package(url: "https://github.com/ichakradharg/skyfig.git", from: "0.1.0")
```

```swift
.product(name: "Skyfig", package: "skyfig")
```

## Use typed tokens in SwiftUI

```swift
import SwiftUI
import Skyfig

struct WelcomeCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text("Welcome")
            .font(SkyfigTokens.Typography.headline.font)
            .foregroundStyle(SkyfigTokens.Colors.Text.primary.color(for: colorScheme))
            .padding(SkyfigTokens.Spacing.md)
            .background(SkyfigTokens.Colors.Surface.primary.color(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
    }
}
```

The generated API is compile-time checked. If a token changes or is removed in a new Skyfig version, app code identifies the affected use during its normal build and test process.

## What stays out of app repositories

Figma access tokens and file keys belong only to the central Skyfig publisher repository. Consumers install a reviewed package release; they do not run the Figma sync workflow and do not need Figma access.
