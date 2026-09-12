# Action plan

## Goal

Turn a Chromecast with Google TV into a quieter, Stremio-centric Android TV device while preserving the platform features that matter: Cast, remote/Bluetooth, Play Store, Google Play Services, system updates, DRM and normal app launching.

## Principles

- Inventory first, change second.
- Prefer `disable-user` over uninstalling system packages.
- Change one class of components at a time.
- Never disable a package merely because its name looks promotional.
- Keep the stock launcher installed during the first validation pass.
- Every mutation must have a documented rollback.
- Do not automate an AGGRESSIVE phase until the real device inventory has been reviewed.

## Phase 0 — prerequisites

On the Chromecast:

1. Settings → System → About → click **Android TV OS build** repeatedly to enable Developer options.
2. Enable Developer options.
3. Enable USB debugging / Wireless debugging depending on the installed Google TV version.
4. Note the Chromecast IP address.

On the local machine:

- Android platform-tools (`adb`) available in `PATH`.
- Chromecast and computer reachable on the same LAN.
- Git clone of this repository.

## Phase 1 — establish ADB and capture baseline

Run:

```bash
adb connect <CHROMECAST_IP>:5555
adb devices
./scripts/audit.sh
```

Expected output: a timestamped directory below `state/` containing build information and package inventories.

Do not continue until the device appears as `device`, not `unauthorized` or `offline`.

## Phase 2 — Projectivy before debloat

Install Projectivy using the Play Store on the Chromecast when possible. Current package name used by the project is:

```text
com.spocky.projengmenu
```

Configure Projectivy:

- launch it once;
- grant only the permissions it actually requests for launcher behavior;
- enable its launcher override / accessibility-based Home handling if required;
- configure startup/resume behavior;
- hide irrelevant applications from the Projectivy UI instead of disabling packages at this stage.

### Gate A

Before any package debloat, verify:

- Home opens Projectivy reliably;
- reboot returns to a usable launcher;
- sleep/wake works;
- remote navigation works;
- volume/power controls still work as expected;
- Cast receiver still works;
- Play Store can install/update an app;
- Stremio launches and plays known-good content;
- DRM-dependent apps that matter to the user still launch.

If Projectivy is unreliable, stop here. Do **not** compensate by disabling random Google components.

## Phase 3 — Stremio-centric home

### Native Stremio channels

In Projectivy, inspect available Android TV channels and enable Stremio rows exposed by the installed Stremio build, such as Continue Watching or library-oriented rows when available.

Channel availability depends on the versions of Stremio, Android TV/Google TV and Projectivy. Treat this as capability discovery, not a guaranteed fixed set.

### Optional Stremio Channels

Reference project:

https://github.com/tedbigham/StremioChannels

Use it only after Projectivy + Stremio are stable. It can provide additional Android TV recommendation rows backed by TMDB-style discovery and deep-link/open into Stremio.

Suggested initial rows:

1. Continue Watching — native Stremio if exposed.
2. Library / favorites — native Stremio if exposed.
3. Trending this week — Stremio Channels.
4. One or two useful genres only.
5. Applications row at the bottom.

Avoid recreating the clutter being removed from Google TV.

### Gate B

- thumbnails load consistently;
- selecting a suggestion opens the expected title/search in Stremio;
- launcher remains responsive after reboot;
- no recommendation component is required for basic Stremio usage.

## Phase 4 — classify packages from the real inventory

Run `./scripts/audit.sh` again after Projectivy/Stremio are installed.

For each candidate package, classify it in `config/packages.tsv` as one of:

- `KEEP` — required or intentionally retained;
- `SAFE_DISABLE` — approved for the first reversible debloat pass;
- `OPTIONAL_DISABLE` — possibly useful but not needed initially;
- `DO_NOT_TOUCH` — core platform dependency or too risky/uncertain;
- `UNKNOWN` — default state until researched.

The repository intentionally ships with **no device-specific SAFE_DISABLE entries**.

### Components that should normally remain untouched

Unless there is model/version-specific evidence proving otherwise, preserve:

- Google Play Services and Play Store;
- package installer / permission controller;
- System UI;
- Android framework providers;
- WebView;
- Bluetooth stack / remote-related packages;
- Cast receiver/service components;
- DRM / MediaDrm components;
- network and captive portal services;
- system updater / OTA components;
- settings;
- input method needed for setup/search;
- the stock launcher package during the initial safe phase.

## Phase 5 — SAFE debloat

Populate `config/packages.tsv` only after review, then run:

```bash
./scripts/apply-safe.sh
```

The script disables only rows explicitly marked `SAFE_DISABLE` and records what it attempted.

### Gate C — mandatory validation

Repeat all Gate A tests plus:

- settings opens;
- Wi-Fi remains stable;
- Bluetooth remote reconnects after reboot;
- voice/search works if you intend to retain it;
- HDMI-CEC behavior remains acceptable;
- app updates continue working;
- Cast discovery works from a phone on the LAN;
- Stremio playback is stable;
- Projectivy rows repopulate normally.

Keep the device in this state for normal usage before contemplating further changes.

## Phase 6 — optional/aggressive changes

Only create an aggressive allowlist after observing an actual reason to do so: measurable memory pressure, persistent background activity, unwanted UI takeover, or unwanted service behavior.

Never equate "package exists" with "package harms performance".

The aggressive phase should remain a separate explicit command/PR and should never run as part of the SAFE script.

Disabling the stock Google TV launcher is considered an optional/aggressive step, not a prerequisite for this project. Projectivy should first be validated while the stock launcher remains installed and enabled.

## Rollback

Fast rollback of project-managed package changes:

```bash
./scripts/rollback.sh
```

If Home becomes unusable but ADB still works, explicitly re-enable the stock launcher package identified from the device inventory and reboot.

If ADB access itself is lost, use Android TV settings/recovery paths available on the device. Factory reset is the last resort, not the normal rollback mechanism.

## Definition of done

The project is successful when:

- Projectivy is the practical day-to-day home screen;
- Stremio content/suggestions are visible where supported;
- unwanted Google TV promotional clutter is no longer part of normal navigation;
- Cast, remote, Play Store, OTA, DRM and networking still function;
- every disabled package is documented;
- rollback has been tested;
- there is no unexplained package removal.
