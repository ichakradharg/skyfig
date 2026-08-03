# Skyfig architecture

Skyfig is a central publisher for typed SwiftUI design tokens. The architecture deliberately separates credentialed design import from the package that application developers use.

```text
Figma Variables (publisher-only credentials)
                |
                v
GitHub Actions sync workflow
                |
                v
Canonical JSON (reviewed source of truth)
                |
       validate + generate
                |
                v
Typed Swift API (SkyfigTokens or team namespace)
                |
        reviewed package release
                |
                v
iOS, iPadOS, macOS, and tvOS apps
```

## Responsibilities and trust boundaries

| Boundary | What belongs there | What must not cross it |
| --- | --- | --- |
| Figma sync workflow | Figma access token, file key, raw API response | Credentials or raw responses in source control and package code |
| Canonical JSON | Validated, reviewable token values | App-specific UI behavior or source IDs |
| Generator | Deterministic conversion from JSON to Swift | Hand-edited generated output |
| Skyfig package | Public, typed token API and runtime helpers | Network access or Figma authentication at app runtime |
| Consumer apps | UI composition and explicit package-version adoption | Figma secrets or token-generation workflows |

The canonical document carries both the established semantic families and a structure-driven primitive collection. This additive boundary lets existing consumers keep their semantic APIs while a forked team generates typed APIs from its own Figma hierarchy without a mapping layer.

## Change lifecycle

1. A maintainer syncs Figma or updates the committed fixture-backed canonical JSON.
2. Skyfig validates the document and generates the corresponding Swift API.
3. A pull request reviews canonical JSON and generated Swift together; CI verifies freshness, documentation, and consumer UI coverage. Rendered consumer changes receive separate dedicated-Mac visual-baseline review.
4. A reviewed release publishes one tested package version.
5. Each application updates that version in its own pull request and verifies the visual change before adoption.

This model makes a token update explicit and reversible for each app team. It also means a missing Figma credential does not block local validation, generation, package builds, documentation, or consumer testing.

## Where to start

- App developers should begin with the [consumer quick start](../README.md#ios-consumer-quick-start) and use the generated namespace configured by their publisher. The default is `SkyfigTokens`; team-owned forks can use a name such as `TeamATokens`.
- Package maintainers should read the [codebase guide](CODEBASE_GUIDE.md), then the [troubleshooting guide](TROUBLESHOOTING.md).
- Design-token maintainers should follow [Figma token-source options](../FIGMA_TOKEN_SOURCE_OPTIONS.md) and the protected sync-pull-request workflow.
- Consumer visual reviewers should follow the [dedicated-Mac baseline guide](VISUAL_REGRESSION.md).
