# From Figma handoff to package release

Use this workflow when UX has approved a Figma Variables change and it needs to become a new package version for app teams.

## Publisher workflow

1. Confirm the Figma Variables change and expected consumer impact with UX.
2. Run **Sync Figma tokens** in the publisher repository.
3. Review the canonical token JSON and generated Swift together in the draft pull request.
4. Complete CI, accessibility, and relevant visual review, then merge the reviewed token change.
5. Choose a semantic version, update release notes, and run the protected **Release** workflow.
6. Approve the `release` environment so GitHub creates the immutable package tag and release.

The sync workflow never publishes a package. A team-owned fork follows the same sequence with its own Figma secrets, approvals, namespace, and release environment.

For a fork, supported primitive Figma paths generate directly beneath the team's namespace without a static family map. Keep a semantic review for any typography or shadow composites: Skyfig intentionally does not infer those structures from arbitrary variable names.

## App-team workflow

App teams choose when to update to the released package version. They build and review affected UI in their own pull request before adoption. This prevents an approved Figma change from silently changing a shipped application.

## Important rules

- Use the configured team namespace, such as `TeamATokens`, in new app code for a fork.
- Never put Figma credentials or raw API responses in source control, tickets, or release notes.
- Never move or replace a published tag. Publish a new corrective version instead.
- When live Figma access is unavailable, fixture validation still proves the generator path but is not a live sync.

The repository’s `Docs/FIGMA_CHANGE_RELEASE_GUIDE.md` has the complete role-based checklist, version decision guide, and recovery path.
