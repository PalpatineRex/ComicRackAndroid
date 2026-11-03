#!/usr/bin/env python3
"""Code changes that need a smali round-trip (apktool): strings of any length,
new instructions, new classes.

Disassembles classes.dex with apktool (which bundles smali/baksmali), applies the
edits below, adds our own classes from tools/smali/, reassembles, and puts the
new classes.dex back into the input APK. Everything else is kept as is. Run it
after the byte patches (patch_lvl.py, patch_fork.py). Every anchor must match
exactly once, otherwise the build stops.

Needs Java and apktool's jar (tested: apktool 2.9.3 on Java 8).

Usage: patch_smali.py IN.apk OUT_UNSIGNED.apk --apktool apktool.jar
"""
import os
import shutil
import subprocess
import sys
import tempfile
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = "https://github.com/PalpatineRex/ComicRackAndroid"
J_SMALI = "smali/com/cyo/comicrack/a/b/j.smali"  # page-file filter (image extensions)
CE_SMALI = "smali/com/cyo/comicrack/a/a/ce.smali"  # a page; compareTo orders pages
BI_SMALI = "smali/com/cyo/common/bi.smali"  # string helpers used by the library sorts

# Articles ignored when sorting series (bi.b strips them; bi.d = series compare;
# also used by the fast-scroll index). Original: the/der/die/das. CE 0.9.180 added
# French articles (Le, La, Les, L') to its default IgnoredArticles.
SORT_ARTICLES = ["the ", "der ", "die ", "das ", "les ", "le ", "la ", "l'", "l\\u2019"]


def articles_block() -> str:
    lines = [f"const/16 v1, 0x{len(SORT_ARTICLES):x}", "new-array v0, v1, [Ljava/lang/String;"]
    for n, a in enumerate(SORT_ARTICLES):
        lines += [f"const/16 v1, 0x{n:x}", f'const-string v2, "{a}"', "aput-object v2, v0, v1"]
    return block(*lines)


def block(*lines: str) -> str:
    """Smali as written by apktool: 4-space indent, a blank line between instructions."""
    return "\n\n".join("    " + line if line else "" for line in lines)


# (smali file, exact old text, new text). Each old text must occur exactly once.
EDITS = [
    # About dialog "Help" button (ComicRackApplication.c, read by viewer.b.onClick)
    ("smali/com/cyo/comicrack/viewer/ComicRackApplication.smali",
     'const-string v0, "http://comicrack.cyolito.com/documentation/comicrack-for-android"',
     f'const-string v0, "{REPO}#readme"'),

    # About dialog "<version>": the original shows versionName + "." + versionCode
    # (1.80.103). The fork's versionName carries the full version (2.9.186).
    ("smali/com/cyo/comicrack/viewer/a.smali",
     block('const-string v5, "."',
           "invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;",
           "move-result-object v4",
           "invoke-static {v2}, Lcom/cyo/common/ag;->e(Landroid/content/Context;)I",
           "move-result v5",
           "invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;",
           "move-result-object v4") + "\n\n",
     ""),

    # Page filter j.a(String): one more register for the SDK checks below.
    (J_SMALI,
     ".method protected static a(Ljava/lang/String;)Z\n    .locals 3",
     ".method protected static a(Ljava/lang/String;)Z\n    .locals 4"),

    # CE 0.9.180: '"__MACOSX" & ".DS_Store" folders will be ignored inside archives'.
    # Reject macOS metadata (__MACOSX/..., AppleDouble "._name") before the
    # extension test; v1 holds the lower-cased entry name.
    (J_SMALI,
     block("invoke-virtual {p0, v0}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;",
           "move-result-object v1") + "\n\n    .line 145",
     block("invoke-virtual {p0, v0}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;",
           "move-result-object v1",
           'const-string v0, "__macosx/"',
           "invoke-virtual {v1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z",
           "move-result v0",
           "if-nez v0, :cra_reject",
           'const-string v0, "/._"',
           "invoke-virtual {v1, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z",
           "move-result v0",
           "if-nez v0, :cra_reject",
           'const-string v0, "._"',
           "invoke-virtual {v1, v0}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z",
           "move-result v0",
           "if-nez v0, :cra_reject",
           "goto :cra_accept_name") +
     "\n\n    :cra_reject\n" +
     block("const/4 v0, 0x0", "return v0") +
     "\n\n    :cra_accept_name\n    .line 145"),

    # CE 0.9.180: HEIF/AVIF support. Android decodes HEIF from 9 (API 28) and AVIF
    # from 12 (API 31), so the extensions are only accepted there.
    (J_SMALI,
     "    :cond_3\n    sput-object v0, Lcom/cyo/comicrack/a/b/j;->d:Ljava/util/List;",
     "    :cond_3\n" +
     block("sget v2, Landroid/os/Build$VERSION;->SDK_INT:I",
           "const/16 v3, 0x1c",
           "if-lt v2, v3, :cra_img_end",
           'const-string v2, ".heic"',
           "invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z",
           'const-string v2, ".heif"',
           "invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z",
           "sget v2, Landroid/os/Build$VERSION;->SDK_INT:I",
           "const/16 v3, 0x1f",
           "if-lt v2, v3, :cra_img_end",
           'const-string v2, ".avif"',
           "invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z") +
     "\n\n    :cra_img_end\n\n    sput-object v0, Lcom/cyo/comicrack/a/b/j;->d:Ljava/util/List;"),

    # Sort articles: rebuild bi.h just before it is stored (v1/v2 are scratch there,
    # both are overwritten before their next read in bi.<clinit>).
    (BI_SMALI,
     "    sput-object v0, Lcom/cyo/common/bi;->h:[Ljava/lang/String;",
     articles_block() + "\n\n    sput-object v0, Lcom/cyo/common/bi;->h:[Ljava/lang/String;"),
]

