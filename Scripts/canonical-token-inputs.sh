#!/usr/bin/env bash

# Shared canonical source order for local scripts and GitHub Actions.
skyfig_repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SKYFIG_CANONICAL_TOKEN_FILES=(
  "$skyfig_repository_root/Tokens/foundations.tokens.json"
  "$skyfig_repository_root/Tokens/semantic.tokens.json"
  "$skyfig_repository_root/Tokens/components.tokens.json"
)

SKYFIG_CANONICAL_TOKEN_ARGS=()
for token_file in "${SKYFIG_CANONICAL_TOKEN_FILES[@]}"; do
  SKYFIG_CANONICAL_TOKEN_ARGS+=(--input "$token_file")
done
