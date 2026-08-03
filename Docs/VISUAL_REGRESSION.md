# Consumer visual regression

Skyfig uses deterministic iPhone and iPad screenshots to catch unintended visual changes in the consumer sample. This is a separate assurance layer from package tests, accessibility checks, and consumer UI tests.

## What is covered today

The committed baselines live in `Examples/SkyfigConsumer/Snapshots`:

- `iphone-light.png`
- `ipad-light.png`

The workflow captures the consumer app after fixing simulator appearance and status-bar state. It is deliberately limited to light appearance for the first baseline set. Dark-mode visual review is deferred; do not interpret a passing visual-regression run as dark-mode approval. Add dark baselines only through a reviewed follow-up that updates the recording script, this guide, and the sample documentation together.

## Dedicated Mac requirements

The workflow runs only on a repository self-hosted runner whose labels include `self-hosted`, `macOS`, and `skyfig-visual`. GitHub-hosted runners are intentionally not used for screenshot comparison because simulator images and rendering can vary.

Before registering the runner, prepare a dedicated Mac with:

1. A stable macOS and Xcode installation. Keep the Xcode and iOS simulator runtime versions unchanged between baseline recording and verification.
2. The iPhone and iPad simulator devices named by `Scripts/verify-consumer-snapshots.sh` (or documented `SKYFIG_IPHONE_SIMULATOR` and `SKYFIG_IPAD_SIMULATOR` overrides).
3. A logged-in local user able to boot simulators and write `/private/tmp/skyfig-consumer-snapshots`.
4. An always-available network connection while the runner service is active.

Confirm the simulator inventory before recording:

```bash
xcrun simctl list devices available
xcodebuild -version
```

## Register the runner

Runner registration is a machine-level action. A repository administrator should use **GitHub → Settings → Actions → Runners → New self-hosted runner** on the dedicated Mac, follow GitHub's generated commands, then add the `skyfig-visual` label. Do not put the short-lived registration token in this repository, shell history, workflow source, issues, or pull requests.

After registration, verify that the runner is **Idle** in repository settings and exposes the required labels. The scheduled and manually dispatched [Visual Regression workflow](../.github/workflows/visual-regression.yml) will then select it automatically.

## Record the first baselines

Record from a clean checkout on the dedicated Mac, not from normal hosted CI and not by dispatching the workflow's `record` mode. The workflow has read-only repository permissions and intentionally does not commit screenshots.

```bash
git switch main
git pull --ff-only
git switch -c feat/record-consumer-baselines

Scripts/verify-consumer-snapshots.sh record all
Scripts/verify-consumer-snapshots.sh verify all
```

Inspect both PNGs under `Examples/SkyfigConsumer/Snapshots` at full size. Confirm the expected iPhone and iPad layouts, semantic colors, Dynamic Type-safe text placement, focus/selection states, and absence of simulator or launch artifacts. Then commit only the reviewed baseline images and open a pull request. Do not include Xcode `xcuserdata`, derived data, or temporary actual screenshots.

## Verify and refresh

Use `Scripts/verify-consumer-snapshots.sh verify all` on the dedicated Mac before merging visual changes. The workflow also supports **Actions → Visual Regression → Run workflow → verify** and runs weekly from the default branch.

When a visual change is intentional, record a fresh baseline in a dedicated pull request. Explain the affected token families or consumer UI behavior, attach/review the image diff, and keep the runner/toolchain stable. Treat an Xcode or simulator upgrade as an intentional baseline refresh, never as an unnoticed routine change.

## Related checks

- [Consumer UI tests](../Examples/SkyfigConsumer/README.md) verify navigation and token-driven content on iPhone and iPad.
- [Accessibility guidance](ACCESSIBILITY.md) covers Dynamic Type, contrast, VoiceOver, and dark appearance review.
- [Token governance](TOKEN_GOVERNANCE.md) explains semantic-token and consumer-impact review requirements.
- [Release checklist](../RELEASING.md) includes app and visual review before publication.
