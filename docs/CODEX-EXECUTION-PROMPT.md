# Codex local execution prompt

Use this prompt from a local Codex session on the computer that can reach the Chromecast over ADB.

---

You are operating the repository `Debloat-Chromecast` on a machine on the same LAN as my Chromecast with Google TV.

Mission: prepare and execute a **reversible, evidence-first** cleanup and Projectivy/Stremio integration. Do not guess package roles and do not perform destructive Android package removal.

Rules:

1. Read `README.md`, `docs/ACTION-PLAN.md`, `docs/VALIDATION.md` and `config/packages.tsv` first.
2. Verify `adb` exists. If it does not, tell me the minimal installation command for this OS; do not install unrelated tooling.
3. Ask me only for the Chromecast IP if it cannot be discovered from the local environment. Do not guess it.
4. Connect with ADB and require an authorized `device` state before proceeding.
5. Run `bash scripts/audit.sh` and inspect the generated `state/<timestamp>/` inventory.
6. Report exact device model, Android/Google TV build, current HOME handler and whether Projectivy (`com.spocky.projengmenu`) is installed.
7. Before changing packages, inspect every proposed candidate using available package metadata (`pm path`, `dumpsys package`, intents/services/providers as useful) and reliable documentation when needed.
8. Update `config/packages.tsv` with evidence-based classifications. Keep uncertain packages as `UNKNOWN` or `DO_NOT_TOUCH`.
9. Preserve Google Play Services, Play Store, System UI, settings, package installer/permission controller, WebView, Bluetooth/remote stack, Cast components, DRM/MediaDrm, networking/captive portal, OTA updater and stock launcher during the SAFE phase unless device-specific evidence clearly requires otherwise.
10. Prefer normal Play Store installation for Projectivy and Stremio. Do not download APKs from random mirrors.
11. Configure/test Projectivy before any debloat. Keep the stock Google TV launcher enabled during the SAFE phase.
12. Discover which Stremio Android TV channels are actually exposed on this device and enable useful ones in Projectivy. Do not claim channels exist unless observed.
13. If desired and compatible, evaluate the official GitHub project `tedbigham/StremioChannels` for extra discovery rows. Verify release/source provenance before sideloading anything.
14. Show me the proposed `SAFE_DISABLE` list and rationale before running it. Do not create or execute an aggressive list in the same step.
15. Once the SAFE list is approved, run `bash scripts/apply-safe.sh`.
16. Execute the full matrix in `docs/VALIDATION.md` as far as automation allows. Clearly separate automated checks from tests that require me to use the TV/remote/phone.
17. If a regression appears, run `bash scripts/rollback.sh` before experimenting further.
18. Never use `pm uninstall --user 0` in this project unless I explicitly change the project policy in a later request.
19. Commit any repository changes with clear messages, but do not commit `state/` device dumps because they may contain device-specific identifiers.

Desired final state:

- Projectivy is the practical Home UI;
- Stremio is prominent and useful recommendation rows are visible where supported;
- Google TV promotional clutter is absent from normal navigation;
- Cast, remote, networking, Play Store, DRM and updates remain functional;
- every disabled package has a documented reason;
- rollback has been demonstrated.

Start with audit only. Do not disable packages until the inventory has been reviewed.

---
