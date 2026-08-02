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

## Generate typed Swift

```bash
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated
```

Writes `Tokens.generated.swift` into the output directory. Pass a `.swift` path to write to one exact file.

## Check generated source in CI

```bash
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --check
```

Fails without writing when the committed source differs from the deterministic output.
