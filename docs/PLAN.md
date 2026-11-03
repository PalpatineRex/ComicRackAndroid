# Plan

Everything below is a plan, not a result. Items marked (?) are hypotheses to test.

## Approach

Decompiling to Java and rebuilding a Gradle project is unlikely to work: the code is ProGuard-obfuscated
and decompiler output rarely recompiles. Preferred approach: **patch the original APK at smali level in CI**
(apktool decode, patch, rebuild, zipalign, sign with our own key), running on GitHub Actions
because the tooling cannot be downloaded in the author's current sandbox.

The base APK is never stored in this repo. CI downloads it from the public release of
`maforget/ComicRackKeygen` and **verifies the SHA-256** listed in docs/ANALYSIS.md before patching.

## Milestones

### M1 - Reproducible patched build
- CI workflow: download base APK, check hash, apktool decode, apply patches, rebuild, sign, upload artifact.
- Patches: remove the LVL check and `CHECK_LICENSE`; new signing key (stored as an Actions secret);
  versionName suffix so it is distinguishable from 1.80.
- Exit criterion: an APK installs on a real device and opens the library.

### M2 - Modern Android install
- Raise targetSdk to at least 23 so Android 14 installs it normally (consistent with the
  `--bypass-low-target-sdk-block` requirement in the maforget release notes).
- Risk: targetSdk >= 23 means runtime permissions. The app does not request them today, so code
  must be added (smali) to ask for storage access (?). Android 11+ may need "all files access" for
  comic files (?). Must be tested on the target phone before choosing the final targetSdk.

### M3 - Auto-update
- App checks the GitHub Releases API of this repo, compares versionCode, downloads the APK and hands it
  to the system installer (needs `REQUEST_INSTALL_PACKAGES`).
- Stopgap needing no code: Obtainium pointed at this repo's releases.
- Requires the same signing key on every release.

### M4 - Cleanup
- Remove AdMob and twitter4j (dead network code).
- Test Wi-Fi sync against ComicRack Community Edition on a real device and PC.
