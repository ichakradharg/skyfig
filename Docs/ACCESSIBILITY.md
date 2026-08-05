# Accessibility

Skyfig provides token values and validation helpers; an app still owns the final accessible experience. Use semantic tokens and test the composed UI in the contexts where users will experience it.

## Typography and Dynamic Type

Use `font(relativeTo:)` for application text. It maps a token to a SwiftUI text style, so the font scales with a user's Dynamic Type setting.

```swift
Text("Account")
    .font(SkyfigTokens.Typography.headline.font(relativeTo: .title))

Text("Your settings are up to date.")
    .font(SkyfigTokens.Typography.body.font(relativeTo: .body))
```

Choose the text style for the role in the interface, not only the token's point size. Verify important screens at an accessibility size and avoid fixed-height text containers.

The bundled Apple fixture uses the default Large metrics from Apple's Human Interface Guidelines for Large Title, Title 1–3, Headline, Body, Callout, Subheadline, Footnote, Caption 1, and Caption 2. These values document and preview the base hierarchy; they are not a replacement for system scaling. Match each token to its SwiftUI text style so the system responds from `xSmall` through `xxxLarge` and all five accessibility sizes. Do not manually select a different token for every content-size category.

## Contrast

Skyfig tests these baseline expectations in light and dark appearance:

- `text.*` against `surface.*` is at least 4.5:1 for normal text.
- `action.onPrimary` against `action.primary` is at least 4.5:1.
- `status.*` against `surface.*` is at least 4.5:1 when used as status text.
- `focus.ring` against `surface.*` is at least 3:1 for a non-text focus indicator.

Use `SkyfigRGBAColor.contrastRatio(against:)` to check an opaque composed pair. A translucent, gradient, or image background needs a screen-specific review because the final color is context dependent.

## App checklist

- Give icon-only controls a concise accessibility label.
- Keep keyboard focus visible; use `focus.ring` rather than relying only on color changes.
- Ensure status is communicated with text or a symbol as well as color.
- Respect Reduce Motion and Reduce Transparency; do not use essential meaning only in animation or material effects.
- Use semantic control labels and traits so VoiceOver presents the intended action.
- Test at least one key flow with VoiceOver, larger Dynamic Type, light and dark appearance, and increased contrast.

## What Skyfig will not infer

The token file cannot know the final background behind a view, the order VoiceOver reads a custom component, or whether an animation conveys essential information. Treat the automated checks as a guardrail, then validate the real app.
