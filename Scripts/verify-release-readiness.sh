#!/usr/bin/env bash
set -euo pipefail

doc_output=".build/release-docc"
rm -rf "$doc_output"

swift build
swift test --parallel
swift package plugin --allow-writing-to-package-directory swiftlint lint
swift run skyfig validate --input Tokens/skyfig.tokens.json
swift run skyfig generate --input Tokens/skyfig.tokens.json --output Sources/Skyfig/Generated --check
Scripts/test-cli-integration.sh
swift run --package-path Examples/SkyfigPackageConsumer
swift package --allow-writing-to-directory "$doc_output" \
  generate-documentation --target Skyfig --output-path "$doc_output"
test -f "$doc_output/documentation/skyfig/index.html"
python3 Scripts/check-markdown-links.py
xcodebuild test \
  -project Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj \
  -scheme SkyfigConsumer \
  -sdk iphonesimulator26.0 \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0.1' \
  -arch arm64 \
  -only-testing:SkyfigConsumerUITests \
  CODE_SIGNING_ALLOWED=NO
xcodebuild test \
  -project Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj \
  -scheme SkyfigConsumer \
  -sdk iphonesimulator26.0 \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=26.0.1' \
  -arch arm64 \
  -only-testing:SkyfigConsumerUITests \
  CODE_SIGNING_ALLOWED=NO
