#!/usr/bin/env python3
"""Change targetSdkVersion in the binary AndroidManifest.xml of an APK.

Same-size in-place edit of the attribute value (no structure change), standard
library only. The output keeps every other entry and drops the old signature,
so sign it afterwards (tools/sign_v1.py or tools/sign.sh).

Why 25 by default for ComicRack 1.80 (was 21):
  * >= 23 removes Android's "built for an older version of Android" warning
    (and the Android 14 install block).
  * >= 24 makes activities resizeable by default, which removes the 1.86 max
    aspect-ratio letterbox (empty band at the bottom on tall phones).
  * < 26 avoids the Android 8 background-service limits, which would break the
    Wi-Fi sync service started at boot.
  Side effect of >= 23: storage permission is a runtime permission. Upgrading an
  install that already had it keeps it; a fresh install must grant it in
  Settings > Apps > ComicRack > Permissions until the app asks for it itself.

Usage: patch_manifest.py IN.apk OUT_UNSIGNED.apk [--target-sdk N]
"""
import struct
import sys
import zipfile

TARGET_SDK_ATTR = 0x01010270  # android:targetSdkVersion
TYPE_INT_DEC = 0x10
TYPE_INT_HEX = 0x11
RES_XML_RESOURCE_MAP_TYPE = 0x0180
RES_XML_START_ELEMENT_TYPE = 0x0102


def is_signature_entry(name: str) -> bool:
    return name == "META-INF/MANIFEST.MF" or (
        name.startswith("META-INF/") and name.endswith((".SF", ".RSA", ".DSA", ".EC"))
    )


def patch_axml(data: bytes, new_target: int) -> tuple[bytes, int]:
    buf = bytearray(data)
    xml_type, header_size, _total = struct.unpack_from("<HHI", buf, 0)
    if xml_type != 0x0003:
        raise SystemExit("not a binary XML file")
    pos = header_size
    res_ids: list[int] = []
    hits = []
    while pos < len(buf):
        ctype, chsize, csize = struct.unpack_from("<HHI", buf, pos)
        if csize == 0:
            break
        if ctype == RES_XML_RESOURCE_MAP_TYPE:
            n = (csize - chsize) // 4
            res_ids = list(struct.unpack_from(f"<{n}I", buf, pos + chsize))
        elif ctype == RES_XML_START_ELEMENT_TYPE:
            ext = pos + chsize  # ResXMLTree_attrExt
            attr_start, attr_size, attr_count = struct.unpack_from("<HHH", buf, ext + 8)
            for i in range(attr_count):
                a = ext + attr_start + i * attr_size
                name_idx = struct.unpack_from("<I", buf, a + 4)[0]
                if name_idx < len(res_ids) and res_ids[name_idx] == TARGET_SDK_ATTR:
                    data_type = buf[a + 15]
                    if data_type not in (TYPE_INT_DEC, TYPE_INT_HEX):
                        raise SystemExit(f"targetSdkVersion has unexpected type 0x{data_type:x}")
                    hits.append(a + 16)
        pos += csize
    if len(hits) != 1:
        raise SystemExit(f"expected exactly one targetSdkVersion attribute, found {len(hits)}")
    old = struct.unpack_from("<I", buf, hits[0])[0]
    struct.pack_into("<I", buf, hits[0], new_target)
    return bytes(buf), old


def main() -> None:
    args = sys.argv[1:]
    target = 25
    if "--target-sdk" in args:
        i = args.index("--target-sdk")
        target = int(args[i + 1])
        del args[i:i + 2]
    if len(args) != 2:
        raise SystemExit(__doc__)
    src, dst = args
    with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w") as zout:
        for info in zin.infolist():
            if is_signature_entry(info.filename):
                continue
            data = zin.read(info.filename)
            if info.filename == "AndroidManifest.xml":
                data, old = patch_axml(data, target)
                print(f"targetSdkVersion {old} -> {target}")
            out = zipfile.ZipInfo(info.filename, date_time=info.date_time)
            out.compress_type = info.compress_type
            out.external_attr = info.external_attr
            zout.writestr(out, data)
    print("wrote", dst)


if __name__ == "__main__":
    main()
