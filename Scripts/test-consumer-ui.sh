#!/usr/bin/env bash
set -euo pipefail

target="${1:-all}"
simulator_os="${SKYFIG_SIMULATOR_OS:-latest}"
iphone_simulator="${SKYFIG_IPHONE_SIMULATOR:-iPhone 17 Pro}"
ipad_simulator="${SKYFIG_IPAD_SIMULATOR:-iPad Pro 13-inch (M5)}"

case "$target" in
  all|iphone|ipad) ;;
  *)
    echo "Usage: $0 [all|iphone|ipad]" >&2
    exit 64
    ;;
esac

run_tests() {
  local simulator="$1"

  xcrun simctl boot "$simulator" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$simulator" -b

  xcodebuild test \
    -project Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj \
    -scheme SkyfigConsumer \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=$simulator,OS=$simulator_os" \
    -only-testing:SkyfigConsumerUITests \
    -test-timeouts-enabled YES \
    -default-test-execution-time-allowance 60 \
    -maximum-test-execution-time-allowance 120 \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_ALLOWED=NO
}

if [[ "$target" == "all" || "$target" == "iphone" ]]; then
  run_tests "$iphone_simulator"
fi

if [[ "$target" == "all" || "$target" == "ipad" ]]; then
  run_tests "$ipad_simulator"
fi
