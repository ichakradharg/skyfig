import Skyfig

let color = SkyfigTokens.Colors.accent.light
let spacing = SkyfigTokens.Spacing.md
let typography = SkyfigTokens.Typography.headline
let shadow = SkyfigTokens.Shadows.card

precondition(color.alpha > 0)
precondition(spacing > 0)
precondition(typography.fontSize > 0)
precondition(!shadow.layers.isEmpty)
