#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <normalized-token-document.json> [output-directory]" >&2
  exit 64
fi

input_document="$1"
output_directory="${2:-Tokens}"
temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/skyfig-token-split.XXXXXX")"
trap 'rm -rf "$temporary_directory"' EXIT

command -v jq >/dev/null 2>&1 || {
  echo "jq is required to split the canonical token document." >&2
  exit 69
}

known_families='[
  "borderWidths", "colors", "cornerRadii", "dynamic", "materials", "metrics",
  "motion", "opacities", "shadows", "spacing", "symbols", "typography"
]'

unknown_families="$(jq -r --argjson known "$known_families" '(.tokens | keys) - $known | join(",")' "$input_document")"
if [[ -n "$unknown_families" ]]; then
  echo "Refusing to drop unknown token families: $unknown_families" >&2
  exit 65
fi

write_partial() {
  local output_name="$1"
  local document_name="$2"
  local families="$3"
  local temporary_output="$temporary_directory/$output_name"

  jq --sort-keys --arg name "$document_name" --argjson families "$families" '
    {
      "$schema": .["$schema"],
      "defaultTheme": .defaultTheme,
      "name": $name,
      "schemaVersion": .schemaVersion,
      "themes": .themes,
      "tokens": (.tokens | with_entries(select(.key as $key | $families | index($key))))
    }
  ' "$input_document" > "$temporary_output"
  mv "$temporary_output" "$output_directory/$output_name"
}

mkdir -p "$output_directory"
write_partial \
  "foundations.tokens.json" \
  "Skyfig Foundations" \
  '["borderWidths", "cornerRadii", "metrics", "opacities", "shadows", "spacing", "typography"]'
write_partial \
  "semantic.tokens.json" \
  "Skyfig Semantic Tokens" \
  '["colors", "materials", "motion"]'
write_partial \
  "components.tokens.json" \
  "Skyfig Components" \
  '["symbols", "dynamic"]'
