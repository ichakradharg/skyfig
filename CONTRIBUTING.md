# Contributing to Skyfig

Thank you for helping make design-token delivery safer and more predictable.

## Development setup

Use Swift 6.0 or newer on macOS. Clone the repository, create a focused branch, and run:

```bash
swift build
swift test --parallel
swift run skyfig validate --input Tokens/skyfig.tokens.json
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --check
```

If you intentionally change canonical tokens or the emitter, regenerate without `--check` and commit both the canonical input and generated output.

For changes to the iOS consumer sample, run `Scripts/test-consumer-ui.sh`. Changes that affect rendered appearance also need the dedicated-Mac [visual-baseline review](Docs/VISUAL_REGRESSION.md); do not record screenshots from ordinary hosted CI.

## Source boundaries

- `Schema/` defines the canonical interchange contract.
- `Tokens/` is reviewed source data.
- `Sources/Skyfig/Generated/` is generator-owned. Never edit it by hand.
- `Sources/Skyfig/Runtime/` contains hand-written, stable runtime helpers.
- `Sources/SkyfigGenerator/` and `Sources/SkyfigCLI/` must never contain credentials or make authenticated network requests.

The GitHub workflow owns the Figma HTTP request so credentials remain in a single, auditable, secret-scoped step.

## Schema and API changes

Canonical schema version and package version are separate. Keep compatible additions within schema `1.0.0`; a breaking canonical representation needs a new schema major and a migration plan. Public Swift API, schema, and CLI compatibility all participate in package [Semantic Versioning](VERSIONING.md).

Generator output must be deterministic: sort token paths, preserve shadow-layer order, use stable numeric and color formatting, emit no timestamps or local paths, and write only the documented generated file.

Add tests for new behavior. High-value coverage includes invalid JSON paths, light/dark mapping, aliases, identifier collisions, generated Swift compilation, and byte-identical output.

## Pull requests

Keep pull requests focused and explain:

- what changed and why;
- whether canonical schema or generated API compatibility changes;
- how the change was tested;
- any required repository or Figma configuration.

All changes, including automated token syncs, are review-first. Do not add automatic publishing to the sync workflow or include Figma responses, file keys, tokens, or other credentials in commits, fixtures, logs, or pull-request bodies.
