# Versioning and releases

Skyfig follows [Semantic Versioning 2.0.0](https://semver.org/). Swift Package versions are immutable Git tags named `vMAJOR.MINOR.PATCH`; there is no separate version constant.

- **Major**: a breaking public Swift API, canonical schema, generated API, or CLI contract change.
- **Minor**: a backward-compatible token capability, API, importer, or CLI addition.
- **Patch**: a compatible fix, deterministic-output correction, workflow hardening, or documentation-only release.

Before `1.0.0`, minor versions may include breaking changes, but they must still be called out explicitly in release notes.

## Token-change guidance

Treat generated token names and types as public API. Choose a version based on the consumer impact, not only on the size of the Figma change.

| Change | Typical release |
| --- | --- |
| Correct a value while preserving the token name, type, and intended meaning | Patch |
| Add an optional token or a backward-compatible capability | Minor |
| Remove or rename a token, change its Swift type, or change its semantic contract | Major |
| Change a widely used token in a way that requires app layout or visual re-validation | Minor, with clear release notes |

Every token-sync pull request should state the expected consumer impact and proposed release level. A release should include notes that identify changed token families and any migration steps.

Token synchronization never releases. A maintainer first merges a reviewed change to `main`, manually dispatches `.github/workflows/release.yml` with a stable version, and obtains approval for the protected `release` environment. The workflow tests the default-branch commit, verifies the version is greater than the latest stable tag, waits at the environment gate, then creates an annotated tag and GitHub release for that exact commit.

Before dispatching a release, run `Scripts/test-consumer-ui.sh` locally on an iPhone and iPad simulator. For token or consumer UI changes, also review the dedicated-Mac [visual baselines](Docs/VISUAL_REGRESSION.md); the initial baseline set covers light appearance only, so dark appearance needs an explicit review. The release workflow compiles the consumer app, but does not use a shared GitHub-hosted simulator for UI tests because those runners can stall before a test starts.

Repository administrators should protect `main`, require `CI / build-and-test`, require review, protect `v*` tags, and configure required reviewers on the `release` environment. Tags and published releases must not be moved or replaced.
