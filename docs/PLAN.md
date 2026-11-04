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
- Library sort: natural numbers, accents ignored, articles the/der/die/das + le/la/les/l' ignored
  (verified on the phone with `tests/smali/cra/test/SortTest.smali` run through app_process).

### Following CE
- `.github/workflows/ce-watch.yml` runs daily and opens one issue per new CE build with its notes
  ("Port ComicRack CE X (Android 2.Y.Z)"). Dry run tested on GitHub.

### CE features still to port (Android-relevant)
- Go To page in the reader.
- RAR5 (the app's RAR reader dates from 2014; to test with a RAR5 CBR).
- Continuous reading mode (webtoon / vertical strip).
- MetronInfo.xml / ComicBook.xml metadata, Translator field.

### Written, built and verified in CI (dry run), not yet run on a device
- Update check (`tools/smali/cra/fork/Updater.smali`, `UpdatePrompt.smali`): at most once a day when
  the library opens, reads `releases/latest` of this repo; tag `2.9.187` / `v2.9.187.1` -> versionCode
  with the build formula; if newer, "Version X is available. Update now?" -> opens the release's `.apk`
  asset in the browser (download + system installer). No release / no network = nothing happens.
  Release rules: tag = versionName, one `.apk` asset, same signing key every time.
- Usage statistics removed: opt-in popup never shown, app and Google Analytics flags forced off,
  GA host replaced by `analytics.invalid`.
- Storage permission asked on first start (`cra/fork/Perms.smali`), library restarts on grant.
- Release workflow `.github/workflows/release.yml`: dry run on GitHub OK (2026-11-03, all checks).
- On-device checks: `tools/device_test.ps1` (app_process tests + optional test build that sees a
  fake 2.9.999 release from `tests/fixtures/fake_release.json`).

### Next
- Real signing key, created and kept by the maintainer (never in the repo or a chat).
- CI release workflow (fetch base, build, verify, sign with secrets, publish) - maintainer's call.
- Test Wi-Fi sync against ComicRack CE on a real PC.
- Dead code removed (2026-11-04, 376 classes: AdMob `com/a/a`, twitter4j, the app's Twitter module
  `com/cyo/common/b/a/*`, 5 listener / dialog classes). Done in `tools/patch_smali.py` (`CUTS`, `STUBS`,
  `DELETE`); the build stops if any remaining code still names a deleted class, and `verify_build.py`
  re-checks it on the final APK. What changed for the user: the reader's Snapshot menu is
  Save / Share (no Tweet), the rating dialog only saves the rating, no ad / Twitter code or keys are left.
  Checked on a Doogee V30 Pro (Android 13): library, reader and page turns, Snapshot menu (Share), rating
  dialog (saved and reverted), settings, no crash in logcat.
  - Google Analytics (`com/a/b/a`) cannot be removed: `com/a/b/a/a/a/m` is a superclass of every activity.
    It is neutralised instead (flags forced off, host `analytics.invalid`).
  - Unused resources (16 strings incl. Twitter / tracking / ad texts, 6 drawables, 1 layout) are pruned by
    `tools/prune_res.py`: the original binary XML files are kept, only `resources.arsc` is rebuilt (apktool /
    aapt2) with ids pinned; the build checks that all remaining ids are unchanged. The hidden Twitter
    checkbox of the rating dialog is gone too (layout, lookup code, `cr` / `ch` listeners).

### Later / only if needed - Android 14+
- Android 14 refuses targetSdk < 23 without `--bypass-low-target-sdk-block`; targetSdk is now 25,
  so this should be solved (?) - to test on an Android 14 device. Fresh installs must grant storage
  in Settings until the app requests it itself.
