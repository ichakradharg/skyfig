#!/usr/bin/env bash
set -euo pipefail

mode="${1:-verify}"
target="${2:-all}"
simulator_os="${SKYFIG_SIMULATOR_OS:-latest}"
iphone_simulator="${SKYFIG_IPHONE_SIMULATOR:-iPhone 17 Pro}"
ipad_simulator="${SKYFIG_IPAD_SIMULATOR:-iPad Pro 13-inch (M5)}"
snapshot_directory="Examples/SkyfigConsumer/Snapshots"
derived_data_path="${SKYFIG_SNAPSHOT_DERIVED_DATA:-/private/tmp/skyfig-consumer-snapshots}"
capture_test="SkyfigConsumerUITests/SkyfigConsumerUITests/testCaptureSnapshotTabs"
snapshot_tabs=(overview components content planning accessibility)

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

prepare_simulator() {
  local simulator="$1"

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
}

snapshot_name_for_tab() {
  local device="$1"
  local tab="$2"

  if [[ "$tab" == "overview" ]]; then
    echo "${device}-light"
  else
    echo "${device}-${tab}-light"
  fi
}

attachment_file_for_tab() {
  local manifest="$1"
  local tab="$2"

  awk -v expected="skyfig-${tab}-light_" '
    /"exportedFileName"/ {
      file = $0
      sub(/^.*"exportedFileName"[[:space:]]*:[[:space:]]*"/, "", file)
      sub(/".*$/, "", file)
    }
    /"suggestedHumanReadableName"/ && index($0, expected) {
      print file
      exit
    }
  ' "$manifest"
}

record_or_verify_snapshot() {
  local actual_snapshot="$1"
  local expected_snapshot="$2"
  local snapshot_name="$3"

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

capture_device() {
  local simulator="$1"
  local device="$2"
  local result_root
  result_root="$(mktemp -d /private/tmp/skyfig-consumer-snapshot-results.XXXXXX)"
  local result_bundle="$result_root/results.xcresult"
  local attachments_directory="$result_root/attachments"
  local manifest="$attachments_directory/manifest.json"

  prepare_simulator "$simulator"

  xcodebuild test \
    -project Examples/SkyfigConsumer/SkyfigConsumer.xcodeproj \
    -scheme SkyfigConsumer \
    -sdk iphonesimulator \
    -destination "platform=iOS Simulator,name=$simulator,OS=$simulator_os" \
    -derivedDataPath "$derived_data_path" \
    -only-testing:"$capture_test" \
    -resultBundlePath "$result_bundle" \
    -test-timeouts-enabled YES \
    -default-test-execution-time-allowance 60 \
    -maximum-test-execution-time-allowance 120 \
    ONLY_ACTIVE_ARCH=YES \
    CODE_SIGNING_ALLOWED=NO

  xcrun xcresulttool export attachments \
    --path "$result_bundle" \
    --output-path "$attachments_directory"

  for tab in "${snapshot_tabs[@]}"; do
    local exported_file
    exported_file="$(attachment_file_for_tab "$manifest" "$tab")"
    if [[ -z "$exported_file" || ! -f "$attachments_directory/$exported_file" ]]; then
      echo "Missing exported $tab attachment for $simulator in $manifest." >&2
      exit 1
    fi

    local snapshot_name
    snapshot_name="$(snapshot_name_for_tab "$device" "$tab")"
    record_or_verify_snapshot \
      "$attachments_directory/$exported_file" \
      "$snapshot_directory/${snapshot_name}.png" \
      "$snapshot_name"
  done
}

mkdir -p "$snapshot_directory"

if [[ "$target" == "all" || "$target" == "iphone" ]]; then
  capture_device "$iphone_simulator" "iphone"
fi

if [[ "$target" == "all" || "$target" == "ipad" ]]; then
  capture_device "$ipad_simulator" "ipad"
fi
