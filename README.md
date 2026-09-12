# Debloat Chromecast with Google TV

A reversible, evidence-first project to turn a Chromecast with Google TV into a cleaner, **Projectivy + Stremio-centric** device without sacrificing Cast, remote control, Play Store, updates, DRM or core Android TV services.

## Target state

- Projectivy Launcher is the day-to-day Home UI.
- Stremio is prominent on Home.
- Native Stremio Android TV rows are exposed in Projectivy where the installed versions support them.
- Optional Stremio Channels rows provide discovery/trending content if useful.
- Google TV promotional clutter is no longer part of normal navigation.
- Only explicitly reviewed packages are disabled.
- Every package change is reversible.

> **Project policy:** use `pm disable-user --user 0`, not `pm uninstall --user 0`. The repository intentionally contains no device-specific `SAFE_DISABLE` entries until the real Chromecast inventory has been reviewed.

## Start here

Read these before touching the device:

1. [`docs/ACTION-PLAN.md`](docs/ACTION-PLAN.md) — complete staged execution plan and safety gates.
2. [`docs/VALIDATION.md`](docs/VALIDATION.md) — functional test matrix before/after changes.
3. [`config/packages.tsv`](config/packages.tsv) — package classification/allowlist.
4. [`docs/CODEX-EXECUTION-PROMPT.md`](docs/CODEX-EXECUTION-PROMPT.md) — ready-to-use prompt for Codex running locally on the computer that can reach the Chromecast.

## Local prerequisites

- Git
- Android platform-tools / `adb`
- computer and Chromecast reachable on the same LAN
- Developer options + ADB/Wireless debugging enabled on the Chromecast

## First execution

Clone the repository on the local machine, then connect ADB:

```bash
adb connect <CHROMECAST_IP>:5555
adb devices
```

Capture the baseline:

```bash
bash scripts/audit.sh
```

The audit creates an ignored `state/<timestamp>/` directory containing:

- model/build/fingerprint summary;
- complete/system/user package lists;
- enabled/disabled package lists;
- current HOME handler;
- Projectivy package details if installed;
- basic storage/memory diagnostics.

**Stop after the audit on the first run.** Review the inventory before changing package state.

## Package classifications

`config/packages.tsv` supports:

- `KEEP`
- `SAFE_DISABLE`
- `OPTIONAL_DISABLE`
- `DO_NOT_TOUCH`
- `UNKNOWN`

Only `SAFE_DISABLE` entries are acted on by the SAFE script.

Apply an approved safe batch:

```bash
bash scripts/apply-safe.sh
```

Rollback the last SAFE batch:

```bash
bash scripts/rollback.sh
```

## Launcher strategy

Projectivy is installed and validated **before debloating anything**. The stock Google TV launcher remains installed and enabled during the SAFE phase.

Projectivy upstream:

https://github.com/spocky/miproja1

Known Projectivy package name used by the project:

```text
com.spocky.projengmenu
```

## Stremio integration

The project favors Android TV channel integration instead of trying to recreate Google TV recommendations manually.

Planned order:

1. Stremio native rows exposed to Android TV / Projectivy, if present on the installed build.
2. Continue Watching / library-oriented rows where actually available.
3. Optional Stremio Channels for a small set of useful discovery rows.
4. Keep the number of rows intentionally low to avoid rebuilding a cluttered launcher.

Stremio Channels reference:

https://github.com/tedbigham/StremioChannels

Availability of specific Stremio rows must be verified on the actual device; the repository does not assume a fixed list.

## What is deliberately protected

Unless device-specific evidence proves otherwise, SAFE work must preserve:

- Google Play Services;
- Play Store;
- System UI;
- settings;
- package installer / permission controller;
- WebView;
- Bluetooth / remote stack;
- Cast receiver/services;
- DRM / MediaDrm;
- networking / captive portal components;
- OTA/system updater;
- stock launcher during the SAFE phase.

## Execution philosophy

This repository does **not** optimize for the maximum number of removed packages. It optimizes for a clean TV experience with minimal regression risk.

A package existing on the device is not evidence that disabling it improves performance.

## Recommended operator workflow

For the actual device-side work, launch Codex locally in this repository and give it the prompt from [`docs/CODEX-EXECUTION-PROMPT.md`](docs/CODEX-EXECUTION-PROMPT.md). That prompt forces an audit-first workflow, evidence-based package classification, manual approval before SAFE changes, and rollback on regression.
