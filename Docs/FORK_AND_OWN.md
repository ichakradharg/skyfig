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
5. In **Settings → Actions → General**, allow the repository `GITHUB_TOKEN` to create pull requests.
6. Configure your own branch protection, code owners, and release reviewers.

The live Figma endpoint requires the eligible Figma plan, membership, and variable-read permission. Until that access is ready, fixture mode continues to validate the full generation pipeline without credentials.

## Generate and review tokens

Run **Actions → Sync Figma tokens → Run workflow** in your fork. The workflow reads only your repository secrets and opens or updates a draft pull request. Review both the canonical JSON and generated Swift changes before merging.

The namespace affects the generated API only. The Swift package module remains `Skyfig` unless your team intentionally renames the package as a separate migration.

```swift
import Skyfig

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

## Release to app developers

After a reviewed token pull request merges, your team chooses when to release. Create a semantic version tag and GitHub Release from your fork. App developers add your fork URL as a Swift Package dependency, import `Skyfig`, and use your configured token namespace.

Token changes are not delivered automatically to apps. Each app deliberately updates to a released package version in its own pull request.

## Troubleshooting

- **Missing secret:** add both Figma secrets in the fork, with their exact names.
- **Namespace error:** correct `SKYFIG_TOKEN_NAMESPACE` to a valid Swift type name.
- **Stale output:** regenerate locally with the same namespace as the repository variable.
- **Figma request fails:** check Figma plan eligibility, file membership, token scope, and file key.

For the full fixture and Figma access paths, see [Figma token-source options](../FIGMA_TOKEN_SOURCE_OPTIONS.md). For release rules, see [Versioning and releases](../VERSIONING.md).