NATURAL = [("invoke-virtual", "invoke-static"),
           ("Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I",
            "Lcra/fork/Natural;->compare(Ljava/lang/String;Ljava/lang/String;)I")]

# (smali file, method header or None, substring identifying exactly one line in that
#  scope, [(old, new), ...] applied to that line)
LINE_EDITS = [
    # CE 0.9.180: "Updated default sort to be natural sorting (numeric)".
    # Pages were ordered by String.compareToIgnoreCase (page 10 before page 2).
    (CE_SMALI, None, "Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I", NATURAL),
    # Library sorts (title, file, series via bi.d...) all end in bi.c, a null-safe
    # compareToIgnoreCase. Natural order there; 0 still means equalsIgnoreCase.
    (BI_SMALI, ".method public static c(Ljava/lang/String;Ljava/lang/String;)I",
     "Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I", NATURAL),
]

EXTRA_SMALI_DIR = os.path.join(HERE, "smali")  # our own classes, copied as is


def is_signature_entry(name: str) -> bool:
    return name == "META-INF/MANIFEST.MF" or (
        name.startswith("META-INF/") and name.endswith((".SF", ".RSA", ".DSA", ".EC"))
    )


def run(cmd: list[str]) -> None:
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit(f"command failed: {' '.join(cmd)}")


def read(path: str) -> str:
    with open(path, encoding="utf-8") as f:
        return f.read().replace("\r\n", "\n")


def write(path: str, text: str) -> None:
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)


def main() -> None:
    args = sys.argv[1:]
    if "--apktool" not in args:
        raise SystemExit(__doc__)
    i = args.index("--apktool")
    jar = args[i + 1]
    del args[i:i + 2]
    extra_dirs = [EXTRA_SMALI_DIR]
    while "--extra-smali" in args:  # test-only classes (tests/smali), never for releases
        i = args.index("--extra-smali")
        extra_dirs.append(os.path.abspath(args[i + 1]))
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
            text = read(path)
            hits = text.count(old)
            if hits != 1:
                raise SystemExit(f"{rel}: expected 1 occurrence, found {hits}: {old[:80]!r}")
            write(path, text.replace(old, new))
            print("edited", rel)
        for rel, method, marker, repl in LINE_EDITS:
            path = os.path.join(work, rel)
            lines = read(path).split("\n")
            lo, hi = 0, len(lines)
            if method:
                heads = [n for n, line in enumerate(lines) if line == method]
                if len(heads) != 1:
                    raise SystemExit(f"{rel}: method {method!r} found {len(heads)} times")
                lo = heads[0]
                hi = next(n for n in range(lo, len(lines)) if lines[n] == ".end method")
            idx = [n for n in range(lo, hi) if marker in lines[n]]
            if len(idx) != 1:
                raise SystemExit(f"{rel}: expected 1 line with {marker!r}, found {len(idx)}")
            for old, new in repl:
                if old not in lines[idx[0]]:
                    raise SystemExit(f"{rel}: {old!r} not in line {lines[idx[0]]!r}")
                lines[idx[0]] = lines[idx[0]].replace(old, new)
            write(path, "\n".join(lines))
            print("edited", rel, "(line)")
        for base in extra_dirs:
          for root, _dirs, files in os.walk(base):
            for name in files:
                if name.endswith(".smali"):
                    rel = os.path.relpath(os.path.join(root, name), base)
                    target = os.path.join(work, "smali", rel)
                    if os.path.exists(target):
                        raise SystemExit(f"class already exists: {rel}")
                    os.makedirs(os.path.dirname(target), exist_ok=True)
                    shutil.copyfile(os.path.join(root, name), target)
                    print("added", rel)
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
