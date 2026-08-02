#!/usr/bin/env bash
set -euo pipefail

doc_output=".build/release-docc"
rm -rf "$doc_output"

swift build
swift test --parallel
swift run skyfig validate --input Tokens/skyfig.tokens.json
swift run skyfig generate --input Tokens/skyfig.tokens.json --output Sources/Skyfig/Generated --check
swift run --package-path Examples/SkyfigPackageConsumer
swift package generate-documentation --target Skyfig --output-path "$doc_output"
test -f "$doc_output/documentation/skyfig/index.html"
python3 Scripts/check-markdown-links.py
xcodebuild build \
  -project Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj \
  -scheme SkyfigConsumer \
  -sdk iphonesimulator26.0 \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
