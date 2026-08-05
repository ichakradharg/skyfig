# Fork and own Skyfig

## Structure-driven Figma variables

A fork can retain its existing Figma hierarchy without configuring a Skyfig family map. Supported primitive paths such as `foundation/colors/brand/primary` generate a nested API such as `TeamTokens.Foundation.Colors.Brand.primary`. Skyfig normalizes only for valid Swift identifiers and reports collisions. Colors, numbers, strings, and booleans are supported. Complete sibling groups with recognized typography or shadow fields also generate bundled composite tokens without mapping their outer path.

Figma stores typography and shadows as several primitive variables, not native composite values. Skyfig bundles a group only when every required field is present once with a compatible type. Common aliases such as `family`, `typeface`, `leading`, `tracking`, `offsetX`, and `blurRadius` are recognized. Partial or ambiguous groups stay primitive instead of being guessed. Numeric shadow layer segments define deterministic layer order; kind defaults to `drop` and spread defaults to zero.

For example, the sibling variables `semantic/text/body/family`, `size`, `weight`, `leading`, and `tracking` become one `TeamTokens.Typography.Semantic.Text.body` value. The outer folders and style name remain team owned; only the recognized leaf roles determine whether the group is complete.

```swift
Text("Account balance")
    .font(
        TeamTokens.Typography.Semantic.Text.body
            .font(relativeTo: .body)
    )
```

The Apple HIG fixture demonstrates all 11 standard iOS and iPadOS text styles. Consumers use each generated token with its corresponding SwiftUI text style so Dynamic Type, including accessibility sizes, remains system controlled.

Each vertical team can use a fork as its own design-token publisher. The team owns Figma access, generated source, review rules, releases, and app adoption timing.

## Configure a generated token namespace

Set the repository Actions variable `SKYFIG_TOKEN_NAMESPACE` to a Swift type name such as `TeamATokens`. The Figma sync workflow passes that value to the generator, so application code uses the team-specific API while still importing the `Skyfig` module.

```swift
import Skyfig

let spacing = TeamATokens.Spacing.md
```

If the variable is unset, Skyfig preserves the default ``SkyfigTokens`` API. For a custom name, generated output retains ``SkyfigTokens`` as a compatibility alias for the bundled examples and tests; new app code should use the team-specific API. CI, releases, and the sync workflow read the same variable.

## First-time fork setup

1. Enable Actions in the fork.
2. Add `FIGMA_ACCESS_TOKEN` and `FIGMA_FILE_KEY` as repository secrets.
3. Optionally add `SKYFIG_TOKEN_NAMESPACE` as a repository Actions variable.
4. Run **Sync Figma tokens** manually once, then add `FIGMA_SYNC_ENABLED=true` as a repository Actions variable to enable weekly synchronization. Without it, scheduled runs are skipped.
5. Allow the repository token to create pull requests.
6. Replace the inherited `@ichakradharg` entry in `.github/CODEOWNERS` with the team’s own owner or team handle.
7. Configure the team’s own branch protection, required checks, release reviewers, `v*` tag protection, Pages, and Actions settings. GitHub does not copy these settings to a fork.

The repository’s `Docs/FORK_AND_OWN.md` guide contains the fixture path, command examples, ownership model, and troubleshooting details.
