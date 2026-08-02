# ``Skyfig``

@Metadata {
    @DisplayName("Skyfig")
    @TechnologyRoot
}

Reviewed, typed SwiftUI design tokens for iOS, macOS, and tvOS apps.

## Overview

Skyfig is a Swift package that lets app teams use a stable, versioned design-token API. The package has no Figma credential, network request, or generation step at app runtime. Import ``Skyfig`` and use the generated ``SkyfigTokens`` values in SwiftUI views.

Skyfig's maintainer workflow is deliberately separate: a protected central repository imports Figma Variables, validates the canonical token document, generates Swift, and releases a reviewed package version. App repositories update to that version when they are ready to adopt the visual change.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:TokenUpdates>
- <doc:ConsumerSample>

### Generated tokens

- ``SkyfigTokens``

### Runtime values

- ``SkyfigRGBAColor``
- ``SkyfigColorToken``
- ``SkyfigTypographyToken``
- ``SkyfigShadowToken``

### SwiftUI support

Skyfig provides SwiftUI conversion helpers for colors, typography, and shadow values when SwiftUI is available.
