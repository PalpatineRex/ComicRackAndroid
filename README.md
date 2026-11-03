# ComicRackAndroid

A maintained fork of the **ComicRack Android client** (cYo Soft, last release 1.80, 2014) that follows
[ComicRack Community Edition](https://github.com/maforget/ComicRackCE): version 2.9.186 = CE 0.9.186,
with CE features ported to Android.

**Status: 2.9.186 builds and runs on Android 13 (test key). No release published yet.**
See [docs/PLAN.md](docs/PLAN.md).

## Goals

- Install on current Android (14+) without `--bypass-low-target-sdk-block`.
- Remove the dead Google Play license check (the Play Store listing is gone).
- Remove dead code: AdMob ads, Twitter integration.
- Keep Wi-Fi sync with ComicRack Community Edition working.
- Auto-update from this repository's GitHub releases.

## Ground rules

- **No third-party binaries in this repo.** The original app is closed source and was never released
  by its author. The build pipeline must fetch the base APK itself; it is never committed here
  (`.gitignore` blocks `*.apk`, `*.dex`, keystores).
- Analysis notes and tooling are in [docs/ANALYSIS.md](docs/ANALYSIS.md) and `tools/analysis/`.

## Legal note

The original author (cYo, Markus Eisenstöck) has not been reachable for years and the app was pulled
from the stores. The Community Edition desktop client took the same decompile-and-continue approach.
This is still a grey area; if the author reappears and asks, the project will comply.
