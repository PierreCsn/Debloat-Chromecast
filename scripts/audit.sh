#!/usr/bin/env bash
set -euo pipefail

if ! command -v adb >/dev/null 2>&1; then
  echo "ERROR: adb is not installed or not in PATH." >&2
  exit 1
fi

if ! adb get-state >/dev/null 2>&1; then
  echo "ERROR: no authorized ADB device is selected. Connect first with: adb connect <IP>:5555" >&2
  exit 1
fi

stamp="$(date +%Y%m%d-%H%M%S)"
out="state/${stamp}"
mkdir -p "$out"

echo "Capturing baseline into $out"

adb shell getprop > "$out/getprop.txt"
adb shell pm list packages > "$out/packages-all.txt"
adb shell pm list packages -s > "$out/packages-system.txt"
adb shell pm list packages -3 > "$out/packages-user.txt"
adb shell pm list packages -d > "$out/packages-disabled.txt"
adb shell pm list packages -e > "$out/packages-enabled.txt"
adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME > "$out/home-handler.txt" || true
adb shell dumpsys package com.spocky.projengmenu > "$out/projectivy-package.txt" || true
adb shell dumpsys activity activities > "$out/activity.txt" || true
adb shell df -h > "$out/df.txt" || true
adb shell dumpsys meminfo > "$out/meminfo.txt" || true

{
  echo "captured_at=$(date -Iseconds)"
  echo "adb_serial=$(adb get-serialno)"
  echo "model=$(adb shell getprop ro.product.model | tr -d '\r')"
  echo "device=$(adb shell getprop ro.product.device | tr -d '\r')"
  echo "android=$(adb shell getprop ro.build.version.release | tr -d '\r')"
  echo "sdk=$(adb shell getprop ro.build.version.sdk | tr -d '\r')"
  echo "fingerprint=$(adb shell getprop ro.build.fingerprint | tr -d '\r')"
} > "$out/summary.txt"

printf '%s\n' "$out" > state/LATEST

echo "Audit complete. Review $out before changing any package state."
