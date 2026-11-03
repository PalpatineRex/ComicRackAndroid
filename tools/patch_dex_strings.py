#!/usr/bin/env python3
"""Replace string constants in classes.dex via a smali round-trip (apktool).

Byte patches cannot change a string's length (dex string ids are sorted and
offset-linked), so this step disassembles classes.dex with apktool (which
bundles smali/baksmali), edits exact `const-string` lines, reassembles, and puts
the new classes.dex back into the input APK. Everything else in the APK is kept
as is. Run it after the byte patches (patch_lvl.py, patch_fork.py).

Needs Java and apktool's jar (tested: apktool 2.9.3 on Java 8).

Usage: patch_dex_strings.py IN.apk OUT_UNSIGNED.apk --apktool apktool.jar
"""
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

REPO = "https://github.com/PalpatineRex/ComicRackAndroid"

# (smali file, exact old line, new line). Each old line must occur exactly once.
EDITS = [
    # About dialog "Help" button (ComicRackApplication.c, read by viewer.b.onClick)
    ("smali/com/cyo/comicrack/viewer/ComicRackApplication.smali",
     'const-string v0, "http://comicrack.cyolito.com/documentation/comicrack-for-android"',
     f'const-string v0, "{REPO}#readme"'),
]


def is_signature_entry(name: str) -> bool:
    return name == "META-INF/MANIFEST.MF" or (
        name.startswith("META-INF/") and name.endswith((".SF", ".RSA", ".DSA", ".EC"))
    )


def run(cmd: list[str]) -> None:
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit(f"command failed: {' '.join(cmd)}")


def main() -> None:
    args = sys.argv[1:]
    if "--apktool" not in args:
        raise SystemExit(__doc__)
    i = args.index("--apktool")
    jar = args[i + 1]
    del args[i:i + 2]
    if len(args) != 2:
        raise SystemExit(__doc__)
    src, dst = args

    tmp = tempfile.mkdtemp(prefix="cra_smali_")
    try:
        work = os.path.join(tmp, "src")
        run(["java", "-jar", jar, "d", "-r", "-f", "-o", work, src])
        for rel, old, new in EDITS:
            path = os.path.join(work, rel)
            with open(path, encoding="utf-8") as f:
                text = f.read()
            hits = text.count(old)
            if hits != 1:
                raise SystemExit(f"{rel}: expected 1 occurrence, found {hits}: {old}")
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                f.write(text.replace(old, new))
            print("edited", rel)
        built = os.path.join(tmp, "built.apk")
        run(["java", "-jar", jar, "b", "-o", built, work])
        with zipfile.ZipFile(built) as zb:
            new_dex = zb.read("classes.dex")
        with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w") as zout:
            for info in zin.infolist():
                if is_signature_entry(info.filename):
                    continue
                data = new_dex if info.filename == "classes.dex" else zin.read(info.filename)
                out = zipfile.ZipInfo(info.filename, date_time=info.date_time)
                out.compress_type = info.compress_type
                out.external_attr = info.external_attr
                zout.writestr(out, data)
        print("wrote", dst)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
