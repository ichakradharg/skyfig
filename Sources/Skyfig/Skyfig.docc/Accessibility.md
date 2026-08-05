# Accessibility

Skyfig validates baseline contrast for its semantic tokens and provides Dynamic Type-aware typography helpers. Consumer apps must still test their composed screens.

## Dynamic Type

Use ``SkyfigTypographyToken/font(relativeTo:)`` for application text. It scales with the user's selected text size.

```swift
Text("Settings")
    .font(SkyfigTokens.Typography.headline.font(relativeTo: .title))
```

Avoid fixed-height text containers and verify important flows at accessibility text sizes.

The generated `Typography.Apple` fixture covers the 11 standard iOS and iPadOS text styles using Apple's default Large metrics. Match Large Title, Title 1–3, Headline, Body, Callout, Subheadline, Footnote, Caption 1, and Caption 2 to their corresponding SwiftUI text styles. SwiftUI then scales them across the seven standard Dynamic Type sizes and five accessibility sizes.

## Contrast and focus

``SkyfigRGBAColor/contrastRatio(against:)`` reports the WCAG ratio for two opaque colors. Skyfig checks semantic text, actions, status text, and focus-ring pairs in both supported appearances. Image, gradient, and translucent backgrounds need a screen-specific review.

Give icon-only controls labels, communicate status with more than color, keep focus visible, and respect Reduce Motion and Reduce Transparency.
