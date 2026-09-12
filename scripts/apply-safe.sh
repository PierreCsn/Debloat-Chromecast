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

config="config/packages.tsv"
if [[ ! -f "$config" ]]; then
  echo "ERROR: missing $config" >&2
  exit 1
fi

stamp="$(date +%Y%m%d-%H%M%S)"
out="state/${stamp}-safe"
mkdir -p "$out"

adb shell pm list packages -d > "$out/disabled-before.txt"
adb shell pm list packages -e > "$out/enabled-before.txt"
: > "$out/attempted.tsv"

count=0
while IFS=$'\t' read -r package classification notes; do
  [[ -z "${package:-}" ]] && continue
  [[ "$package" == \#* ]] && continue
  [[ "${classification:-}" != "SAFE_DISABLE" ]] && continue

  if ! adb shell pm path "$package" >/dev/null 2>&1; then
    printf '%s\t%s\t%s\n' "$package" "SKIPPED_NOT_INSTALLED" "${notes:-}" >> "$out/attempted.tsv"
    continue
  fi

  result="$(adb shell pm disable-user --user 0 "$package" 2>&1 | tr -d '\r')"
  printf '%s\t%s\t%s\n' "$package" "$result" "${notes:-}" >> "$out/attempted.tsv"
  count=$((count + 1))
done < "$config"

adb shell pm list packages -d > "$out/disabled-after.txt"
printf '%s\n' "$out" > state/LATEST_SAFE

echo "SAFE phase complete: $count package(s) requested for disable."
echo "Log: $out/attempted.tsv"
echo "Run the validation matrix before making any further change."
