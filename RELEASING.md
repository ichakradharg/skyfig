# Releasing Skyfig

This checklist keeps package releases predictable for iOS consumers.

## Before starting

- Ensure the intended token or API changes are merged to `main` through a reviewed pull request.
- Confirm the `main` CI run is green.
- Choose a stable `MAJOR.MINOR.PATCH` version using [Versioning and releases](VERSIONING.md).
- Prepare release notes that summarize token changes, consumer impact, and any migration work.
- Move the relevant Unreleased entries from [CHANGELOG.md](CHANGELOG.md) into the tagged release notes.
- Confirm the `release` environment has the intended reviewers and that `v*` tags are protected.

## Publish

1. Open **Actions → Release → Run workflow**.
2. Enter the chosen stable version without the `v` prefix.
3. Let the workflow build, test, validate tokens, and verify generated Swift.
4. Approve the protected `release` environment when prompted.
5. Confirm that GitHub created the immutable tag and release for the tested `main` commit.

## Verify as an iOS consumer

1. Add or update the Skyfig package dependency to the released version in a sample iOS app.
2. Build the app and verify views that use changed token families in light and dark appearance.
3. Confirm that the app has no Figma credentials and makes no Figma request at runtime.
4. Ship the app update through its normal review and release process.

See the [consumer upgrade guide](Docs/CONSUMER_UPGRADES.md) for the app-team adoption sequence.

## Guardrails

- Do not release directly from an automated Figma sync.
- Do not move or replace an existing release tag.
- Do not put Figma credentials, file keys, or raw API responses in source, release notes, or artifacts.
