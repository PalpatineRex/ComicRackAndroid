#!/usr/bin/env python3
"""Remove resources nothing uses any more (Twitter, usage statistics, ads, old UI leftovers).

The original binary XML files are kept as they are; only the ones listed below are dropped
from the APK, and resources.arsc (the table of strings, styles, ids) is rebuilt without the
removed entries by apktool/aapt2. Resource ids are pinned (public.xml): the script checks that
every remaining resource has exactly the id it had, because classes.dex holds them as numbers.

Run it after patch_smali.py. Needs Java and apktool's jar.
Usage: prune_res.py IN.apk OUT_UNSIGNED.apk --apktool apktool.jar
"""
import glob
import os
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile

# (type, name). Found by checking every id against classes.dex (R fields and numbers) and
# against the other resource files (@type/name); see docs/PLAN.md.
UNUSED = (
    [("string", n) for n in (
        "ga_api_key", "general_allow_tracking_summary", "general_allow_tracking_title",
        "close_advertisment", "authenticate_on_twitter", "preference_category_social_title",
        "general_twitter_reset_title", "general_twitter_reset_summary", "tweet_sent",
        "tweet_failed", "general_twitter_include_thumb_title",
        "general_twitter_include_thumb_summary", "tweet", "tweet_snapshot_caption",
        "tweet_snapshot_text", "flat")]
    + [("drawable", n) for n in (
        "widget_cover_black_border", "btn_contract", "btn_expand", "btn_next_page",
        "btn_prev_page", "rating_star_full_black")]
    + [("layout", "ok_cancel_strip")]
)
FILE_TYPES = ("drawable", "layout")


def run(cmd):
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit(f"command failed: {' '.join(cmd)}")


def public_ids(path):
    with open(path, encoding="utf-8") as f:
        return {(t, n): i for t, n, i in re.findall(r'<public type="(\w+)" name="([^"]+)" id="(0x[0-9a-f]+)"', f.read())}


def main():
    args = sys.argv[1:]
    if "--apktool" not in args or len(args) != 4:
        raise SystemExit(__doc__)
    i = args.index("--apktool")
    jar = args[i + 1]
    del args[i:i + 2]
    src, dst = args
    tmp = tempfile.mkdtemp(prefix="cra_res_")
    try:
        work = os.path.join(tmp, "res")
        run(["java", "-jar", jar, "d", "-f", "--no-src", "-o", work, src])
        before = public_ids(os.path.join(work, "res", "values", "public.xml"))
        missing = [u for u in UNUSED if u not in before]
        if missing:
            raise SystemExit(f"resources not in the APK: {missing}")
        removed_files = set()
        for typ, name in UNUSED:
            if typ in FILE_TYPES:
                for p in glob.glob(os.path.join(work, "res", f"{typ}*", f"{name}.*")):
                    removed_files.add(os.path.relpath(p, work).replace(os.sep, "/"))
                    os.remove(p)
        strings = {n for t, n in UNUSED if t == "string"}
        for p in glob.glob(os.path.join(work, "res", "values*", "strings.xml")):
            with open(p, encoding="utf-8") as f:
                text = f.read()
            for n in strings:
                text = re.sub(r'\s*<string name="%s"[^>]*>.*?</string>' % re.escape(n), "", text, flags=re.S)
            with open(p, "w", encoding="utf-8", newline="\n") as f:
                f.write(text)
        pub = os.path.join(work, "res", "values", "public.xml")
        with open(pub, encoding="utf-8") as f:
            text = f.read()
        for typ, name in UNUSED:
            text = re.sub(r'\s*<public type="%s" name="%s" id="[^"]+" />' % (typ, re.escape(name)), "", text)
        with open(pub, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        built = os.path.join(tmp, "built.apk")
        run(["java", "-jar", jar, "b", "-o", built, work])
        check = os.path.join(tmp, "check")
        run(["java", "-jar", jar, "d", "-f", "--no-src", "-o", check, built])
        after = public_ids(os.path.join(check, "res", "values", "public.xml"))
        want = {k: v for k, v in before.items() if k not in set(UNUSED)}
        if after != want:
            diff = {k for k in set(after) | set(want) if after.get(k) != want.get(k)}
            raise SystemExit(f"resource ids changed: {sorted(diff)[:10]}")
        with zipfile.ZipFile(built) as zb:
            arsc = zb.read("resources.arsc")
        with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w") as zout:
            for info in zin.infolist():
                if info.filename in removed_files:
                    print("removed", info.filename)
                    continue
                data = arsc if info.filename == "resources.arsc" else zin.read(info.filename)
                out = zipfile.ZipInfo(info.filename, date_time=info.date_time)
                out.compress_type = info.compress_type
                out.external_attr = info.external_attr
                zout.writestr(out, data)
        print(f"removed {len(UNUSED)} resources ({len(removed_files)} files), {len(want)} ids unchanged; wrote {dst}")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
