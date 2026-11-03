#!/usr/bin/env python3
"""Check a built APK for every fork change (disassembly-based, works after a dex rebuild).

Needs: pip install androguard loguru
Usage: verify_build.py BUILT.apk [--version-name S --version-code N]
Exits non-zero if any check fails.
"""
import re
import sys
import zipfile

from loguru import logger

logger.remove()
from androguard.core.apk import APK  # noqa: E402
from androguard.core.axml import AXMLPrinter  # noqa: E402
from androguard.core.dex import DEX  # noqa: E402

REPO = "https://github.com/PalpatineRex/ComicRackAndroid"


def method_ins(dex, cls, name, desc_part=""):
    for c in dex.get_classes():
        if c.get_name() == cls:
            for m in c.get_methods():
                if m.get_name() == name and desc_part in str(m.get_descriptor()) and m.get_code():
                    return [(i.get_name(), i.get_output()) for i in m.get_instructions()]
    return None


def main() -> None:
    args = sys.argv[1:]
    want_name = want_code = None
    if "--version-name" in args:
        want_name = args[args.index("--version-name") + 1]
    if "--version-code" in args:
        want_code = int(args[args.index("--version-code") + 1])
    path = args[0]
    apk = APK(path)
    z = zipfile.ZipFile(path)
    dex = DEX(z.read("classes.dex"))
    strings = {str(s) for s in dex.get_strings()}
    checks = []

    lvl = method_ins(dex, "Lcom/a/b/b/a/i;", "a", "Lcom/a/b/b/a/m;")
    checks.append(("license check bypassed (if-ne v0, v0)",
                   lvl is not None and any(n == "if-ne" and o.startswith("v0, v0,") for n, o in lvl)))
    eula = method_ins(dex, "Lcom/cyo/comicrack/viewer/id;", "run")
    checks.append(("EULA dialog skipped (if-ne v5, v5)",
                   eula is not None and any(n == "if-ne" and o.startswith("v5, v5,") for n, o in eula)))
    checks.append(("Help URL -> repo", f"{REPO}#readme" in strings))
    checks.append(("old documentation URL gone",
                   "http://comicrack.cyolito.com/documentation/comicrack-for-android" not in strings))
    about = z.read("res/raw/about.txt").decode("utf-8")
    checks.append(("About links: no cyolito.com", "cyolito.com" not in about))
    prefs = AXMLPrinter(z.read("res/xml/preferences_general.xml")).get_xml().decode()
    checks.append(("Settings 'Visit ComicRack' -> repo", f'android:data="{REPO}"' in prefs))
    checks.append(("targetSdk 25", apk.get_target_sdk_version() == "25"))
    if want_name:
        checks.append((f"versionName {want_name}", apk.get_androidversion_name() == want_name))
    if want_code:
        checks.append((f"versionCode {want_code}", apk.get_androidversion_code() == str(want_code)))
    checks.append(("classes count 1421", len(dex.get_classes()) == 1421))

    ok = True
    for label, passed in checks:
        print(("OK   " if passed else "FAIL ") + label)
        ok &= passed
    if not ok:
        raise SystemExit(1)
    print("all checks passed")


if __name__ == "__main__":
    main()
