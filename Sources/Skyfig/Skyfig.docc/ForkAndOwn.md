# Fork and own Skyfig

Each vertical team can use a fork as its own design-token publisher. The team owns Figma access, generated source, review rules, releases, and app adoption timing.

## Configure a generated token namespace

Set the repository Actions variable `SKYFIG_TOKEN_NAMESPACE` to a Swift type name such as `TeamATokens`. The Figma sync workflow passes that value to the generator, so application code uses the team-specific API while still importing the `Skyfig` module.

```swift
import Skyfig

let spacing = TeamATokens.Spacing.md
```

If the variable is unset, Skyfig preserves the default ``SkyfigTokens`` API. Use one namespace consistently for local generation, CI, and the sync workflow.

## First-time fork setup

1. Enable Actions in the fork.
2. Add `FIGMA_ACCESS_TOKEN` and `FIGMA_FILE_KEY` as repository secrets.
3. Optionally add `SKYFIG_TOKEN_NAMESPACE` as a repository Actions variable.
4. Allow the repository token to create pull requests.
5. Configure the team’s own code owners, branch protection, and release reviewers.

The complete command examples, ownership model, fixture path, and troubleshooting guide are in the repository’s [Fork and own Skyfig guide](https://github.com/ichakradharg/skyfig/blob/main/Docs/FORK_AND_OWN.md).
