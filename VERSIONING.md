# Versioning and releases

Skyfig follows [Semantic Versioning 2.0.0](https://semver.org/). Swift Package versions are immutable Git tags named `vMAJOR.MINOR.PATCH`; there is no separate version constant.

- **Major**: a breaking public Swift API, canonical schema, generated API, or CLI contract change.
- **Minor**: a backward-compatible token capability, API, importer, or CLI addition.
- **Patch**: a compatible fix, deterministic-output correction, workflow hardening, or documentation-only release.

Before `1.0.0`, minor versions may include breaking changes, but they must still be called out explicitly in release notes.

Token synchronization never releases. A maintainer first merges a reviewed change to `main`, manually dispatches `.github/workflows/release.yml` with a stable version, and obtains approval for the protected `release` environment. The workflow tests the default-branch commit, verifies the version is greater than the latest stable tag, waits at the environment gate, then creates an annotated tag and GitHub release for that exact commit.

Repository administrators should protect `main`, require `CI / build-and-test`, require review, protect `v*` tags, and configure required reviewers on the `release` environment. Tags and published releases must not be moved or replaced.
