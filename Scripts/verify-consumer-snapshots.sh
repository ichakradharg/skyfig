#!/usr/bin/env bash
set -euo pipefail

mode="${1:-verify}"
target="${2:-all}"
iphone_simulator="${SKYFIG_IPHONE_SIMULATOR:-iPhone 17 Pro}"
ipad_simulator="${SKYFIG_IPAD_SIMULATOR:-iPad Pro 13-inch (M5)}"
snapshot_directory="Examples/SkyfigConsumer/Snapshots"
derived_data_path="${SKYFIG_SNAPSHOT_DERIVED_DATA:-/private/tmp/skyfig-consumer-snapshots}"
app_path="$derived_data_path/Build/Products/Debug-iphonesimulator/SkyfigConsumer.app"
bundle_identifier="com.skyfig.consumer"
snapshot_settle_delay="${SKYFIG_SNAPSHOT_SETTLE_DELAY:-5}"

case "$mode" in
  record|verify) ;;
  *)
    echo "Usage: $0 [record|verify] [all|iphone|ipad]" >&2
    exit 64
    ;;
esac

case "$target" in
  all|iphone|ipad) ;;
  *)
    echo "Usage: $0 [record|verify] [all|iphone|ipad]" >&2
    exit 64
    ;;
esac

record_or_verify_snapshot() {
  local simulator="$1"
  local snapshot_name="$2"
  local actual_snapshot="/private/tmp/skyfig-${snapshot_name}-actual.png"
  local expected_snapshot="$snapshot_directory/${snapshot_name}.png"

  xcrun simctl boot "$simulator" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "$simulator" -b
  xcrun simctl ui "$simulator" appearance light
  xcrun simctl status_bar "$simulator" override \
    --time "9:41" \
    --dataNetwork wifi \
    --wifiBars 3 \
    --cellularBars 4 \
    --batteryLevel 100 \
    --batteryState charged

  xcodebuild build \
    -project Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj \
    -scheme SkyfigConsumer \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=$simulator" \
    -derivedDataPath "$derived_data_path" \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_ALLOWED=NO

  xcrun simctl install "$simulator" "$app_path"
  xcrun simctl launch --terminate-running-process "$simulator" "$bundle_identifier"
  sleep "$snapshot_settle_delay"
  xcrun simctl io "$simulator" screenshot "$actual_snapshot"

  if [[ "$mode" == "record" ]]; then
    cp "$actual_snapshot" "$expected_snapshot"
    echo "Recorded $expected_snapshot"
  elif [[ ! -f "$expected_snapshot" ]]; then
    echo "Missing baseline $expected_snapshot. Run '$0 record $target' on the dedicated visual-regression Mac." >&2
    exit 1
  elif ! cmp -s "$expected_snapshot" "$actual_snapshot"; then
    echo "Visual regression detected for $snapshot_name." >&2
    echo "Expected: $expected_snapshot" >&2
    echo "Actual:   $actual_snapshot" >&2
    exit 1
  else
    echo "Verified $snapshot_name"
  fi
}

mkdir -p "$snapshot_directory"

if [[ "$target" == "all" || "$target" == "iphone" ]]; then
  record_or_verify_snapshot "$iphone_simulator" "iphone-light"
fi

if [[ "$target" == "all" || "$target" == "ipad" ]]; then
  record_or_verify_snapshot "$ipad_simulator" "ipad-light"
fi
