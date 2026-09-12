# Validation matrix

Run this matrix at three points:

- baseline before any modification;
- after Projectivy/Stremio integration;
- after every debloat batch.

Record PASS / FAIL / N/A and notes.

| Test | Baseline | Projectivy | SAFE debloat | Notes |
|---|---|---|---|---|
| Device boots normally | | | | |
| Projectivy opens from Home | N/A | | | |
| Home remains usable after reboot | | | | |
| Sleep and wake | | | | |
| D-pad navigation | | | | |
| Back/Home buttons | | | | |
| Volume control | | | | |
| Power / HDMI-CEC | | | | |
| Bluetooth remote reconnect | | | | |
| Wi-Fi reconnect | | | | |
| Settings app | | | | |
| Play Store opens | | | | |
| Install/update one test app | | | | |
| Google Cast device discovery | | | | |
| Cast video from phone | | | | |
| Stremio launches | | | | |
| Stremio playback | | | | |
| Stremio resume / Continue Watching | | | | |
| Projectivy Stremio rows populate | N/A | | | |
| Suggestion opens correct Stremio target | N/A | | | |
| DRM app(s) important to user | | | | |
| Voice/search, if retained | | | | |
| OTA/update screen remains accessible | | | | |

## Stop conditions

Rollback the last package batch if any of these regress unexpectedly:

- Home becomes unusable;
- remote cannot reconnect;
- networking is unstable;
- Cast disappears;
- Play Store / app installation fails;
- DRM playback breaks;
- Projectivy cannot recover after reboot;
- system settings become inaccessible.

Do not compensate for a regression by disabling more packages.
