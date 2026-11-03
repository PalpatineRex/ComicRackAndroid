#!/usr/bin/env python3
"""Edit the binary AndroidManifest.xml of an APK: targetSdk and version.

Standard library only (uses tools/axml.py). Drops the old signature; sign the
output afterwards (tools/sign_v1.py or tools/sign.sh).

Why targetSdk 25 by default for ComicRack 1.80 (was 21):
  * >= 23 removes Android's "built for an older version of Android" warning
    (and the Android 14 install block).
  * >= 24 makes activities resizeable by default, which removes the 1.86 max
    aspect-ratio letterbox (empty band at the bottom on tall phones).
  * < 26 avoids the Android 8 background-service limits, which would break the
    Wi-Fi sync service started at boot.
  Side effect of >= 23: storage permission is a runtime permission. Upgrading an
  install that already had it keeps it; a fresh install must grant it in
  Settings > Apps > ComicRack > Permissions until the app asks for it itself.

Version: versionCode must grow with every release (Android refuses downgrades and
the auto-updater compares it). The About screen shows "versionName.versionCode".

Usage: patch_manifest.py IN.apk OUT_UNSIGNED.apk [--target-sdk N]
                         [--version-name S] [--version-code N]
"""
import os
import sys
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import axml  # noqa: E402

ATTR_TARGET_SDK = 0x01010270
ATTR_VERSION_CODE = 0x0101021B
BASE_VERSION_NAME = "1.80"


def is_signature_entry(name: str) -> bool:
    return name == "META-INF/MANIFEST.MF" or (
        name.startswith("META-INF/") and name.endswith((".SF", ".RSA", ".DSA", ".EC"))
    )


def take(args: list[str], flag: str, default):
    if flag in args:
        i = args.index(flag)
        value = args[i + 1]
        del args[i:i + 2]
        return type(default)(value) if default is not None else value
    return default


def main() -> None:
    args = sys.argv[1:]
    target = take(args, "--target-sdk", 25)
    version_name = take(args, "--version-name", None)
    version_code = take(args, "--version-code", 0)
    if len(args) != 2:
        raise SystemExit(__doc__)
    src, dst = args
    with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w") as zout:
        for info in zin.infolist():
            if is_signature_entry(info.filename):
                continue
            data = zin.read(info.filename)
            if info.filename == "AndroidManifest.xml":
                data, old = axml.set_int_attr(data, ATTR_TARGET_SDK, target)
                print(f"targetSdkVersion {old} -> {target}")
                if version_code:
                    data, old = axml.set_int_attr(data, ATTR_VERSION_CODE, version_code)
                    if version_code <= old:
                        raise SystemExit(f"versionCode must be > {old}")
                    print(f"versionCode {old} -> {version_code}")
                if version_name:
                    data = axml.replace_strings(data, {BASE_VERSION_NAME: version_name})
                    print(f"versionName {BASE_VERSION_NAME} -> {version_name}")
            out = zipfile.ZipInfo(info.filename, date_time=info.date_time)
            out.compress_type = info.compress_type
            out.external_attr = info.external_attr
            zout.writestr(out, data)
    print("wrote", dst)


if __name__ == "__main__":
    main()
