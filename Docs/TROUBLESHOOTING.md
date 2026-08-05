# Token sync and generation troubleshooting

Use this guide in the central Skyfig publisher repository. iOS apps that consume a released Skyfig package do not need Figma credentials or token-generation access.

## Start with the right boundary

There are two supported sources for tokens:

- **Fixture path** — committed canonical JSON under `Tokens/`; works without Figma access and is the normal local-development path.
- **Live Figma path** — the **Sync Figma tokens** GitHub Actions workflow fetches Figma Variables, normalizes them, generates Swift, and opens or updates a draft pull request.

The live workflow requires Figma Enterprise access, a full member, and the two repository secrets `FIGMA_ACCESS_TOKEN` and `FIGMA_FILE_KEY`. Do not put either value in source files, shell history, pull-request text, or issue comments.

Weekly synchronization is opt-in. After a manual sync succeeds, set the repository Actions variable `FIGMA_SYNC_ENABLED` to `true`. If the variable is missing or has any other value, scheduled runs are skipped; manual runs remain available and still fail clearly when credentials are missing or invalid.

## Local validation or generation fails

From the repository root, run the commands in this order:

```bash
swift run skyfig validate --input Tokens/skyfig.tokens.json
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --check
```

| Symptom | Likely cause | Resolution |
| --- | --- | --- |
| Validation reports a JSON path | A canonical token is missing, malformed, or uses an unsupported value. | Correct the cited value in `Tokens/skyfig.tokens.json`, then validate again. |
| Generation check reports stale output | The canonical JSON changed without regenerating the committed Swift source. | Run the same `generate` command without `--check`, review `Tokens.generated.swift`, and commit both files together. |
| Generated names collide | Two paths normalize to the same Swift identifier. | Rename the conflicting token path in the canonical JSON; do not hand-edit generated Swift. |
| A token family is unexpectedly empty | The source document is missing that family or its composite fields. | Check the canonical JSON or the Figma naming convention, then validate before generating. |

Generation is deterministic and atomic. A failed validation or `--check` leaves the existing generated file unchanged.

## Live Figma sync fails

### Dynamic Figma names do not generate as expected

No semantic family mapping is needed for supported primitives. Use non-empty slash-separated path segments; Skyfig converts punctuation and whitespace to lower-camel Swift identifiers, prefixes numeric-leading segments with `_`, and rejects source paths that normalize to the same output. COLOR, FLOAT, STRING, and BOOLEAN are dynamic; typography and shadows remain explicit composites because Skyfig does not infer semantics from arbitrary paths.

Open the failed **Sync Figma tokens** workflow run and identify the first failing step.

| Failing step or symptom | Likely cause | Resolution |
| --- | --- | --- |
| Missing secret | One or both GitHub Actions secrets are unset or misspelled. | Add `FIGMA_ACCESS_TOKEN` and `FIGMA_FILE_KEY` in repository Actions secrets, then rerun the workflow. |
| Figma returns access or plan errors | The token lacks `file_variables:read`, the user is not a full member, the file is inaccessible, or the plan does not support the Variables API. | Confirm Enterprise eligibility, membership, file access, and a least-privilege token. A public Figma file does not bypass these requirements. |
| Light or dark mode error | A multi-mode collection does not contain modes named `Light` and `Dark`. | Rename the Figma modes, case-insensitively, or use a single-mode collection. |
| Alias or cycle error | A referenced Figma variable is missing, deleted incorrectly, or part of an alias cycle. | Repair the alias relationship in Figma. Variables marked `deletedButReferenced` may resolve aliases but are not emitted. |
| Typography or shadow error | A composite token is incomplete or has an unsupported metric. | Supply every required component using the repository naming convention, then rerun. |

The workflow keeps the raw Figma response only in the runner's temporary directory. It commits canonical JSON and generated Swift, not credentials or raw API data.

## A sync pull request is created but cannot merge

This is expected until the pull request is reviewed and its checks pass.

1. Review the canonical JSON change and generated Swift diff together.
2. Confirm CI passes validation, generation freshness, tests, and the iOS consumer build.
3. If GitHub shows an approval-required Actions check on a bot-created pull request, a maintainer must approve that workflow run.
4. Obtain the required code-owner approval, then merge through the protected `main` branch.

Never merge by copying generated files directly to `main`; the pull request is the audit trail for a design-token change.

## Consumer app fails after a package update

Use the consumer app's compiler errors as the source of truth. A removed or renamed public token is intentionally a compile-time break, so update the app to the generated API for that publisher—`SkyfigTokens` by default or the team namespace in a fork—and verify its UI before merging the package-version update.

## Visual baseline setup or verification fails

Visual screenshots require a repository self-hosted Mac runner with the `skyfig-visual` label; ordinary GitHub-hosted CI does not create or compare baselines. Follow [consumer visual regression](VISUAL_REGRESSION.md) to verify runner labels, simulator names, Xcode versions, and the record/verify commands. If a screenshot differs, inspect it as a design review artifact rather than copying it over blindly. Dark appearance is not yet represented by the committed baseline set and must be reviewed separately.

For the repository sample, open `Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj` and run it on an iOS 26 simulator. If it appears letterboxed, confirm the target still generates its iOS launch screen and that the app is running from the current build.

## Escalation checklist

Before opening an issue or asking for help, include the failing command or workflow step, the first error message, the Skyfig version or commit, and whether you used the fixture or live-Figma path. Redact tokens, file keys, raw Figma responses, and any secret values.
