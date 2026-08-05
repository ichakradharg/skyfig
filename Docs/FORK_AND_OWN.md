# Fork and own Skyfig

Use this guide when a vertical team wants to own its design tokens, Figma access, pull-request approvals, and package releases independently.

## What a fork owns

Your fork is its own token publisher. Your team owns:

- the Figma file and the two repository secrets used to read it;
- generated canonical JSON and Swift source;
- pull-request rules, reviewers, package releases, and app adoption timing.

The upstream Skyfig repository remains the generator and reference implementation. Updating to a newer upstream version is optional and happens through your own pull request.

## First-time setup

1. Fork Skyfig, then enable GitHub Actions in the fork.
2. Choose a token namespace for application code. It must be a Swift type name, such as `TeamATokens` or `PaymentsTokens`.
3. In **Settings → Secrets and variables → Actions → Variables**, create `SKYFIG_TOKEN_NAMESPACE` with that value. If you do not create it, generated code keeps the default `SkyfigTokens` namespace.
4. In **Settings → Secrets and variables → Actions → Secrets**, add `FIGMA_ACCESS_TOKEN` and `FIGMA_FILE_KEY`. Keep both values out of source code and pull-request text.
5. Run **Sync Figma tokens** manually once. After it succeeds, create the Actions variable `FIGMA_SYNC_ENABLED` with the value `true` to enable weekly synchronization. Scheduled runs stay skipped while this variable is unset.
6. In **Settings → Actions → General**, allow the repository `GITHUB_TOKEN` to create pull requests.
7. Replace the inherited `@ichakradharg` entry in `.github/CODEOWNERS` with your team’s owner or team handle.
8. Configure your own branch protection, required CI checks, release-environment reviewers, `v*` tag protection, Pages, and Actions settings. GitHub does not copy these repository settings when you fork.

The live Figma endpoint requires the eligible Figma plan, membership, and variable-read permission. Until that access is ready, fixture mode continues to validate the full generation pipeline without credentials.

## Fork readiness checklist

Before inviting app teams to depend on the fork, confirm all of the following:

- `swift test --parallel` and `Scripts/test-custom-namespace.sh` pass locally;
- the configured namespace appears in `Sources/Skyfig/Generated/Tokens.generated.swift` after generation;
- the fork’s `CODEOWNERS`, branch rules, required CI check, release environment, and tag rules belong to the team—not the upstream repository owner;
- GitHub Pages is enabled only if the team wants hosted DocC, and the Pages workflow has been run once;
- the package URL in consumer apps points to the team fork and uses a released version, never the default branch.

## Generate and review tokens

Share the [Figma variable authoring rules](FIGMA_AUTHORING_GUIDE.md) with designers before the first live sync. It defines the flexible hierarchy model, recognized composite leaf roles, modes, aliases, and the handoff checklist.

Run **Actions → Sync Figma tokens → Run workflow** in your fork. The workflow reads only your repository secrets and opens or updates a draft pull request. Review both the canonical JSON and generated Swift changes before merging.

The first sync should be treated as an onboarding exercise: inspect the canonical token diff, confirm the generated namespace, let the required CI check finish, and merge only after the team owner approves it.

The namespace affects the generated API only. The Swift package module remains `Skyfig` unless your team intentionally renames the package as a separate migration. Skyfig keeps `SkyfigTokens` as a compatibility alias for its bundled tests and examples; new application code should use your chosen namespace.

Your Figma naming hierarchy does not need to match Skyfig's semantic fixture. Supported primitive variables retain their slash hierarchy automatically, so `foundation/colors/brand/primary` becomes `TeamATokens.Foundation.Colors.Brand.primary`. There is no per-team mapping configuration. Names are normalized only as required by Swift and ambiguous normalized paths fail with actionable source-name errors.

Dynamic output exposes COLOR, FLOAT, STRING, and BOOLEAN variables individually. Skyfig also examines sibling variables without requiring a team-specific outer-path map. A complete typography group containing family, size, weight, line height, and letter spacing becomes a bundled `SkyfigTypographyToken`; a complete shadow group containing color, x, y, and blur becomes a bundled `SkyfigShadowToken`. Common field aliases are supported. Partial, incorrectly typed, or ambiguous groups remain primitives so a fork never receives a guessed composite. The explicit `typography/...` and `shadows/...` conventions remain compatible.

For example, the sibling variables `semantic/text/body/family`, `size`, `weight`, `leading`, and `tracking` generate one `TeamATokens.Typography.Semantic.Text.body` token. The outer folders and style name remain owned by the Figma team; Skyfig only recognizes the leaf roles needed to assemble the style.

For Apple-platform typography, use the generated token with the matching SwiftUI `Font.TextStyle`. This lets the system scale across standard and accessibility Dynamic Type sizes. The repository's Apple HIG fixture and consumer sample demonstrate all 11 standard iOS and iPadOS styles.

```swift
import Skyfig

Text("Account balance")
    .font(
        TeamATokens.Typography.Semantic.Text.body
            .font(relativeTo: .body)
    )

Text("Pay now")
    .padding(TeamATokens.Spacing.md)
    .foregroundStyle(TeamATokens.Colors.Text.primary.color(for: colorScheme))
```

## Local generation

Use the same namespace locally and in CI. This keeps generated output deterministic.

```bash
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --namespace TeamATokens
```

The namespace must be a valid Swift identifier: begin with a letter or underscore, contain only letters, numbers, and underscores, and not be a Swift keyword.

The repository variable is the source of truth for hosted checks. For local work, pass the same value with `--namespace`; `Scripts/test-custom-namespace.sh` proves that a non-default namespace still builds the package and its consumer example.

## Release to app developers

After a reviewed token pull request merges, your team chooses when to release. Create a semantic version tag and GitHub Release from your fork. App developers add your fork URL as a Swift Package dependency, import `Skyfig`, and use your configured token namespace.

Token changes are not delivered automatically to apps. Each app deliberately updates to a released package version in its own pull request.

## Troubleshooting

- **Missing secret:** add both Figma secrets in the fork, with their exact names.
- **Namespace error:** correct `SKYFIG_TOKEN_NAMESPACE` to a valid Swift type name.
- **Stale output:** regenerate locally with the same namespace as the repository variable.
- **Checks fail after the first sync:** confirm the same `SKYFIG_TOKEN_NAMESPACE` Actions variable is configured for CI and releases; generated output includes a compatibility alias so the bundled examples continue to compile.
- **Figma request fails:** check Figma plan eligibility, file membership, token scope, and file key.

For the full fixture and Figma access paths, see [Figma token-source options](../FIGMA_TOKEN_SOURCE_OPTIONS.md). For release rules, see [Versioning and releases](../VERSIONING.md).
