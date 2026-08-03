# Consumer upgrade guide

Skyfig releases are explicit package versions. Updating a dependency is an app-team decision, not an automatic design change.

## Before updating

1. Read the target release section in [CHANGELOG.md](../CHANGELOG.md).
2. Check the stated token families, visual impact, and any migration notes.
3. Update Skyfig in a dedicated application pull request.

## Validate the app change

1. Build the app with the new package version.
2. Review every screen using the changed semantic token families in light and dark appearance.
3. Test at a larger Dynamic Type size when typography or layout changed.
4. Run the app's usual accessibility, UI, and screenshot checks.
5. Merge the app pull request only after the visual change is accepted.

For the repository consumer sample, run `Scripts/test-consumer-ui.sh` on both devices and, when a change affects rendered appearance, verify the dedicated-Mac [visual baselines](VISUAL_REGRESSION.md). Review dark appearance separately because the initial screenshot baselines cover light appearance only.

## Handle breaking changes

Major versions may remove, rename, or change the type or meaning of public generated tokens. Follow the release migration notes, update call sites, and avoid copying token values into the app as a workaround. If a deprecated token is available, migrate before the next major release rather than waiting for removal.

## Pin versions intentionally

Use a stable release requirement in Xcode or `Package.swift`. Do not point production apps at Skyfig's default branch; a version pin makes the design-system update testable and reversible for each app team.
