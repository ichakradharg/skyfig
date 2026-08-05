# Figma variable authoring rules

Use this guide when a designer prepares a Figma Variables file for Skyfig. The outer hierarchy is team owned and can be as deep as needed. Skyfig does not require a static family map; it recognizes supported primitive types and complete typography or shadow groups at any depth.

## General naming rules

- Use non-empty slash-separated variable names, for example `retail/ios/components/profile/title/size`.
- Keep every path unique across the file. Collection names do not become part of the generated Swift path, so identical variable paths in two collections collide.
- Prefer clear lower-case words separated by spaces, hyphens, or slashes. Skyfig converts them deterministically to lower-camel Swift identifiers.
- Do not create two names that normalize to the same result, such as `brand-color` and `brand color` under the same parent.
- Numeric-leading Swift segments are prefixed with `_` automatically.
- COLOR, FLOAT, STRING, and BOOLEAN variables are always preserved as typed primitive values.

## Modes and aliases

- A single-mode collection can use any mode name; its default value is used for both supported appearances.
- A multi-mode collection must contain modes named `Light` and `Dark`, matched case-insensitively.
- Figma variable aliases can cross collections. The aliased value must exist for the requested mode.
- Do not create alias cycles. A deleted-but-referenced variable may resolve an alias but is not generated as a public token.

## Typography groups

Put exactly one variable for each required role under the same parent group. The parent can appear anywhere in the hierarchy.

| Role | Accepted leaf names | Figma type | Required value |
| --- | --- | --- | --- |
| Font family | `font-family`, `family`, `typeface` | STRING | `system` or the exact installed font family |
| Font size | `font-size`, `size` | FLOAT | Points |
| Font weight | `font-weight`, `weight` | FLOAT or STRING | 100–900 or Ultra Light, Thin, Light, Regular/Normal, Medium, Semibold, Bold, Heavy, Black |
| Line height | `line-height`, `leading` | FLOAT | Points |
| Letter spacing | `letter-spacing`, `tracking` | FLOAT | Points |

Example with a team-owned, deeply nested hierarchy:

```text
enterprise/retail/ios/components/profile/header/primary-title/typeface
enterprise/retail/ios/components/profile/header/primary-title/size
enterprise/retail/ios/components/profile/header/primary-title/weight
enterprise/retail/ios/components/profile/header/primary-title/leading
enterprise/retail/ios/components/profile/header/primary-title/tracking
```

This becomes one nested Swift typography token. The folders and `primary-title` name are preserved; Skyfig only interprets the five leaf roles. For Apple platforms, use semantic style names such as `large-title`, `body`, or `caption-1` so developers can apply the matching SwiftUI `Font.TextStyle` and retain Dynamic Type accessibility scaling.

If a group is missing a required role, uses an incompatible Figma type, or contains two aliases for the same role, Skyfig keeps the individual primitive variables but does not guess a composite. The legacy explicit `typography/...` convention remains strict and reports an incomplete group as an error.

## Shadow groups

For a single shadow layer, put the required leaves directly beneath one parent.

| Role | Accepted leaf names | Figma type | Requirement |
| --- | --- | --- | --- |
| Color | `color` | COLOR | Required |
| Horizontal offset | `x`, `offset-x`, `horizontal-offset` | FLOAT | Required, in points |
| Vertical offset | `y`, `offset-y`, `vertical-offset` | FLOAT | Required, in points |
| Blur radius | `blur`, `blur-radius` | FLOAT | Required, in points |
| Spread | `spread`, `spread-radius` | FLOAT | Optional; defaults to 0 |
| Kind | `kind`, `type` | STRING | Optional `drop` or `inner`; defaults to `drop` |

```text
components/dialog/elevation/color
components/dialog/elevation/offset-x
components/dialog/elevation/offset-y
components/dialog/elevation/blur-radius
components/dialog/elevation/spread-radius
```

For multiple layers, insert numeric layer segments immediately before each field. Layers are emitted in numeric order.

```text
components/floating-panel/elevation/0/color
components/floating-panel/elevation/0/x
components/floating-panel/elevation/0/y
components/floating-panel/elevation/0/blur
components/floating-panel/elevation/1/color
components/floating-panel/elevation/1/x
components/floating-panel/elevation/1/y
components/floating-panel/elevation/1/blur
```

Do not mix direct single-layer fields and a numeric `0` layer in the same group. If any numeric layer is incomplete or ambiguous, Skyfig leaves the group as primitives rather than publishing a partially reconstructed shadow.

## Designer handoff checklist

Before asking an engineering team to sync the file:

1. Confirm every variable has a unique slash path.
2. Confirm a multi-mode collection uses `Light` and `Dark` mode names.
3. Confirm each typography group has all five required sibling roles exactly once.
4. Confirm each shadow layer has color, x, y, and blur; add kind and spread only when needed.
5. Confirm numeric shadow layers use one consistent `0`, `1`, `2` sequence.
6. Confirm aliases resolve and do not form cycles.
7. Agree which SwiftUI text style corresponds to each semantic typography token.
8. Run a fixture or live sync and review the canonical JSON plus generated Swift pull-request diff with engineering.

When a design cannot follow these composite contracts, keep the variables: Skyfig will still generate their supported primitive values. Engineering can introduce an explicit convention later without losing source data.
