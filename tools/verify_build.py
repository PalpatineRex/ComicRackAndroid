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
    ok_listener = method_ins(dex, "Lcom/cyo/comicrack/viewer/cr;", "<init>", "Lcom/cyo/comicrack/a/b/h;)V") or []
    checks.append(("Rating dialog: no Twitter checkbox (layout, code, OK listener)",
                   bool(rating) and bool(ok_listener)
                   and not any("CheckBox" in o for _, o in rating)
                   and b"CheckBox" not in AXMLPrinter(z.read("res/layout/comic_rating.xml")).get_xml()
                   and "tweet_rating" not in strings and "tweet_include_thumb" not in strings))
    # A constructor that calls super() twice is rejected by ART's verifier (VerifyError at the first
    # use, found on a device once): the rewritten listener constructors must call it exactly once.
    for cls in ("cr", "ch"):
        ctor = method_ins(dex, f"Lcom/cyo/comicrack/viewer/{cls};", "<init>") or []
        checks.append((f"{cls}.<init> calls super() exactly once",
                       sum(1 for n, o in ctor if n == "invoke-direct" and "Ljava/lang/Object;-><init>" in o) == 1))
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
    ours = {"Lcra/fork/Natural;", "Lcra/fork/Updater;", "Lcra/fork/UpdatePrompt;", "Lcra/fork/Perms;",
            "Lcra/fork/Rar5Fix;", "Lcra/fork/Rar5Reader;", "Lcra/fork/Rar5Reader$Entry;",
            "Lcra/fork/Rar5Reader$Filter;", "Lcra/fork/Rar5Reader$Lz;", "Lcra/fork/Rar5Reader$1;"}
    cont = {n for n in names if n.startswith("Lcra/fork/ContReader")}
    test_classes = {n for n in names if n.startswith("Lcra/test/")}
    checks.append(("classes: 1421 original - 376 dead + cra/fork (Natural, Updater, UpdatePrompt, Perms, Rar5*, Cont*), no test class",
                   len(names) == 1421 - 376 + len(ours) + len(cont) and ours <= names and "Lcra/fork/Cont;" in names and not test_classes))
    # Dead code (AdMob, twitter4j, the Twitter module) is gone and nothing names it any more:
    # every class a declaration or instruction refers to has its descriptor in the string table.
    dead = ("Lcom/a/a/", "Ltwitter4j/", "Lcom/cyo/common/b/a/",
            "Lcom/cyo/comicrack/viewer/cs;", "Lcom/cyo/comicrack/viewer/gv;", "Lcom/cyo/comicrack/viewer/gw;",
            "Lcom/cyo/comicrack/viewer/hb;", "Lcom/cyo/comicrack/viewer/hc;",
            "Lcom/cyo/common/view/e;", "Lcom/cyo/common/view/g;")
    checks.append(("no dead class (AdMob, twitter4j, Twitter module) in the dex, none referenced",
                   not any(t.startswith(dead) for t in strings)))
    checks.append(("no embedded Twitter / AdMob keys",
                   not any(k in strings for k in ("lc7K38IqLGD9tlvj9DP42w", "ca-app-pub-4781274123938257/5497297649",
                                                  "a14e6a2bbd7e129"))))
    pruned = ("tweet", "close_advertisment", "general_allow_tracking_title", "general_twitter_reset_title")
    arsc_text = z.read("resources.arsc")
    checks.append(("unused resources pruned (Twitter / tracking / ad strings, old drawables)",
                   not any(n.encode("utf-16-le") in arsc_text or n.encode() in arsc_text for n in pruned)
                   and not any(n.startswith(("res/layout/ok_cancel_strip", "res/drawable-hdpi-v4/btn_expand"))
                               for n in z.namelist())))
    lib = method_ins(dex, "Lcom/cyo/comicrack/viewer/LibraryActivity;", "a", "(Landroid/os/Bundle;)V") or []
    checks.append(("Update check started by LibraryActivity",
                   any("Lcra/fork/Updater;->start(" in o for _, o in lib)))
    checks.append(("Storage permission asked by LibraryActivity",
                   any("Lcra/fork/Perms;->ensure(" in o for _, o in lib)))
    res = method_ins(dex, "Lcom/cyo/comicrack/viewer/LibraryActivity;", "onRequestPermissionsResult") or []
    checks.append(("Permission answer handled (restart on grant)",
                   any("Lcra/fork/Perms;->onResult(" in o for _, o in res)))
    rar = method_ins(dex, "Lcom/cyo/common/c/a;", "<init>", "(Ljava/io/File;)V") or []
    checks.append(("RAR reader opens files through Rar5Fix.prepare (RAR5 support)",
                   any("Lcra/fork/Rar5Fix;->prepare(" in o for _, o in rar)))
    gn = method_ins(dex, "Lcom/cyo/comicrack/viewer/gn;", "onPostExecute", "Ljava/lang/Object;") or []
    checks.append(("Continuous mode: reader hands loaded comics to Cont.open",
                   any("Lcra/fork/Cont;->open(" in o for _, o in gn)))
    dfrag = method_ins(dex, "Lcom/cyo/comicrack/viewer/ComicRackPreferencesActivity$DisplayFragment;", "onCreate") or []
    checks.append(("Continuous mode: setting added to reader settings",
                   any("Lcra/fork/Cont;->addPreference(" in o for _, o in dfrag)))
    checks.append(("Update check reads this repo's releases",
                   "https://api.github.com/repos/PalpatineRex/ComicRackAndroid/releases/latest" in strings))

    def forced_false(cls, name, desc, key):
        ins = method_ins(dex, cls, name, desc) or []
        out = [i for i, (n, o) in enumerate(ins) if n.startswith("const-string") and f'"{key}"' in o]
        if not out:
            return False
        after = ins[out[0]:]
        call = next((i for i, (n, o) in enumerate(after) if "getBoolean" in o), None)
        return call is not None and after[call + 1] == ("const/4", "v0, 0")
    checks.append(("Stats: opt-in popup never asked (ask_tracking_enabled -> false)",
                   forced_false("Lcom/cyo/comicrack/viewer/a;", "b", "()Z", "ask_tracking_enabled")))
    checks.append(("Stats: app tracking flag always false",
                   forced_false("Lcom/cyo/comicrack/viewer/a;", "a", "()Z", "tracking_enabled")))
    checks.append(("Stats: Google Analytics own flag always false",
                   forced_false("Lcom/a/b/a/a/a/b;", "a", "(Landroid/content/Context;)V", "tracking_enabled")))
    checks.append(("Stats: Google Analytics host neutralised",
                   "www.google-analytics.com" not in strings and "analytics.invalid" in strings))
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
