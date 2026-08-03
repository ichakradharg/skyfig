# Consumer screenshot baselines

This directory stores committed baseline screenshots for the iPhone and iPad consumer sample. They are checked only on the dedicated `skyfig-visual` Mac runner, never in normal pull-request CI.

## Bootstrap the dedicated runner

1. Register a dedicated, always-on Mac as a GitHub self-hosted runner for this repository.
2. Apply the `skyfig-visual` label and keep Xcode plus the named iPhone and iPad simulators installed.
3. Check out `main` and run `Scripts/verify-consumer-snapshots.sh record`.
4. Review the created screenshots, commit them in a pull request, and merge them.
5. Use **Actions → Visual Regression → Run workflow** with `verify`; the weekly run then verifies that the committed screens remain pixel-stable.

The script fixes the simulator status bar and appearance before each capture. Keep the runner's Xcode and simulator versions stable; a toolchain upgrade should be handled as an intentional baseline-refresh pull request.

## Local use

```bash
Scripts/verify-consumer-snapshots.sh record iphone
Scripts/verify-consumer-snapshots.sh verify all
```

The expected baselines are deliberately not generated in ordinary CI. A visual mismatch should be reviewed as a design change, then re-recorded on the dedicated runner only when intended.
