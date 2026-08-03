# Skyfig

Skyfig turns Figma Variables into reviewed, typed SwiftUI design tokens. It is a standalone Swift Package and command-line generator—there is no Figma plugin, build phase, or runtime network dependency.

The repository includes:

- a strict, source-agnostic [canonical JSON schema](Schema/skyfig.tokens.schema.json);
- light and dark colors, typography, spacing, corner radii, border widths, and layered shadows;
- deterministic Swift generation with generated code isolated in `Sources/Skyfig/Generated`;
- a Figma Variables REST API normalizer with alias resolution;
- CI, scheduled/manual Figma synchronization, and review-gated SemVer releases;
- unit tests and a runnable SwiftUI showcase.

## How it works

```text
Figma Variables API
        │
        ▼
temporary API response ── normalize ──► Tokens/skyfig.tokens.json
                                              │
                                              ▼
                                     validate + generate
                                              │
                                              ▼
                              Sources/Skyfig/Generated/
                                              │
                                              ▼
                                      automated draft PR
```

The raw Figma response exists only in the Actions runner's temporary directory. It is never committed or uploaded. The sync workflow changes the canonical JSON and generated Swift only, then opens or updates a draft pull request. It never tags or releases.

## Requirements

- Swift 6.0 or newer
- iOS 16+, macOS 13+, or tvOS 16+ for the SwiftUI library
- macOS for the included showcase

The schema, normalizer, generator, and CLI use Foundation only. SwiftUI is confined to the public runtime conveniences and showcase.

## Documentation

- [Codebase guide](Docs/CODEBASE_GUIDE.md) explains the repository structure, token flow, and public API boundaries.
- [Architecture guide](Docs/ARCHITECTURE.md) explains trust boundaries, token flow, and how apps consume releases.
- [Token governance](Docs/TOKEN_GOVERNANCE.md) explains semantic token use, accessibility expectations, and safe public-API evolution.
- [Accessibility](Docs/ACCESSIBILITY.md) explains Dynamic Type-aware token use, contrast guardrails, and app-level accessibility checks.
- [Consumer upgrade guide](Docs/CONSUMER_UPGRADES.md) explains how app teams safely adopt a new Skyfig package version.
- [Changelog](CHANGELOG.md) records consumer-facing changes and migration expectations.
- [Consumer visual regression](Docs/VISUAL_REGRESSION.md) explains dedicated-Mac runner setup, baseline recording, light-only screenshot coverage, and the deferred dark-mode review.
- [CLI reference](Docs/CLI_REFERENCE.md) documents validation, normalization, generation, and generated-source checks.
- [Rendered DocC site guide](Docs/DOCS_SITE.md) explains the hosted API reference and how to preview it locally.
- [iOS consumer sample](Examples/SkyfigConsumer/README.md) explains the iPhone and iPad integration example.
- [Package consumer smoke test](Examples/SkyfigPackageConsumer/README.md) verifies the public package boundary without an app project.
- [Troubleshooting](Docs/TROUBLESHOOTING.md) covers fixture validation, generation, live Figma sync, and consumer-update failures.
- [Figma token-source options](FIGMA_TOKEN_SOURCE_OPTIONS.md) explains fixture and live-sync workflows.
- [Versioning and releases](VERSIONING.md) and the [release checklist](RELEASING.md) describe package publication for iOS consumers.

## iOS consumer quick start

Skyfig is designed to be the central, versioned source of typed design tokens. App repositories do not need Figma credentials or a token-generation workflow.

1. In Xcode, choose **File → Add Package Dependencies**, enter the Skyfig repository URL, and select a stable release.
2. Add the `Skyfig` library product to the iOS app target.
3. Import `Skyfig` and use `SkyfigTokens` from SwiftUI views.
4. When design tokens are released, update the package version in a dedicated app pull request and verify the UI before merging.

The package exposes typed token values; it does not contact Figma at app runtime. See [Versioning and releases](VERSIONING.md) and the [release checklist](RELEASING.md) for how new token versions are published.

