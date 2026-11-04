# ComicRackAndroid

A maintained fork of the **ComicRack Android client** (cYo Soft, last release 1.80, 2014) that follows
[ComicRack Community Edition](https://github.com/maforget/ComicRackCE) (CE) on the desktop:
version **2.9.186 = CE 0.9.186**, with the CE features that make sense on Android ported to it.

**Status:** [latest release](../../releases/latest) (2.9.186; signed APK, about 7.8 MB because it
bundles the JPEG XL library). It runs on Android 13. Details, progress and known limits: [docs/PLAN.md](docs/PLAN.md).

## What changes compared to ComicRack 1.80

- Installs and runs on current Android: no Google Play license check (the store listing is gone),
  no "built for an older version of Android" warning, full screen on tall phones.
- No ads, no Twitter, no usage statistics: the opt-in popup is gone and nothing is ever sent. The
  dead ad and Twitter code and unused resources are removed too (smaller app; the Snapshot menu is
  Save / Share).
- Ported from CE: natural sort (2 before 10) for pages and library lists, accents and articles
  (The, Le, La, Les, L', Der, Die, Das) ignored when sorting series, `__MACOSX` / `._` files
  ignored inside archives, HEIC/HEIF (Android 9+) and AVIF (Android 12+) pages.
- Update check: once a day the app looks at this repository's releases and offers newer versions.
- The in-app History tab lists every change.

## Install

1. Download the `.apk` of the latest [release](../../releases/latest) on your phone and open it.
   Android asks you to allow installs from your browser or file manager the first time.
2. Start ComicRack and **allow access to files** when asked: the library reads your comics from
   storage. If you refused, grant it in *Settings > Apps > ComicRack > Permissions*.
3. Coming from ComicRack 1.80: uninstall it first only if Android refuses the install (different
   signature). Your comic files are not touched; the app's own library database is rebuilt.

Updates: when the app tells you a new version is available, tap *Update*: the browser downloads the
APK and Android installs it over the current one. Every release is signed with the same key;
its certificate SHA-256 fingerprint is
`fd4fd4789eaba18d9dbc2770f656a839d14a4ddc573f5b2918128519ac655f67` (CN=ComicRackAndroid).

## With ComicRack Community Edition

Wi-Fi sync with the CE desktop app uses the original protocol (unchanged in CE). Tested with CE
0.9.186 on Windows: CE finds the phone and pairs with it (Edit > Devices > Link device). A full
transfer has **not been tested yet**; reports are welcome in the [issues](../../issues).

## Known limits

- **RAR5** CBR files open  through a one-time conversion: the first open of a big
  file is slow and the library scan is slower than with CBZ. Encrypted and multi-volume RAR5 are not
  supported.
- Continuous (webtoon) mode is a plain vertical strip you scroll, no page-turn animations. Tap zones
  (top/bottom of the screen), volume keys, double-tap and pinch zoom work (zoom checked on a phone by the
  maintainer). Off by default (Settings > Reading and display > Continuous mode).
- Metadata: ComicInfo.xml, ComicBook.xml and MetronInfo.xml are read (CE 0.9.185 mapping); the
  The Translator field is read and shown in the comic details; existing library entries get it when their file is rescanned.
- **JPEG XL** pages (.jxl, CE 0.9.184) are decoded by the bundled jxl-coder / libjxl library (Android 5+),
  which adds about 14 MB to the APK (arm64-v8a, armeabi-v7a, x86). Checked on an x86 emulator; the
  arm64 / armv7 builds of the same library are not run in my tests.
- Releases are checked on an Android 13 phone, not on every Android version.

## For maintainers

- Build: `python tools/build.py --base ComicRack.1.80.apk --ce-version 0.9.186 --apktool apktool_2.9.3.jar --key key.pem --cert cert.pem --out ComicRackAndroid.apk`
  (Python 3.10+, Java 8+, `pip install cryptography androguard loguru`). `verify_build.py` must pass.
- Release: push a tag like `2.9.187` (`2.9.187.1` for an Android-only fix);
  [`.github/workflows/release.yml`](.github/workflows/release.yml) builds, verifies, signs with the
  `SIGNING_KEY_PEM` / `SIGNING_CERT_PEM` secrets and publishes. A manual run is a dry run.
- New CE builds open an issue automatically ([`ce-watch.yml`](.github/workflows/ce-watch.yml)).
- How it works and what is ported: [docs/ANALYSIS.md](docs/ANALYSIS.md), [docs/PLAN.md](docs/PLAN.md).

## Ground rules

- **No third-party binaries in this repo.** The original app is closed source. The build downloads
  the base APK from its public release and checks its SHA-256; it is never committed here
  (`.gitignore` blocks `*.apk`, `*.dex`, keys).
- Patches are small, documented and checked by `tools/verify_build.py`; test-only code lives in
  `tests/` and is refused in release builds.

## Legal note

The original author (cYo, Markus Eisenstöck) has not been reachable for years and the app was pulled
from the stores. The Community Edition desktop client took the same decompile-and-continue approach.
This is still a grey area; if the author reappears and asks, the project will comply.
ComicRack is a trademark of cYo Soft.
