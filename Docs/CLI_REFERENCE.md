# Skyfig CLI reference

The `skyfig` executable works with local files. It never accepts Figma credentials and does not make authenticated network requests.

## Validate canonical tokens

```bash
source Scripts/canonical-token-inputs.sh
swift run skyfig validate "${SKYFIG_CANONICAL_TOKEN_ARGS[@]}"
```

Validates the JSON document's structure, supported schema version, token paths, themes, values, and composite token requirements.

Repeat `--input` to validate a shared set as one token source. Each file is validated independently before the combined token paths are validated:

```bash
swift run skyfig validate \
  --input Tokens/foundations.tokens.json \
  --input Tokens/semantic.tokens.json \
  --input Tokens/components.tokens.json
```

## Normalize a saved Figma response

```bash
swift run skyfig normalize-figma \
  --input /path/to/figma-variables.json \
  --output /tmp/skyfig.tokens.json \
  --name "My Design System"
Scripts/split-canonical-tokens.sh /tmp/skyfig.tokens.json Tokens
```

Converts a saved Variables API response to canonical JSON. The GitHub workflow is responsible for downloading the source response securely.

No family mapping file is required. Recognized semantic families are normalized into their typed token maps. Other supported primitive variables retain their slash-separated hierarchy in `tokens.dynamic`, unless their root is reserved by a generated family, and generation emits that hierarchy directly below `--namespace`. COLOR, FLOAT, STRING, and BOOLEAN are supported. Complete, unambiguous sibling groups with recognized typography or shadow fields also generate bundled composite tokens; partial and ambiguous groups remain primitives.

## Generate typed Swift

```bash
swift run skyfig generate \
  --input Tokens/foundations.tokens.json \
  --input Tokens/semantic.tokens.json \
  --input Tokens/components.tokens.json \
  --output Sources/Skyfig/Generated \
  --namespace TeamATokens
```

Writes `Tokens.generated.swift` into the output directory. Pass a `.swift` path to write to one exact file.

`--input` is repeatable. Canonical files may omit token families they do not own; omitted families decode as empty maps. Skyfig combines all families into one generated API and rejects any duplicate token path with both source filenames. Input order never acts as override precedence.

`--namespace` controls the generated public enum. It defaults to `SkyfigTokens`, so existing repositories and consumers remain compatible. A team-owned fork can choose a distinct Swift type name, such as `TeamATokens`; use the same namespace every time you generate or check the output. Custom output includes `SkyfigTokens` as a compatibility alias for the bundled Skyfig tests and examples, while new app code should use the selected namespace.

## Check generated source in CI

```bash
swift run skyfig generate \
  --input Tokens/foundations.tokens.json \
  --input Tokens/semantic.tokens.json \
  --input Tokens/components.tokens.json \
  --output Sources/Skyfig/Generated \
  --namespace TeamATokens \
  --check
```

Fails without writing when the committed source differs from the deterministic output.
