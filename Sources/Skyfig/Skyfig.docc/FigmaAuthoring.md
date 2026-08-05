# Figma variable authoring rules

Use these rules when preparing a Figma Variables file for Skyfig. The hierarchy above a token group is team owned and can be arbitrarily deep. Skyfig recognizes primitive types and complete typography or shadow sibling groups without a static family map.

## General rules

- Use unique, non-empty slash-separated variable paths.
- Remember that collection names are not added to generated paths; duplicate variable paths across collections collide.
- COLOR, FLOAT, STRING, and BOOLEAN variables are always retained as typed primitive values.
- Multi-mode collections must have `Light` and `Dark` modes. A single-mode collection uses its default value for both appearances.
- Aliases can cross collections, but missing targets and cycles fail the sync.
- Names that normalize to the same Swift identifier fail with both source names instead of silently overwriting one another.

## Typography contract

Place exactly one leaf for each role under the same parent:

| Role | Accepted names | Type |
| --- | --- | --- |
| Family | `font-family`, `family`, `typeface` | STRING |
| Size | `font-size`, `size` | FLOAT |
| Weight | `font-weight`, `weight` | FLOAT 100–900 or a standard weight name |
| Line height | `line-height`, `leading` | FLOAT |
| Letter spacing | `letter-spacing`, `tracking` | FLOAT |

```text
enterprise/retail/ios/components/profile/header/primary-title/typeface
enterprise/retail/ios/components/profile/header/primary-title/size
enterprise/retail/ios/components/profile/header/primary-title/weight
enterprise/retail/ios/components/profile/header/primary-title/leading
enterprise/retail/ios/components/profile/header/primary-title/tracking
```

The example generates one nested typography token even though its outer structure is unrelated to Skyfig's fixture. For Apple apps, give semantic styles recognizable names and agree on the matching SwiftUI `Font.TextStyle`; ``SkyfigTypographyToken/font(relativeTo:)`` then supplies Dynamic Type scaling through the accessibility sizes.

Incomplete, incorrectly typed, or duplicate-role groups remain individual primitives. Skyfig does not infer relationships that the source does not prove.

## Shadow contract

A single layer requires COLOR `color` plus FLOAT x, y, and blur fields. X accepts `x`, `offset-x`, or `horizontal-offset`; y accepts `y`, `offset-y`, or `vertical-offset`; blur accepts `blur` or `blur-radius`. FLOAT spread is optional and defaults to zero. STRING kind is optional, accepts `drop` or `inner`, and defaults to `drop`.

For multiple layers, insert numeric layer segments immediately before the leaves, such as `elevation/0/color` and `elevation/1/color`. Skyfig emits layers in numeric order. Do not mix direct single-layer fields and an explicit layer `0` in one group.

## Handoff checklist

1. Confirm unique slash paths and valid modes.
2. Confirm each typography group contains all five sibling roles exactly once.
3. Confirm every shadow layer contains color, x, y, and blur.
4. Confirm aliases resolve without cycles.
5. Agree on each typography token's matching SwiftUI text style.
6. Review the normalized JSON and generated Swift together in the sync pull request.

The full repository guide, `Docs/FIGMA_AUTHORING_GUIDE.md`, includes expanded alias tables, multi-layer examples, and designer-to-engineer review guidance.
