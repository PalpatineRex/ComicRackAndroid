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
    rating = method_ins(dex, "Lcom/cyo/comicrack/viewer/ComicRackApplication;", "a",
                        "Lcom/cyo/comicrack/a/b/h; Z Ljava/lang/Runnable;") or []
    checks.append(("Rating dialog: Twitter checkbox always unchecked and hidden",
                   any(n.startswith("invoke-virtual") and o.startswith("v7, v5, Landroid/widget/CheckBox;->setChecked")
                       for n, o in rating)
                   and any(n == "if-ne" and o.startswith("v6, v6,") for n, o in rating)))
    checks.append(("Help URL -> repo", f"{REPO}#readme" in strings))
    checks.append(("old documentation URL gone",
                   "http://comicrack.cyolito.com/documentation/comicrack-for-android" not in strings))
    about = z.read("res/raw/about.txt").decode("utf-8")
    checks.append(("About links: no cyolito.com", "cyolito.com" not in about))
    checks.append(("About: FAQ and forum links removed", ">FAQ<" not in about and "Forum<" not in about))
    ver = method_ins(dex, "Lcom/cyo/comicrack/viewer/a;", "a", "Landroid/app/Activity; I")
    checks.append(("About shows versionName only (no versionCode)",
                   ver is not None and not any("Lcom/cyo/common/ag;->e(" in o for _, o in ver)))
    prefs = AXMLPrinter(z.read("res/xml/preferences_general.xml")).get_xml().decode()
    checks.append(("Settings 'Visit ComicRack' -> repo", f'android:data="{REPO}"' in prefs))
    checks.append(("Settings: Twitter and usage statistics removed",
                   all(k not in prefs for k in ("tweet_include_thumb", "general_twitter_reset",
                                                "tracking_enabled", "general_social"))))
    checks.append(("Settings: other options kept",
                   all(k in prefs for k in ("general_enable_wireless", "general_startup_open_last",
                                            "general_library_use_volumes", "visit_comicrack"))))
    changes = z.read("res/raw/changes.txt").decode("utf-8")
    first = changes.split("\r\n", 1)[0]
    checks.append((f"History starts with fork notes ({first})",
                   want_name is None or first == f"V{want_name}:"))
    checks.append(("History keeps original notes", "V1.80:" in changes))
    checks.append(("targetSdk 25", apk.get_target_sdk_version() == "25"))
    if want_name:
        checks.append((f"versionName {want_name}", apk.get_androidversion_name() == want_name))
    if want_code:
        checks.append((f"versionCode {want_code}", apk.get_androidversion_code() == str(want_code)))
    names = {c.get_name() for c in dex.get_classes()}
    checks.append(("classes: 1421 original + cra/fork/Natural",
                   len(names) == 1422 and "Lcra/fork/Natural;" in names))
    page_filter = method_ins(dex, "Lcom/cyo/comicrack/a/b/j;", "a", "(Ljava/lang/String;)Z") or []
    filter_strings = {o.split(", ", 1)[-1].strip('"') for n, o in page_filter if n.startswith("const-string")}
    checks.append(("CE: __MACOSX / AppleDouble files ignored in archives",
                   {"__macosx/", "/._", "._"} <= filter_strings))
    checks.append(("CE: HEIF/AVIF pages accepted (.heic .heif .avif)",
                   {".heic", ".heif", ".avif"} <= filter_strings))
    cmp_ = method_ins(dex, "Lcom/cyo/comicrack/a/a/ce;", "compareTo") or []
    bic = method_ins(dex, "Lcom/cyo/common/bi;", "c", "(Ljava/lang/String; Ljava/lang/String;)I") or []
    checks.append(("CE: natural library sort (bi.c -> Natural.compare)",
                   any("Lcra/fork/Natural;->compare(" in o for _, o in bic)
                   and not any("compareToIgnoreCase" in o for _, o in bic)))
    clinit = method_ins(dex, "Lcom/cyo/common/bi;", "<clinit>") or []
    arts = {o.split(", ", 1)[-1].strip('"') for n, o in clinit if n.startswith("const-string")}
    checks.append(("CE: French articles ignored when sorting (le, la, les, l')",
                   {"the ", "le ", "la ", "les ", "l'"} <= arts))
    checks.append(("CE: natural page order (ce.compareTo -> Natural.compare)",
                   any("Lcra/fork/Natural;->compare(" in o for _, o in cmp_)
                   and not any("compareToIgnoreCase" in o for _, o in cmp_)))

    ok = True
    for label, passed in checks:
        print(("OK   " if passed else "FAIL ") + label)
        ok &= passed
    if not ok:
        raise SystemExit(1)
    print("all checks passed")


if __name__ == "__main__":
    main()
