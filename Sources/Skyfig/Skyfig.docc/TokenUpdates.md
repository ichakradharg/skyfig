# Adopt token updates safely

Skyfig separates design-token publishing from application adoption, so teams can review visual changes at a controlled pace.

## Publisher flow

1. The Skyfig repository imports approved Figma Variables or uses its fixture data.
2. It validates canonical JSON and deterministically regenerates the typed Swift API.
3. A pull request reviews the token and generated-source changes.
4. A release publishes an explicit semantic version.

## App-team flow

1. Update the Skyfig package requirement in an app pull request.
2. Build and run the app's tests and visual checks.
3. Review the affected screens before merging the dependency update.

This design prevents a design-system change from silently changing a shipped application. Use a patch release for compatible corrections, a minor release for additive tokens, and a major release when a consumer-facing token is removed or changed incompatibly.

## Inspect the source of a token

The publisher keeps reviewed canonical input in `Tokens/skyfig.tokens.json` and generated API source in `Sources/Skyfig/Generated/Tokens.generated.swift`. Consumers should reference only the public `SkyfigTokens` API; do not copy generated values into an app.
