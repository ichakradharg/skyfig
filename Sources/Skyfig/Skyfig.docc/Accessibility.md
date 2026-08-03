# Accessibility

Skyfig validates baseline contrast for its semantic tokens and provides Dynamic Type-aware typography helpers. Consumer apps must still test their composed screens.

## Dynamic Type

Use ``SkyfigTypographyToken/font(relativeTo:)`` for application text. It scales with the user's selected text size.

```swift
Text("Settings")
    .font(SkyfigTokens.Typography.headline.font(relativeTo: .title))
```

Avoid fixed-height text containers and verify important flows at accessibility text sizes.

## Contrast and focus

``SkyfigRGBAColor/contrastRatio(against:)`` reports the WCAG ratio for two opaque colors. Skyfig checks semantic text, actions, status text, and focus-ring pairs in both supported appearances. Image, gradient, and translucent backgrounds need a screen-specific review.

Give icon-only controls labels, communicate status with more than color, keep focus visible, and respect Reduce Motion and Reduce Transparency.
