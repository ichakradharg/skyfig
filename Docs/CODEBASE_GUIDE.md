# Skyfig codebase guide

Skyfig is a central publisher for typed SwiftUI design tokens. This guide explains where each responsibility lives and how a token change reaches an iOS app.

## Repository map

| Location | Responsibility |
| --- | --- |
| `Schema/` | The versioned canonical JSON contract for token data. |
| `Tokens/` | Reviewed canonical token input used for generation. |
| `Sources/Skyfig/Generated/` | Generator-owned, typed Swift token API. Never edit this output by hand. |
| `Sources/Skyfig/Runtime/` | Stable token value types and SwiftUI conversion helpers. |
| `Sources/SkyfigGenerator/` | Canonical validation, Figma normalization, JSON I/O, and Swift generation. |
| `Sources/SkyfigCLI/` | The `skyfig` command-line interface. |
| `Examples/SkyfigShowcase/` | A macOS SwiftUI app that demonstrates generated tokens. |
| `Examples/SkyfigConsumer/` | An iOS 26+ iPhone and iPad consumer app that imports Skyfig through a local package reference. |
| `Tests/` | Unit, importer, schema, and pipeline coverage. |
| `.github/workflows/` | CI, Figma synchronization, and manually approved releases. |

## Token flow

1. Figma Variables are fetched only by the Skyfig repository workflow.
2. `FigmaImporter` converts the API response into `Tokens/skyfig.tokens.json`.
3. `TokenIO` validates the canonical document.
4. `SwiftEmitter` produces `Sources/Skyfig/Generated/Tokens.generated.swift`.
5. CI verifies that the committed generated source is current.
6. A reviewed release publishes a versioned Swift package for iOS consumers.

## Public API guide

- `SkyfigTokens` is generated and is the entry point used by application code.
- `SkyfigColorToken`, `SkyfigTypographyToken`, and `SkyfigShadowToken` are runtime values used by generated source.
- SwiftUI extensions convert runtime values to `Color`, `Font`, line spacing, and font weights when SwiftUI is available.
- `SkyfigGenerator` contains the programmatic document, validation, import, and generation APIs for tooling.

## Contribution boundaries

Do not add Figma credentials, raw API responses, or file identifiers to source control. Do not edit generated Swift manually. A change to canonical JSON should be paired with regenerated Swift, tests when behavior changes, and an explanation of consumer impact in the pull request.