## See it in a real iOS app

The repository includes [SkyfigConsumer](Examples/SkyfigConsumer/README.md), an iOS 26+ SwiftUI sample that imports Skyfig through a separate app project. It is a practical reference for package consumers and demonstrates:

- a modern, full-screen iPhone presentation and an adaptive iPad layout;
- five token-driven tabs: Home, Library, Activity, Profile, and Search;
- a native search-tab role, an app-bar add button, and generated colors, typography, spacing, corner radii, and elevation shadows.

Open `Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj`, select an iOS 26 iPhone or iPad simulator, and run the `SkyfigConsumer` scheme. The [sample guide](Examples/SkyfigConsumer/README.md) includes the full verification steps.

## Add Skyfig to an app

After the first tagged release, add the package URL in Xcode or in `Package.swift`:

```swift
.package(url: "https://github.com/ichakradharg/skyfig.git", from: "0.1.0")
```

Then depend on the `Skyfig` product and import it:

```swift
import SwiftUI
import Skyfig

struct Card: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text("Hello, Skyfig")
            .font(SkyfigTokens.Typography.headline.font)
            .tracking(SkyfigTokens.Typography.headline.letterSpacing)
            .foregroundStyle(SkyfigTokens.Colors.Text.primary.color(for: colorScheme))
            .padding(SkyfigTokens.Spacing.md)
            .background(SkyfigTokens.Colors.Surface.primary.color(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SkyfigTokens.CornerRadii.card))
    }
}
```

Generated values remain platform-neutral (`SkyfigRGBAColor`, `SkyfigTypographyToken`, and `SkyfigShadowToken`). SwiftUI extensions convert them into `Color`, `Font`, tracking, and line-spacing values.

Run the example on macOS:

```bash
swift run SkyfigShowcase
```

## Verify the token pipeline

Skyfig includes fixture data so the complete token-to-Swift pipeline can be verified without Figma credentials. From a clean checkout, run:

```bash
# Run the package and generator test suites.
swift test --parallel

# Validate the canonical fixture-backed token document.
swift run skyfig validate --input Tokens/skyfig.tokens.json

# Confirm committed Swift output exactly matches the token document.
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --check
```

The generated, typed Swift API lives at `Sources/Skyfig/Generated/Tokens.generated.swift`. The showcase uses that API directly, so running `swift run SkyfigShowcase` is a visual demonstration of the generated tokens in SwiftUI.

For an iOS app, add Skyfig as a package dependency, import `Skyfig`, and use `SkyfigTokens` in SwiftUI views as shown above. See [Figma token-source options](FIGMA_TOKEN_SOURCE_OPTIONS.md) for the fixture path and the later live-Figma setup.

## Canonical tokens

`Tokens/skyfig.tokens.json` is the source of truth after import. Version 1 uses literal values only, exact `light` and `dark` themes, uppercase eight-digit sRGB colors, and dot-separated lower-camel token paths.

```json
{
  "$schema": "../Schema/skyfig.tokens.schema.json",
  "schemaVersion": "1.0.0",
  "name": "Example",
  "defaultTheme": "light",
  "themes": ["light", "dark"],
  "tokens": {
    "colors": {
      "surface.primary": {
        "values": { "light": "#FFFFFFFF", "dark": "#111827FF" }
      }
    },
    "typography": {},
    "spacing": {},
    "cornerRadii": {},
    "borderWidths": {},
    "shadows": {}
  }
}
```

The schema requires all six token maps; a category may be an empty object. Dimension, typography, and shadow metrics are expressed in points. Unknown properties, malformed identifiers, namespace collisions, invalid weights, non-finite dimensions, and missing theme values are rejected.

## Command line

```bash
# Validate canonical JSON
swift run skyfig validate --input Tokens/skyfig.tokens.json

# Convert a saved Figma Variables API response to canonical JSON
swift run skyfig normalize-figma \
  --input /tmp/figma-variables.json \
  --output Tokens/skyfig.tokens.json \
  --name "My Design System"

# Generate committed Swift source
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated

# Fail without writing when committed output is stale
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --check
```

