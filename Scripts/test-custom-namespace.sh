#!/usr/bin/env bash
set -euo pipefail

# Proves that a fork can use a named public token API without breaking the
# package's own runtime tests and consumer sample.
namespace="TeamATokens"
generated_source="Sources/Skyfig/Generated/Tokens.generated.swift"
backup="$(mktemp "${TMPDIR:-/tmp}/skyfig-generated.XXXXXX")"

cleanup() {
  cp "$backup" "$generated_source"
  rm -f "$backup"
}
trap cleanup EXIT

cp "$generated_source" "$backup"
swift run skyfig generate \
  --input Tokens/skyfig.tokens.json \
  --output Sources/Skyfig/Generated \
  --namespace "$namespace"

grep -Fq "public enum $namespace" "$generated_source"
grep -Fq "public typealias SkyfigTokens = $namespace" "$generated_source"
swift test --parallel
swift run --package-path Examples/SkyfigPackageConsumer
