#!/usr/bin/env python3
"""Disable the Google Play license check (LVL) in ComicRack for Android 1.80.

Applies 5 byte edits to classes.dex, fixes the dex header (adler32 + SHA-1),
and writes an UNSIGNED apk (old signature files removed). Sign it afterwards
(see tools/sign.sh). Standard library only.

The edits were derived by diffing the original 1.80 APK against the widely
circulated "cracked" 1.80 APK; applied to the original they reproduce that
classes.dex byte for byte (checked by tools/verify_patch.py).

The base APK is NOT part of this repository. It is verified by SHA-256 before
patching so we never patch (or publish) something unexpected.

Usage: patch_lvl.py BASE.apk OUT_UNSIGNED.apk
"""
import hashlib
import sys
import zlib
import zipfile

BASE_SHA256 = "15dc3d55bbefa792698ce84cd5e687e9beaf4364fbaef658fcd1c18c683d154b"

# (offset in classes.dex, expected old byte(s), new byte(s))
PATCHES = [
    (0x0C121A, bytes.fromhex("38"), bytes.fromhex("33")),
    (0x0C160C, bytes.fromhex("0a00"), bytes.fromhex("1210")),
    (0x0C190C, bytes.fromhex("18"), bytes.fromhex("0f")),
    (0x0C1910, bytes.fromhex("0f"), bytes.fromhex("18")),
    (0x0C1FB5, bytes.fromhex("10"), bytes.fromhex("00")),
]

SIGNATURE_ENTRIES = ("META-INF/MANIFEST.MF",)
SIGNATURE_SUFFIXES = (".SF", ".RSA", ".DSA", ".EC")


def patch_dex(dex: bytes) -> bytes:
    buf = bytearray(dex)
    for off, old, new in PATCHES:
        if bytes(buf[off:off + len(old)]) != old:
            raise SystemExit(f"unexpected bytes at 0x{off:x}: refusing to patch")
        buf[off:off + len(new)] = new
    # dex header: signature = SHA-1 of bytes[32:], checksum = adler32 of bytes[12:]
    buf[12:32] = hashlib.sha1(bytes(buf[32:])).digest()
    buf[8:12] = (zlib.adler32(bytes(buf[12:])) & 0xFFFFFFFF).to_bytes(4, "little")
    return bytes(buf)


def is_signature_entry(name: str) -> bool:
    if name in SIGNATURE_ENTRIES:
        return True
    return name.startswith("META-INF/") and name.endswith(SIGNATURE_SUFFIXES)


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    src, dst = sys.argv[1], sys.argv[2]
    digest = hashlib.sha256(open(src, "rb").read()).hexdigest()
    if digest != BASE_SHA256:
        raise SystemExit(f"base APK SHA-256 mismatch:\n  got      {digest}\n  expected {BASE_SHA256}")
    with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w") as zout:
        for info in zin.infolist():
            if is_signature_entry(info.filename):
                continue
            data = zin.read(info.filename)
            if info.filename == "classes.dex":
                data = patch_dex(data)
            out = zipfile.ZipInfo(info.filename, date_time=info.date_time)
            out.compress_type = info.compress_type
            out.external_attr = info.external_attr
            zout.writestr(out, data)
    print("wrote", dst)


if __name__ == "__main__":
    main()
