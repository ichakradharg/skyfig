#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cli="${SKYFIG_CLI_BIN:-$root/.build/debug/skyfig}"
temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/skyfig-cli-tests.XXXXXX")"
trap 'rm -rf "$temporary_directory"' EXIT

if [[ ! -x "$cli" ]]; then
  swift build --product skyfig
fi

expect_failure() {
  local description="$1"
  local expected_message="$2"
  shift 2

  local output
  local status
  set +e
  output="$("$@" 2>&1)"
  status=$?
  set -e

  if [[ $status -eq 0 ]]; then
    echo "Expected $description to fail." >&2
    exit 1
  fi
  if [[ "$output" != *"$expected_message"* ]]; then
    echo "Unexpected $description error:" >&2
    echo "$output" >&2
    exit 1
  fi
}

valid_tokens="$root/Tokens/skyfig.tokens.json"
generated="$temporary_directory/Tokens.generated.swift"
normalized="$temporary_directory/normalized.tokens.json"
shared_generated="$temporary_directory/SharedTokens.generated.swift"
shared_colors="$root/Tests/SkyfigGeneratorTests/Fixtures/shared-colors.tokens.json"
shared_layout="$root/Tests/SkyfigGeneratorTests/Fixtures/shared-layout.tokens.json"

expect_failure "missing command" "USAGE" "$cli"
expect_failure "unknown command" "Unknown command: unknown" "$cli" unknown
expect_failure "missing required option" "Missing required option --input" "$cli" validate

"$cli" validate --input "$valid_tokens" | grep -Fq "Valid Skyfig schema 1.0.0"
"$cli" generate --input "$valid_tokens" --output "$generated"
test -f "$generated"
"$cli" generate --input "$valid_tokens" --output "$generated" --check

"$cli" validate --input "$shared_colors" --input "$shared_layout" \
  | grep -Fq "Valid 2 Skyfig token files using schema 1.0.0"
"$cli" generate \
  --input "$shared_colors" \
  --input "$shared_layout" \
  --output "$shared_generated"
grep -Fq "public static let accent = SkyfigColorToken" "$shared_generated"
grep -Fq "public static let gutter: Double = 24" "$shared_generated"
module_cache="$temporary_directory/clang-module-cache"
mkdir -p "$module_cache"
CLANG_MODULE_CACHE_PATH="$module_cache" swiftc -typecheck \
  "$root/Sources/Skyfig/Runtime/TokenTypes.swift" \
  "$root/Sources/Skyfig/Runtime/SwiftUI+Skyfig.swift" \
  "$shared_generated"
expect_failure "duplicate shared token path" "$.tokens.colors.shared.accent: declared in both" \
  "$cli" generate \
    --input "$shared_colors" \
    --input "$shared_colors" \
    --output "$shared_generated"

printf '\n// stale fixture\n' >> "$generated"
expect_failure "stale generated source" "Generated output is stale" \
  "$cli" generate --input "$valid_tokens" --output "$generated" --check

"$cli" normalize-figma \
  --input "$root/Tests/SkyfigGeneratorTests/Fixtures/figma-variables.json" \
  --output "$normalized" \
  --name "CLI Integration Fixture"
"$cli" validate --input "$normalized" | grep -Fq "CLI Integration Fixture"

echo "CLI integration tests passed."
