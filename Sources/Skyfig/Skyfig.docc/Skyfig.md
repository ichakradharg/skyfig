# ``Skyfig``

@Metadata {
    @DisplayName("Skyfig")
}

Reviewed, typed SwiftUI design tokens for iOS, macOS, and tvOS apps.

## Overview

Skyfig is a Swift package that lets app teams use a stable, versioned design-token API. The package has no Figma credential, network request, or generation step at app runtime. Import ``Skyfig`` and use the generated ``SkyfigTokens`` values in SwiftUI views. A team-owned publisher fork can expose the same API under its own configured namespace, such as `TeamATokens`.

Skyfig's publisher workflow is deliberately separate: a protected repository imports Figma Variables, validates the canonical token document, generates Swift, and releases a reviewed package version. A team can own that publisher through a fork, while app repositories update to its version when they are ready to adopt the visual change.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Architecture>
- <doc:ForkAndOwn>
- <doc:FigmaChangeRelease>
- <doc:TokenUpdates>
- <doc:TokenGovernance>
- <doc:Accessibility>
- <doc:ConsumerSample>
- <doc:Troubleshooting>

### Generated tokens

- ``SkyfigTokens``

### Runtime values

- ``SkyfigRGBAColor``
- ``SkyfigColorToken``
- ``SkyfigTypographyToken``
- ``SkyfigShadowToken``

### SwiftUI support

Skyfig provides SwiftUI conversion helpers for colors, typography, and shadow values when SwiftUI is available.
