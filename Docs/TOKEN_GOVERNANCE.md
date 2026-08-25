# Token governance

Skyfig publishes a stable, semantic API for application developers. Token values can evolve; their meaning and public names must remain deliberate.

## Use semantic tokens in apps

Consumer code should express intent, not a literal design choice. Prefer `SkyfigTokens.Colors.Text.primary` and `SkyfigTokens.Colors.Surface.primary` over copying a color value or using an implementation-oriented name. In a team-owned fork, substitute the configured namespace, such as `TeamATokens`. The current fixture also exposes `accent` as a primitive bridge token; new application-facing color tokens should be semantic.

The fixture now models the first semantic color contract: `action.primary` and `action.onPrimary`, `focus.ring`, `text.*`, `surface.*`, and `status.success`, `status.warning`, `status.danger`, and `status.info`. These are sample design decisions, ready to be replaced by approved Figma values later without changing the publishing workflow.

Use this naming model for future token families:

| Layer | Purpose | Examples |
| --- | --- | --- |
| Primitive | Raw palette or scale; maintained by the design system | `blue.600`, `gray.50` |
| Semantic | Intent that app UI should use | `text.primary`, `surface.secondary`, `action.primary`, `status.warning` |
| Component | A reusable component contract when needed | `button.primary.background`, `tabBar.selected.icon` |

Apps should normally consume semantic tokens. Component tokens are appropriate only when the component contract is intentionally shared. Primitive tokens are not a stable default for app UI.

## iOS and iPadOS interaction families

Keep interaction metrics separate from general spacing. The fixture exposes preferred and compact touch targets, bezel and unbezeled gaps, component heights/insets, readable content width, and iPad sidebar/panel widths. These are layout guidance for adaptive SwiftUI composition; do not encode safe-area insets, device dimensions, or breakpoint values as tokens.

Use `materials` only for constrained SwiftUI system materials (`ultraThin`, `thin`, `regular`, and `thick`), not approximate RGBA replacements. `symbols` describe an SF Symbol name, weight, scale, rendering mode, semantic tint role, and optional availability. `motion` carries a standard duration/curve and a reduce-motion duration so views can opt out when `accessibilityReduceMotion` is true.

Semantic colors include foreground/action contracts that Skyfig tests at 4.5:1, plus non-text focus support tested at 3:1. Component state tokens describe shared branded controls such as buttons, search, segmented controls, list rows, tabs, toolbars, and sidebars. They are additive public API: document intended use and preserve names during consumer migrations.

## Change policy

Generated names, token types, and semantic meaning are public package API.

| Change | Review and release expectation |
| --- | --- |
| Correct a token value without changing its meaning | Document the visual impact; usually patch |
| Add a semantic token | Document intended use; usually minor |
| Change a widely used semantic meaning | Treat as consumer-impacting; usually minor with migration guidance |
| Rename, remove, or change the type of a public token | Deprecate first where practical; major release when removal occurs |

Every token pull request should state affected token families, expected consumer impact, and the proposed release level. Review canonical JSON and generated Swift together; never hand-edit generated output.

## Accessibility baseline

Semantic foreground and surface tokens must meet WCAG AA's 4.5:1 contrast target for normal text in both light and dark appearance. Skyfig tests the current `text` and `surface` pairs as a baseline. Components using transparent, image, or gradient backgrounds need an explicit design review because their final contrast depends on composition.

Typography must preserve Dynamic Type behavior in consuming apps. Skyfig provides type metrics; apps should apply them with scalable SwiftUI text styles and verify their important screens at larger accessibility sizes.

## Migration approach

1. Add the new semantic token and document its intended use.
2. Update Skyfig samples and consumer guidance.
3. Give consumers an upgrade note and a release to adopt at their own pace.
4. Deprecate the old API where a compatible migration path exists.
5. Remove it only in a planned major release.