Generation is sorted, locale-independent, timestamp-free, byte-stable, and atomic. A failed validation or `--check` does not replace the previous generated file. Hand-written runtime helpers live in `Sources/Skyfig/Runtime` and are outside the generator's output path.

## Figma setup

The workflow calls Figma's [`GET /v1/files/:file_key/variables/local`](https://developers.figma.com/docs/rest-api/variables-endpoints/) endpoint directly. That mode-capable endpoint currently requires an Enterprise plan, a full member, and `file_variables:read`. For CI, prefer a resource-allowlisted [plan access token](https://developers.figma.com/docs/rest-api/plan-access-tokens/) restricted to the one Figma file.

Add these GitHub Actions secrets:

- `FIGMA_ACCESS_TOKEN` — a token with `file_variables:read`, scoped as narrowly as possible;
- `FIGMA_FILE_KEY` — the Figma file key.

The token is step-scoped, passed through `X-Figma-Token`, and never accepted by the Skyfig CLI. The file key is also kept in Secrets so the file identity is not exposed in workflow source.

Run **Actions → Sync Figma tokens → Run workflow**, or rely on the weekly schedule. Repository Actions settings must permit `GITHUB_TOKEN` to create pull requests. GitHub may place CI for a pull request created by the built-in token in an approval-required state; if so, a maintainer must choose **Approve workflows to run** before the required PR check can complete. A least-privilege GitHub App installation token is the appropriate option if fully unattended PR checks are needed; do not substitute a broad personal access token.

### Figma naming convention

Collection modes are matched by name, case-insensitively, never by array position. Name them `Light` and `Dark`. A single-mode collection uses its default mode for both themes; a multi-mode collection must define both names so a misspelling cannot silently map dark values to light. Aliases are resolved across collections by theme; missing aliases and cycles fail the sync. Variables marked `deletedButReferenced` remain available for alias resolution but are not emitted as tokens.

| Canonical family | Figma variable names |
| --- | --- |
| Colors | `colors/accent`, `colors/surface/primary` (any COLOR variable outside a composite is also accepted) |
| Spacing | `spacing/md` |
| Corner radii | `cornerRadii/card` or `radius/card` |
| Border widths | `borderWidths/thin` |
| Typography | `typography/body/fontFamily`, `fontSize`, `fontWeight`, `lineHeight`, `letterSpacing` |
| Shadows | `shadows/card/color`, `x`, `y`, `blur`, `spread`, and optional `kind`; use `shadows/card/0/color` for ordered layers |

Typography and shadows are grouped because Figma Variables natively store primitive COLOR, FLOAT, and STRING values rather than composite styles. All required fields in a composite must be present. `fontWeight` accepts 100 through 900 or a standard name such as `Semibold`. Shadow `kind` is `drop` by default and may be `drop` or `inner`.

## CI and releases

Pull requests and `main` run builds, tests, canonical validation, and a generated-source freshness check. Releases follow [Semantic Versioning](VERSIONING.md) and are deliberately separate from token synchronization:

1. merge a reviewed change to `main`;
2. run the consumer UI tests locally on an iPhone and iPad simulator;
3. manually dispatch the **Release** workflow with a stable `X.Y.Z` version;
4. approve the protected `release` environment;
5. the workflow tags the exact tested commit and creates the GitHub release.

To make this a real review gate, configure the public `release` environment with required reviewers, protect `main` with the `CI / linux-toolchain` check and at least one PR approval, and protect `v*` tags from update or deletion. The iOS consumer build runs only for relevant package or sample changes. Run simulator UI validation locally or on a dedicated macOS runner rather than relying on shared GitHub-hosted simulator runners. A solo repository can keep the manual environment gate, but independent approval requires a trusted collaborator.

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow and [SECURITY.md](SECURITY.md) for private vulnerability reporting. Skyfig is licensed under Apache 2.0; see [LICENSE](LICENSE).
