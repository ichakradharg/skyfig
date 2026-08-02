# Figma token-source options

Skyfig supports two practical paths for its token-generation pipeline.

## Option A: use the fixture now

### What it is

The fixture is a saved example of the Figma Variables API response. It contains representative colors, spacing, typography, radii, and light/dark modes, so the normalizer and generator can be tested without contacting Figma.

### When to use it

Use the fixture when no Figma Enterprise organization, API token, or production design-system file is available.

### What it validates

- Schema validation and token normalization.
- Deterministic Swift source generation.
- CI checks, tests, and generated-source freshness.
- Review-based delivery through pull requests.

It does not prove access to a live Figma file.

### Recommended workflow

Keep the fixture as stable test data. Update it deliberately for new token types or regression cases, and review generated Swift changes in pull requests.

## Option B: connect a live Figma source later

### Prerequisites

The Figma Variables REST API requires an eligible Figma Enterprise organization. A public Community file or a free Figma account does not grant this API access.

You will need:

- Access to the target design-system file.
- A Figma token with `file_variables:read` scope.
- The file key for that Figma file.
- Permission to manage GitHub repository secrets.

### GitHub configuration

Add these repository secrets:

| Secret | Purpose |
| --- | --- |
| `FIGMA_ACCESS_TOKEN` | Authenticates the Variables API request. |
| `FIGMA_FILE_KEY` | Identifies the source Figma file. |

GitHub Actions is already enabled to create the draft pull requests used by syncs.

### First live sync

1. Confirm the Figma variable collections and modes follow Skyfig's documented naming conventions.
2. Add the two repository secrets. Never commit or paste credentials into source, issues, or pull requests.
3. Run the **Sync Figma tokens** workflow manually.
4. Review the draft pull request containing the canonical JSON and generated Swift updates.
5. Let CI pass and merge through the protected `main` branch.

### Ongoing operation

The scheduled or manual sync should create a draft pull request rather than write directly to `main`. This preserves review, CI, and branch-protection controls.

## Choosing a path

| Situation | Recommended path |
| --- | --- |
| No Enterprise access yet | Fixture |
| Need deterministic generator and CI testing | Fixture |
| Need production tokens from Figma Variables | Live API sync |
| Need a free-plan source later | Export versioned design-token JSON and extend Skyfig to ingest it instead of the Variables API |

## References

- [Figma Variables guide](https://help.figma.com/hc/en-us/articles/15339657135383-Guide-to-variables-in-Figma)
- [Figma Variables REST API](https://developers.figma.com/docs/rest-api/variables/)
- [GitHub Actions secrets](https://docs.github.com/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions)
