#!/usr/bin/env bash
set -euo pipefail

if ! command -v adb >/dev/null 2>&1; then
  echo "ERROR: adb is not installed or not in PATH." >&2
  exit 1
fi

if ! adb get-state >/dev/null 2>&1; then
  echo "ERROR: no authorized ADB device is selected." >&2
  exit 1
fi

latest_file="state/LATEST_SAFE"
if [[ ! -f "$latest_file" ]]; then
  echo "ERROR: no SAFE run recorded in $latest_file" >&2
  exit 1
fi

run_dir="$(cat "$latest_file")"
log="$run_dir/attempted.tsv"

if [[ ! -f "$log" ]]; then
  echo "ERROR: missing rollback log: $log" >&2
  exit 1
fi

while IFS=$'\t' read -r package result notes; do
  [[ -z "${package:-}" ]] && continue
  case "$result" in
    *disabled-user*|*new\ state:\ disabled-user*|*disabled*)
      echo "Re-enabling $package"
      adb shell pm enable --user 0 "$package" || adb shell pm enable "$package" || true
      ;;
    *)
      echo "Skipping $package; SAFE log does not show a successful disable."
      ;;
  esac
done < "$log"

echo "Rollback requests complete. Reboot the Chromecast and run the validation matrix."
