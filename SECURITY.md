# Security policy

## Supported versions

Security fixes are made on `main` and in the latest released major version. Before the first release, only `main` is supported.

| Version | Supported |
| --- | --- |
| `main` | Yes |
| Latest major release | Yes |
| Older major releases | No |

## Report a vulnerability

Please do not disclose a suspected vulnerability in a public issue. Use GitHub's private vulnerability reporting from the repository's **Security** tab. Include the affected revision, impact, reproduction steps, and any suggested mitigation. If the private-reporting button is unavailable, open an issue containing no vulnerability details and ask a maintainer to establish a private contact channel.

Maintainers will acknowledge a complete report as soon as practical, coordinate validation and remediation privately, and credit reporters when requested and appropriate.

## Secrets and generated content

Skyfig does not need credentials at runtime. Figma credentials belong only in GitHub Actions Secrets and are scoped to the fetch step in `.github/workflows/sync-figma.yml`. Never commit Figma API responses or pass access tokens as CLI arguments. Generated Swift must contain normalized token literals only—never source IDs, access tokens, environment values, timestamps, or machine paths.

## Automated dependency safeguards

Dependabot opens weekly update pull requests for Swift package dependencies and GitHub Actions. Dependabot security updates, secret scanning, and push protection are enabled in the repository settings. Pull requests that change dependencies or workflows run the dependency-review check, which blocks newly introduced high-severity vulnerabilities. CodeQL scans Swift and GitHub Actions workflows after merges to `main`, weekly, and when run manually; it is kept off pull-request CI to preserve fast feedback.
