# Plan

Goal: port ComicRack Community Edition to Android. The app follows CE's builds:
CE `0.9.186` = Android `2.9.186`, and CE features that make sense on Android are ported.
Items marked (?) are hypotheses still to test.

## Approach

Patch the original APK instead of decompiling to Java: the code is ProGuard-obfuscated and
decompiler output rarely recompiles. Byte patches where the size does not change, a smali
round-trip (apktool) for everything else, our own classes in `tools/smali/`. The base APK is
never stored in this repo; the build fetches it and **verifies its SHA-256** (`tools/patch_lvl.py`).

Distribution (not started): signed APKs as GitHub Releases of this repository, polled by the
app for updates. Nothing has been published yet.

## Versioning

`tools/patch_manifest.py --ce-version X.Y.Z [--rev N]`:
versionName `(X+2).Y.Z[.N]`, versionCode `X*10^7 + Y*10^5 + Z*100 + N` (CE 0.9.186 -> 2.9.186 / 918600).
`--rev` is for an Android-only fix between two CE builds. `ce-version.txt` = CE build the fork is at.

## Build (run on the maintainer's PC; CI to come)

    python tools/build.py --base ComicRack.1.80.apk --ce-version 0.9.186 \
        --apktool apktool_2.9.3.jar --key key.pem --cert cert.pem --out ComicRackAndroid.apk

Chain: `patch_lvl` (license check, identical to the circulating crack) -> `patch_fork` (EULA,
links, Settings cleanup, History notes) -> `patch_manifest` (targetSdk 25, version) ->
`patch_smali` (code changes, ported CE features) -> `verify_build` (every change checked by
disassembly; nothing is signed if a check fails) -> `sign_v1`.
Needs Python 3.10+, Java 8+, `pip install cryptography androguard loguru`, apktool 2.9.3.

## Status

### Done, tested on a Doogee V30 Pro (Android 13), build 2.9.186
- Starts and loads the library; no letterbox; no "older version of Android" warning.
- License check, EULA dialog, dead Twitter / usage-statistics options, dead FAQ / forum links removed.
- Links to the old site point to this repo (Settings, About, Help); About shows `2.9.186`.
- History tab starts with the fork's notes.
- Ported from CE, verified with `tests/fixtures/cra_test_pages.cbz` (pages shown 1, 2, 3, 10,
  junk files skipped): natural page order, `__MACOSX` / `._` files ignored, HEIC (Android 9+)
  and AVIF (Android 12+) pages.

### Following CE
- `.github/workflows/ce-watch.yml` runs daily and opens one issue per new CE build with its notes
  ("Port ComicRack CE X (Android 2.Y.Z)"). Dry run tested on GitHub.

### CE features still to port (Android-relevant)
- Go To page in the reader.
- Natural sort and French articles (Le, La, Les, L') for the library lists (pages are done).
- RAR5 (the app's RAR reader dates from 2014; to test with a RAR5 CBR).
- Continuous reading mode (webtoon / vertical strip).
- MetronInfo.xml / ComicBook.xml metadata, Translator field.

### Next
- Auto-update: app checks this repo's GitHub Releases, compares versionCode, downloads and hands the
  APK to the installer (`REQUEST_INSTALL_PACKAGES`). Every release must use the same key.
  Stopgap without code: Obtainium on this repo's releases.
- Real signing key, created and kept by the maintainer (never in the repo or a chat).
- CI release workflow (fetch base, build, verify, sign with secrets, publish) - maintainer's call.
- Test Wi-Fi sync against ComicRack CE on a real PC.
- Remove dead AdMob / twitter4j code.

### Later / only if needed - Android 14+
- Android 14 refuses targetSdk < 23 without `--bypass-low-target-sdk-block`; targetSdk is now 25,
  so this should be solved (?) - to test on an Android 14 device. Fresh installs must grant storage
  in Settings until the app requests it itself.
