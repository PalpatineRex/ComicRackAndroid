# Plan

Items marked (?) are hypotheses still to test.

## Approach

Patch the original APK directly instead of decompiling to Java: the code is ProGuard-obfuscated and
decompiler output rarely recompiles. The base APK is never stored in this repo; the pipeline fetches
it and **verifies its SHA-256** before touching it (see `tools/patch_lvl.py`).

Final distribution: signed APKs published as GitHub Releases of this repository, which the app itself
will poll for updates. Others can use this fork as a base.

## Milestones

### M1 - Patched, re-signed build (tools done and tested locally; CI not written yet)
- `tools/patch_lvl.py`: 5 byte edits to `classes.dex` + header fix. Output `classes.dex` is
  **byte-identical to the circulating cracked 1.80** (checked with `tools/verify_patch.py`).
- `tools/sign.sh`: v1 signature with the JDK's `jarsigner`; key comes from CI secrets, never from the repo.
- Still to do: GitHub Actions workflow (fetch base APK, verify hash, patch, sign, publish release),
  and a one-time real signing key created by the maintainer.
- Not yet tested on a device. Note: the license-check bypass only neutralises the check; the
  `CHECK_LICENSE` permission is still declared.

### M2 - Auto-update
- App checks the GitHub Releases API of this repo, compares versionCode, downloads the APK and hands it
  to the system installer (needs `REQUEST_INSTALL_PACKAGES`).
- Needs a code change in the app (smali). Every release must be signed with the same key.
- Stopgap needing no code: Obtainium pointed at this repo's releases.

### M3 - Cleanup
- Remove AdMob and twitter4j (dead network code).
- Test Wi-Fi sync against ComicRack Community Edition on a real device and PC.

### Later / only if needed - Android 14+
- Android 14 refuses to install apps with targetSdk < 23 without `--bypass-low-target-sdk-block`.
  Raising targetSdk means adding runtime storage-permission handling (?) and possibly "all files access"
  on Android 11+ (?). Deferred: Android 13 and older install the current build normally.
