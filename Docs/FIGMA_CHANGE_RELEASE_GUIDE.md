# From Figma handoff to package release

Use this guide when the UX team has approved a change in the team’s Figma Variables file and the change needs to reach iOS applications as a new Skyfig package version.

The change is not released directly from Figma. It moves through a reviewed token pull request, then through a separately approved package release. This keeps every app team in control of when it adopts the visual change.

## Roles and inputs

- **UX team:** makes and approves the Figma Variables change, describes its intended visual impact, and identifies affected screens when known.
- **Skyfig publisher maintainer:** runs the sync, reviews the canonical token and generated Swift changes, chooses the proposed release level, and prepares release notes.
- **Release approver:** approves the protected `release` environment.
- **App team:** updates its package version in its own pull request and verifies its UI before adoption.

Before starting, confirm the publisher repository has the correct `FIGMA_ACCESS_TOKEN`, `FIGMA_FILE_KEY`, and, for a team-owned fork, `SKYFIG_TOKEN_NAMESPACE` Actions variable. These credentials stay in GitHub Actions secrets; never put them in tickets, pull requests, or source files.

## 1. Turn the approved design handoff into a token pull request

1. Confirm the UX team has finished its Figma Variables change. Check the expected token families, light and dark modes, and any renamed or removed tokens.
2. In the publisher repository, open **Actions → Sync Figma tokens → Run workflow**.
3. The workflow fetches Figma Variables, normalizes the canonical JSON, generates Swift, runs tests, and opens or updates a draft pull request. It does **not** release a package.
4. Review the pull request as a single change set: `Tokens/skyfig.tokens.json` explains the design values and `Sources/Skyfig/Generated/Tokens.generated.swift` shows the public Swift API.
5. Confirm a fork’s generated namespace is correct. New app code should use the configured name, such as `TeamATokens`; `SkyfigTokens` remains only as compatibility support for bundled examples.

If Figma access is not available, use the fixture path for generator and CI work, but do not describe it as a live design sync.

## 2. Assess consumer impact

Record the following in the token pull request and draft release notes:

- changed token families and their intended visual effect;
- whether any public token was added, renamed, removed, or changed in type or meaning;
- screens that need visual review; and
- the proposed semantic version.

Use [Versioning and releases](../VERSIONING.md) as the decision rule: compatible corrections are normally patches, additive tokens are normally minors, and removed, renamed, or incompatible public tokens require a major version. A widespread visual change may need a minor release even when its Swift type is unchanged.

## 3. Validate and merge the token pull request

1. Let required CI checks finish.
2. Review generated Swift, semantic-token use, and accessibility impact. Confirm contrast and Dynamic Type guidance when relevant.
3. For consumer-facing visual changes, run the iPhone and iPad UI tests locally and review the dedicated-Mac visual baselines. Review dark appearance explicitly because the current baseline set is light-only.
4. Obtain the required code-owner approval and merge the token pull request into `main`.

Do not hand-edit generated Swift and do not merge a Figma sync merely because the workflow completed.

## 4. Publish the package release

1. Update `CHANGELOG.md` with the consumer impact, proposed version, and any migration instructions.
2. Confirm `main` is green and the `release` environment has the intended approvers.
3. Open **Actions → Release → Run workflow** and enter the selected stable `MAJOR.MINOR.PATCH` version without the `v` prefix.
4. Let the workflow rebuild, test, validate tokens, check generated source, and compile the consumer sample.
5. Approve the protected `release` environment.
6. Confirm GitHub created the immutable `vMAJOR.MINOR.PATCH` tag and release for the tested `main` commit.

Tags are immutable. If a problem is found after publishing, do not move or replace the tag; publish a corrective version instead.

## 5. Hand the release to application teams

1. Announce the version, affected token families, visual impact, and any migration steps.
2. Each app team updates the package version in its own pull request.
3. Each app builds, runs its normal UI and accessibility checks, and reviews screens that use changed tokens before merging.

Applications never receive a Figma change automatically. Their explicit package-version update makes adoption testable and reversible.

## Quick decision path

| Situation | Action |
| --- | --- |
| UX approves a Figma Variables change | Run **Sync Figma tokens** and review its draft pull request. |
| Token values are corrected without an API change | Usually release a patch after review. |
| New optional tokens are added | Usually release a minor version. |
| A public token is removed, renamed, or made incompatible | Plan a major version and migration notes. |
| Live Figma access is unavailable | Continue fixture validation; wait to claim a live sync until credentials are available. |
| A released package has a defect | Publish a new corrective version; never retag the old one. |

For the compact release operator checklist, see [Releasing Skyfig](../RELEASING.md). For app-team adoption, see [Consumer upgrade guide](CONSUMER_UPGRADES.md).
