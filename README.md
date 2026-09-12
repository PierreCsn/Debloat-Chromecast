# Debloat Chromecast with Google TV

Repository for a **reversible, evidence-first cleanup and launcher replacement** of a Chromecast with Google TV.

The target setup is:

- keep casting, Google Play Services, Play Store, updates, Bluetooth/remote and core Android TV services working;
- replace the visual home experience with **Projectivy Launcher**;
- surface **Stremio** content/channels on the launcher where supported;
- optionally add **Stremio Channels** for TMDB-backed rows that open titles in Stremio;
- remove or disable only packages that have been inventoried and explicitly approved;
- keep a complete rollback path.

> **Safety rule:** this project defaults to `pm disable-user --user 0`, not `pm uninstall --user 0`. No package is disabled until it has been classified from the actual device inventory.

## Upstream references

- Projectivy Launcher: https://github.com/spocky/miproja1
- Projectivy Play Store package: `com.spocky.projengmenu`
- Stremio Channels: https://github.com/tedbigham/StremioChannels

## Planned workflow

1. Capture device/build information and the complete package inventory.
2. Save current enabled/disabled package state for rollback.
3. Install and validate Projectivy without disabling the stock launcher.
4. Validate Home, reboot, sleep/wake, Cast, remote, Play Store and Stremio.
5. Enable Stremio/Android TV channels in Projectivy.
6. Optionally install Stremio Channels for additional recommendation rows.
7. Review the inventory and populate an explicit safe-disable allowlist.
8. Apply only the reviewed SAFE phase.
9. Re-run the validation matrix.
10. Consider optional/aggressive changes only if there is a measured benefit.

The detailed execution kit is prepared on a dedicated branch before any real device modification.
