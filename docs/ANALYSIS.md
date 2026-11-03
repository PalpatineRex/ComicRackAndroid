# Analysis of ComicRack for Android 1.80

Static analysis only (nothing was installed or executed). Date: 2026-11-03.
Tools: `tools/analysis/*.py` (androguard 4.1.4, `pip install androguard loguru`).

## Inputs

| File | SHA-256 |
|------|---------|
| `ComicRack.1.80.apk` (original, signed by cYo Soft) | `15dc3d55bbefa792698ce84cd5e687e9beaf4364fbaef658fcd1c18c683d154b` |
| `ComicRack.1.80.Cracked.apk` | `930572201289fdbecca4a8deeebc7658d5cd989184c50b237c4a72bbb0663dd8` |

Both are published as assets of the release `1.0` of `maforget/ComicRackKeygen`.

## App structure (verified)

- Package `com.cyo.comicrack.viewer`, versionName 1.80, versionCode 103.
- minSdk 8, **targetSdk 21**. Plain Java: a single `classes.dex`, no native libs, no .NET assemblies.
- 1421 classes. Application package has 294 classes, **263 of them ProGuard-renamed (1-2 letters)**.
  Classes referenced by the manifest keep their names: `LibraryActivity`, `ReaderActivity`,
  `ComicListActivity`, `ComicDetailsActivity`, `WifiSyncService`, widget providers,
  `CoverWallpaperService`, `ComicRackPreferencesActivity`.
- Bundled libraries: Google License Verification Library (`com.a.b.b.a.*`, obfuscated), AdMob SDK
  (`com.a.a.*`, URLs to admob.com present), `twitter4j` (140 classes, API v1.1), support-v4.
- Permissions: INTERNET, ACCESS_NETWORK_STATE, READ/WRITE_EXTERNAL_STORAGE, RECEIVE_BOOT_COMPLETED,
  WAKE_LOCK, `com.android.vending.CHECK_LICENSE`.
- Signature: v1 only. Original cert O=cYo Soft; cracked APK uses the standard Android debug cert.

## Original vs cracked (verified)

Only **3 of 1421 classes differ**, all in the Google LVL: `com.a.b.b.a.i`, `.l`, `.t`.
In `i.a(m)` a conditional branch (`if-eqz`) became `if-ne v0, v0` (always taken), i.e. a
one-instruction patch of the license check. Classes `l` and `t` also differ; only `i` was read in detail.
Resources and manifest are identical apart from signing.

At byte level the whole difference is **5 edits in `classes.dex`** (offsets 0x0C121A, 0x0C160C, 0x0C190C,
0x0C1910, 0x0C1FB5) plus the dex header checksum/SHA-1. `tools/patch_lvl.py` applies exactly those
edits to the original; the resulting `classes.dex` has the same SHA-256 as the cracked one
(`922c93a2...aaf30`).

## Desktop side of Wi-Fi sync (from ComicRackCE, commit 7a3ab2e, 2026-10-23)

Source: `ComicRack.Engine/Sync/` in `maforget/ComicRackCE`.

- Discovery: multicast group `224.34.123.90`; UDP listen port 7615; client port 7614; server control
  ports start at 7620.
- 14 commands over TCP: list files, read file, free space, file exists, delete, write, start,
  completed, progress, info, read multi-file, check abort, client pong, server available.
- `DeviceInfo` requires `Hash == SHA1(Model + Manufacturer + SerialNumber + Edition + Version)` and
  rejects the device otherwise (`InvalidDataException`).
- `ValidateWifi`: edition must be `Android Full` (or iOS); `Android Free` and unknown editions are
  refused. The signing-key comparison is present but followed by an unconditional `flag = true`,
  so on the CE the key check is effectively bypassed. **Not tested on a real device.**

Consequence for the fork: keep the existing sync client code unchanged, keep reporting edition
`Android Full` and the same hash scheme.

## Not analysed yet

- Content of the sync client classes (obfuscated), exact bytes sent for `Info`/`Hash`.
- Classes `l` and `t` of the LVL diff.
- Storage access code (needed for the targetSdk decision, see PLAN.md).
- Whether the ComicRackCE wiki's Android page documents anything beyond installation.
