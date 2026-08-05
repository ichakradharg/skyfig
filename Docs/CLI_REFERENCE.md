# Skyfig CLI reference

The `skyfig` executable works with local files. It never accepts Figma credentials and does not make authenticated network requests.

## Validate canonical tokens

```bash
swift run skyfig validate --input Tokens/skyfig.tokens.json
```

Validates the JSON document's structure, supported schema version, token paths, themes, values, and composite token requirements.

## Normalize a saved Figma response

```bash
swift run skyfig normalize-figma \
  --input /path/to/figma-variables.json \
  --output Tokens/skyfig.tokens.json \
  --name "My Design System"
```

Converts a saved Variables API response to canonical JSON. The GitHub workflow is responsible for downloading the source response securely.

No family mapping file is required. The normalizer retains every supported primitive variable's slash-separated hierarchy in `tokens.dynamic`; generation emits that hierarchy directly below `--namespace`. Semantic families remain available for existing Skyfig consumers. COLOR, FLOAT, STRING, and BOOLEAN are supported. Complete, unambiguous sibling groups with recognized typography or shadow fields also generate bundled composite tokens; partial and ambiguous groups remain primitives.

## Generate typed Swift

```bash
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --namespace TeamATokens
```

Writes `Tokens.generated.swift` into the output directory. Pass a `.swift` path to write to one exact file.

`--namespace` controls the generated public enum. It defaults to `SkyfigTokens`, so existing repositories and consumers remain compatible. A team-owned fork can choose a distinct Swift type name, such as `TeamATokens`; use the same namespace every time you generate or check the output. Custom output includes `SkyfigTokens` as a compatibility alias for the bundled Skyfig tests and examples, while new app code should use the selected namespace.

## Check generated source in CI

```bash
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --namespace TeamATokens \
  --check
```

Fails without writing when the committed source differs from the deterministic output.
