# Fork and own Skyfig

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
4. Allow the repository token to create pull requests.
5. Replace the inherited `@ichakradharg` entry in `.github/CODEOWNERS` with the team’s own owner or team handle.
6. Configure the team’s own branch protection, required checks, release reviewers, `v*` tag protection, Pages, and Actions settings. GitHub does not copy these settings to a fork.

The repository’s `Docs/FORK_AND_OWN.md` guide contains the fixture path, command examples, ownership model, and troubleshooting details.
