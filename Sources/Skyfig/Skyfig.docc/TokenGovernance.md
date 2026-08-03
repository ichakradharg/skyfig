# Token governance

Use semantic token names in app code so design changes can be published without coupling apps to palette implementation details.

## Prefer intent over literals

Use tokens such as ``SkyfigTokens/Colors/Text/primary`` and ``SkyfigTokens/Colors/Surface/primary`` to describe the role a value has in the interface. Do not copy RGBA values into an app. New application-facing tokens should describe intent, such as `action.primary` or `status.warning`, rather than a color name.

## Accessibility

Skyfig verifies the current semantic text and surface pairs against the WCAG AA 4.5:1 contrast target for normal text in light and dark appearance. You can inspect a pair in tooling with ``SkyfigRGBAColor/contrastRatio(against:)``.

Apps remain responsible for checking contrast where a token is layered over imagery, gradients, or translucent material, and for verifying their screens at larger Dynamic Type sizes.

## Public API changes

Generated token names, types, and meanings are public API. Additive tokens are normally minor releases. Renames, removals, and incompatible type or meaning changes require a documented migration and a major release when removed. Read <doc:TokenUpdates> for the consumer-adoption flow.
