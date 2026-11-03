#!/usr/bin/env python3
"""Fork-specific patches for ComicRack for Android 1.80 (run after patch_lvl.py).

1. Skip the first-run EULA dialog: in SplashActivity's EULA runnable
   (com.cyo.comicrack.viewer.id.run), the branch "if !eula.accepted -> show dialog"
   (`if-eqz v5`) becomes `if-ne v5, v5`, which is never taken, so the app always
   continues as if the EULA had been accepted. 4 bytes, same size.
2. About screen (res/raw/about.txt): links to the defunct comicrack.cyolito.com
   site are pointed to maintained pages. Only URLs are replaced; the text itself
   comes from the base APK at build time and is not stored in this repository.
3. Settings (res/xml/preferences_general.xml, binary XML): "Visit ComicRack" opens
   this repository; the dead Social (Twitter) section and the "Usage statistics"
   option are removed. The code reads those keys with getBoolean(key, default),
   so the defaults apply (usage statistics default: off).
4. History tab (res/raw/changes.txt): the fork's own release notes (FORK_CHANGES,
   written for this project) are prepended to the original history.
   Still pointing to the old site: the About dialog's "Help" button (URL stored in
   classes.dex; changing it needs a dex rebuild, see docs/PLAN.md).

Writes an UNSIGNED apk. Usage: patch_fork.py IN.apk OUT_UNSIGNED.apk
"""
import hashlib
import os
import sys
import zlib
import zipfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import axml  # noqa: E402

REPO = "https://github.com/PalpatineRex/ComicRackAndroid"
CE = "https://github.com/maforget/ComicRackCE"

# (offset in classes.dex, expected old bytes, new bytes) - offsets valid for the
# classes.dex produced by patch_lvl.py from the verified 1.80 base.
DEX_PATCHES = [
    (0x0EAC30, bytes.fromhex("38050600"), bytes.fromhex("33550600")),  # EULA check
]

# Longest first: the bare site URL is a prefix of the others.
ABOUT_LINKS = [
    ("http://comicrack.cyolito.com/documentation/comicrack-for-android", REPO + "#readme"),
    ("http://comicrack.cyolito.com/faqs/comicrack-android", REPO + "/issues"),
    ("http://comicrack.cyolito.com/forum", REPO + "/issues"),
    ('href="http://comicrack.cyolito.com"', 'href="' + CE + '"'),  # "ComicRack for Windows"
]


REMOVED_PREFERENCES = ["preference_category_general_social", "tracking_enabled"]

# Fork release notes, newest first. Same layout as the original changes.txt.
FORK_CHANGES = {
    "1.81": [
        "Community fork, maintained at github.com/PalpatineRex/ComicRackAndroid",
        'Targets Android 7.1: no more "built for an older version of Android" warning',
        "Uses the full screen on tall phones (no more empty band at the bottom)",
        "Removed the Google Play license check (the store listing no longer exists)",
        "Removed the first-run license agreement dialog",
        "Removed the dead Twitter and usage statistics options",
        "Links to the old website now point to the fork (Settings, About, Help)",
    ],
}


def history_header() -> bytes:
    lines = []
    for version, items in FORK_CHANGES.items():
        lines.append(f"V{version}:")
        lines.append("")
        lines += ["• " + item for item in items]
        lines.append("")
    return ("\r\n".join(lines) + "\r\n").encode("utf-8")


def is_signature_entry(name: str) -> bool:
    return name == "META-INF/MANIFEST.MF" or (
        name.startswith("META-INF/") and name.endswith((".SF", ".RSA", ".DSA", ".EC"))
    )


def patch_dex(dex: bytes) -> bytes:
    buf = bytearray(dex)
    for off, old, new in DEX_PATCHES:
        if bytes(buf[off:off + len(old)]) != old:
            raise SystemExit(f"unexpected dex bytes at 0x{off:x} (run patch_lvl.py first?)")
        buf[off:off + len(new)] = new
    buf[12:32] = hashlib.sha1(bytes(buf[32:])).digest()
    buf[8:12] = (zlib.adler32(bytes(buf[12:])) & 0xFFFFFFFF).to_bytes(4, "little")
    return bytes(buf)


def patch_about(raw: bytes) -> bytes:
    text = raw.decode("utf-8")
    for old, new in ABOUT_LINKS:
        if old not in text:
            raise SystemExit(f"about.txt: expected link not found: {old}")
        text = text.replace(old, new)
    if "cyolito.com" in text:
        raise SystemExit("about.txt: cyolito.com link left after patching")
    return text.encode("utf-8")


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    src, dst = sys.argv[1], sys.argv[2]
    with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w") as zout:
        for info in zin.infolist():
            if is_signature_entry(info.filename):
                continue
            data = zin.read(info.filename)
            if info.filename == "classes.dex":
                data = patch_dex(data)
                print("classes.dex: EULA dialog disabled")
            elif info.filename == "res/raw/about.txt":
                data = patch_about(data)
                print("about.txt: links replaced")
            elif info.filename == "res/xml/preferences_general.xml":
                data = axml.replace_strings(data, {"http://comicrack.cyolito.com": REPO})
                data = axml.remove_elements(data, REMOVED_PREFERENCES)
                print("preferences_general.xml: 'Visit ComicRack' -> repo, Twitter/statistics removed")
            elif info.filename == "res/raw/changes.txt":
                if not data.startswith(b"V1.80:"):
                    raise SystemExit("changes.txt: unexpected start, refusing to patch")
                data = history_header() + data
                print("changes.txt: fork release notes added")
            out = zipfile.ZipInfo(info.filename, date_time=info.date_time)
            out.compress_type = info.compress_type
            out.external_attr = info.external_attr
            zout.writestr(out, data)
    print("wrote", dst)


if __name__ == "__main__":
    main()
