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
LIB_SMALI = "smali/com/cyo/comicrack/viewer/LibraryActivity.smali"

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

    # Google Analytics endpoint -> reserved never-resolving domain (RFC 2606 ".invalid"),
    # on top of the tracking flags forced off in patch_fork.py.
    ("smali/com/a/b/a/a/r.smali",
     'const-string v0, "www.google-analytics.com"',
     'const-string v0, "analytics.invalid"'),

    # Sort articles: rebuild bi.h just before it is stored (v1/v2 are scratch there,
    # both are overwritten before their next read in bi.<clinit>).
    (BI_SMALI,
     "    sput-object v0, Lcom/cyo/common/bi;->h:[Ljava/lang/String;",
     articles_block() + "\n\n    sput-object v0, Lcom/cyo/common/bi;->h:[Ljava/lang/String;"),
]


# Dead code (docs/PLAN.md): AdMob (com/a/a), twitter4j and the app's Twitter module
# (com/cyo/common/b/a/*) have no use any more: no ads, no tweets. Every use of them
# is cut here, then the classes are deleted and main() checks that nothing in the
# remaining code still names a deleted class.
RV = "smali/com/cyo/comicrack/viewer/"
READER = RV + "ReaderActivity.smali"
AD_LAYOUT = "smali/com/cyo/common/view/a.smali"  # banner slots; ad views only


def ad_method_stub(header: str) -> tuple[str, str]:
    return (AD_LAYOUT, header)


# (smali file, start marker, end marker, replacement): text from the start marker up to
# (not including) the first end marker after it is replaced. Start must occur once.
CUTS = [
    # Reader: interstitial ad. Q() built the ad (null when none): remove it, its field
    # and both callers; "page-turn ad then Runnable" becomes "Runnable".
    (READER, ".method private Q()Lcom/a/a/a/c;", ".method private R()V", ""),
    (READER, ".field n:Lcom/a/a/a/c;\n\n", ".field o:Landroid/widget/Toast;", ""),
    (READER,
     "    :cond_6\n    invoke-direct {p0}, Lcom/cyo/comicrack/viewer/ReaderActivity;->Q()Lcom/a/a/a/c;",
     ".end method",
     "    :cond_6\n" +
     block("if-eqz p1, :cond_2", "invoke-interface {p1}, Ljava/lang/Runnable;->run()V", "goto :goto_1") + "\n"),
    (READER,
     "    .line 830\n    invoke-direct {p0}, Lcom/cyo/comicrack/viewer/ReaderActivity;->Q()Lcom/a/a/a/c;\n\n",
     "    .line 832", "    .line 830\n"),
    # Reader: snapshot menu "Save / Tweet / Share" -> "Save / Share" (gu keeps its index
    # shift for the two-item menu; its Tweet case, which built the dialog gv, is gone).
    (READER,
     "    invoke-static {p0}, Lcom/cyo/common/ag;->a(Landroid/content/Context;)Z\n\n    move-result v3\n\n    if-eqz v3, :cond_a",
     "    :goto_6\n    new-instance v2, Landroid/app/AlertDialog$Builder;",
     block("const/4 v3, 0x0", "goto :cond_a") + "\n\n"),
    (RV + "gu.smali", "    .line 2249\n    :pswitch_1\n", "    .line 2278\n    :cond_1",
     "    :pswitch_1\n" + block("goto :goto_0") + "\n\n"),
    # Rating dialog OK: rating and review are saved (kept); the tweet part is gone.
    (RV + "cr.smali", "    .line 975\n    iget-boolean v0, p0, Lcom/cyo/comicrack/viewer/cr;->f:Z", ".end method",
     block("return-void") + "\n"),
    # Rating dialog (ComicRackApplication.a): the "Share on Twitter" checkbox is gone from its
    # layout (patch_fork.py), so is the code that looked it up, set it and handed it to the
    # OK listener cr. cr now takes (app, rating bar, review field, comic, comic file).
    (RV + "ComicRackApplication.smali",
     "    .line 954\n    sget v1, Lcom/cyo/comicrack/viewer/fs;->comicRatingTweet:I", "    .line 956\n", ""),
    (RV + "ComicRackApplication.smali",
     '    .line 958\n    const-string v1, "tweet_rating"', "    .line 962\n", ""),
    (RV + "cr.smali", ".field private final synthetic f:Z", "# direct methods", ""),
    (RV + "cr.smali",
     ".method constructor <init>(Lcom/cyo/comicrack/viewer/ComicRackApplication;Landroid/widget/RatingBar;"
     "Landroid/widget/EditText;Lcom/cyo/comicrack/a/a/b;Lcom/cyo/comicrack/a/b/h;ZLandroid/widget/CheckBox;"
     "Landroid/content/SharedPreferences;Landroid/app/Activity;)V",
     "    .line 963\n    invoke-direct {p0}, Ljava/lang/Object;-><init>()V",
     ".method constructor <init>(Lcom/cyo/comicrack/viewer/ComicRackApplication;Landroid/widget/RatingBar;"
     "Landroid/widget/EditText;Lcom/cyo/comicrack/a/a/b;Lcom/cyo/comicrack/a/b/h;)V\n    .locals 0\n\n"
     "    .prologue\n    .line 1\n" +
     block("iput-object p1, p0, Lcom/cyo/comicrack/viewer/cr;->a:Lcom/cyo/comicrack/viewer/ComicRackApplication;",
           "iput-object p2, p0, Lcom/cyo/comicrack/viewer/cr;->b:Landroid/widget/RatingBar;",
           "iput-object p3, p0, Lcom/cyo/comicrack/viewer/cr;->c:Landroid/widget/EditText;",
           "iput-object p4, p0, Lcom/cyo/comicrack/viewer/cr;->d:Lcom/cyo/comicrack/a/a/b;",
           "iput-object p5, p0, Lcom/cyo/comicrack/viewer/cr;->e:Lcom/cyo/comicrack/a/b/h;") +
     "\n\n"),
    # ch (dialog dismissed): it saved the checkbox state, then restores the screen and runs
    # the Runnable; only the last two remain. New constructor (app, activity, runnable).
    (RV + "ch.smali", ".field private final synthetic b:Landroid/content/SharedPreferences;",
     ".field private final synthetic d:Landroid/app/Activity;", ""),
    (RV + "ch.smali",
     ".method constructor <init>(Lcom/cyo/comicrack/viewer/ComicRackApplication;Landroid/content/SharedPreferences;"
     "Landroid/widget/CheckBox;Landroid/app/Activity;Ljava/lang/Runnable;)V",
     "    .line 1020\n    invoke-direct {p0}, Ljava/lang/Object;-><init>()V",
     ".method constructor <init>(Lcom/cyo/comicrack/viewer/ComicRackApplication;Landroid/app/Activity;Ljava/lang/Runnable;)V\n"
     "    .locals 0\n\n    .prologue\n    .line 1\n" +
     block("iput-object p1, p0, Lcom/cyo/comicrack/viewer/ch;->a:Lcom/cyo/comicrack/viewer/ComicRackApplication;",
           "iput-object p2, p0, Lcom/cyo/comicrack/viewer/ch;->d:Landroid/app/Activity;",
           "iput-object p3, p0, Lcom/cyo/comicrack/viewer/ch;->e:Ljava/lang/Runnable;") +
     "\n\n"),
    (RV + "ch.smali", "    .line 1024\n    iget-object v0, p0, Lcom/cyo/comicrack/viewer/ch;->b:", "    .line 1026\n", ""),
    # The id of the removed checkbox
    (RV + "fs.smali", ".field public static final comicRatingTweet:I = 0x7f0c0091\n\n", ".field", ""),
    # Settings: reset of the Twitter login (pref no longer exists in the settings screen).
    (RV + "ip.smali", "    .line 344\n    sget-object v0, Lcom/cyo/comicrack/viewer/ComicRackApplication;->i:", "    .line 349\n", ""),
    # The app's Twitter module (with the consumer keys that were embedded in n()).
    (RV + "ComicRackApplication.smali", ".field private p:Lcom/cyo/common/b/a/f;\n\n", ".field", ""),
    (RV + "ComicRackApplication.smali", ".method public final n()Lcom/cyo/common/b/a/f;", ".method public onCreate()V", ""),
]

# Plain text edits (exactly once each), added with the rating dialog change above.
EDITS += [
    (RV + "ComicRackApplication.smali",
     "invoke-direct/range {v0 .. v9}, Lcom/cyo/comicrack/viewer/cr;-><init>(Lcom/cyo/comicrack/viewer/ComicRackApplication;"
     "Landroid/widget/RatingBar;Landroid/widget/EditText;Lcom/cyo/comicrack/a/a/b;Lcom/cyo/comicrack/a/b/h;ZLandroid/widget/CheckBox;"
     "Landroid/content/SharedPreferences;Landroid/app/Activity;)V",
     "invoke-direct/range {v0 .. v5}, Lcom/cyo/comicrack/viewer/cr;-><init>(Lcom/cyo/comicrack/viewer/ComicRackApplication;"
     "Landroid/widget/RatingBar;Landroid/widget/EditText;Lcom/cyo/comicrack/a/a/b;Lcom/cyo/comicrack/a/b/h;)V"),
]

EDITS += [
    (RV + "ComicRackApplication.smali",
     "    .line 1020\n    new-instance v0, Lcom/cyo/comicrack/viewer/ch;\n\n"
     + block("move-object v1, p0", "move-object v2, v8", "move-object v3, v7", "move-object v4, p1",
             "move-object/from16 v5, p4",
             "invoke-direct/range {v0 .. v5}, Lcom/cyo/comicrack/viewer/ch;-><init>(Lcom/cyo/comicrack/viewer/ComicRackApplication;"
             "Landroid/content/SharedPreferences;Landroid/widget/CheckBox;Landroid/app/Activity;Ljava/lang/Runnable;)V"),
     "    .line 1020\n    new-instance v0, Lcom/cyo/comicrack/viewer/ch;\n\n"
     + block("move-object v1, p0", "move-object v2, p1", "move-object/from16 v3, p4",
             "invoke-direct {v0, v1, v2, v3}, Lcom/cyo/comicrack/viewer/ch;-><init>(Lcom/cyo/comicrack/viewer/ComicRackApplication;"
             "Landroid/app/Activity;Ljava/lang/Runnable;)V")),
]

# RAR5: the app's RAR reader (common/c/a) only knows RAR 1.x-4. Its public constructor first
# passes the file through cra.fork.Rar5Fix.prepare, which converts a RAR5 archive into a RAR4
# archive with stored entries (cached) and returns every other file unchanged.
EDITS += [
    ("smali/com/cyo/common/c/a.smali",
     ".method public constructor <init>(Ljava/io/File;)V\n    .locals 1\n\n    .prologue\n    .line 101\n",
     ".method public constructor <init>(Ljava/io/File;)V\n    .locals 1\n\n    .prologue\n"
     + block("invoke-static {p1}, Lcra/fork/Rar5Fix;->prepare(Ljava/io/File;)Ljava/io/File;",
             "move-result-object p1") + "\n\n    .line 101\n"),
]

# Banner manager common/view/a: the slots (a, b(I), constructor) are still used for layout
# bookkeeping; everything that created, showed or released ad views does nothing now.
STUBS = [
    ad_method_stub(".method public final a()V"),
    ad_method_stub(".method final a(Lcom/cyo/common/view/f;)V"),
    ad_method_stub(".method public final b()V"),
    ad_method_stub(".method final b(Lcom/cyo/common/view/f;)V"),
    ad_method_stub(".method public final c()V"),
]

# Removed from the dex (paths under smali/). Nothing left may reference them.
DELETE = [
    "smali/com/a/a", "smali/twitter4j", "smali/com/cyo/common/b/a",
    RV + "cs.smali", RV + "gv.smali", RV + "gw.smali", RV + "hb.smali", RV + "hc.smali",
    "smali/com/cyo/common/view/e.smali", "smali/com/cyo/common/view/g.smali",
]
DELETED_TYPES = ("Lcom/a/a/", "Ltwitter4j/", "Lcom/cyo/common/b/a/",
                 "Lcom/cyo/comicrack/viewer/cs;", "Lcom/cyo/comicrack/viewer/gv;",
                 "Lcom/cyo/comicrack/viewer/gw;", "Lcom/cyo/comicrack/viewer/hb;",
                 "Lcom/cyo/comicrack/viewer/hc;", "Lcom/cyo/common/view/e;",
                 "Lcom/cyo/common/view/g;")

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
    # When the library starts, right after LibraryActivity.a(Bundle) calls its base
    # class: ask for storage access if missing (cra.fork.Perms), then the update
    # check (cra.fork.Updater, at most once a day).
    (LIB_SMALI, None,
     "Lcom/cyo/comicrack/viewer/ep;->a(Landroid/os/Bundle;)V",
     [("Lcom/cyo/comicrack/viewer/ep;->a(Landroid/os/Bundle;)V",
       "Lcom/cyo/comicrack/viewer/ep;->a(Landroid/os/Bundle;)V\n\n"
       "    invoke-static {p0}, Lcra/fork/Perms;->ensure(Landroid/app/Activity;)V\n\n"
       "    invoke-static {p0}, Lcra/fork/Updater;->start(Landroid/app/Activity;)V")]),
]

# (smali file, text appended at the end) - new methods for existing classes.
APPENDS = [
    # Storage permission answer -> cra.fork.Perms.onResult (restarts on grant).
    # The original app (2014) never overrides this; Activity's version is a no-op.
    (LIB_SMALI,
     "\n.method public onRequestPermissionsResult(I[Ljava/lang/String;[I)V\n"
     "    .locals 0\n\n"
     "    invoke-super {p0, p1, p2, p3}, Lcom/cyo/comicrack/viewer/ep;->onRequestPermissionsResult(I[Ljava/lang/String;[I)V\n\n"
     "    invoke-static {p0, p1, p3}, Lcra/fork/Perms;->onResult(Landroid/app/Activity;I[I)V\n\n"
     "    return-void\n"
     ".end method\n"),
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
    update_url = None  # test-only: point the update check at a fake release JSON
    if "--update-url" in args:
        i = args.index("--update-url")
        update_url = args[i + 1]
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
        for rel, text in APPENDS:
            path = os.path.join(work, rel)
            content = read(path)
            if "onRequestPermissionsResult" in content:
                raise SystemExit(f"{rel}: already defines onRequestPermissionsResult")
            write(path, content.rstrip("\n") + "\n" + text)
            print("appended to", rel)
        for rel, start, end, repl in CUTS:
            path = os.path.join(work, rel)
            text = read(path)
            hits = text.count(start)
            if hits != 1:
                raise SystemExit(f"{rel}: expected 1 occurrence, found {hits}: {start[:80]!r}")
            a = text.index(start)
            b = text.find(end, a + len(start))
            if b < 0:
                raise SystemExit(f"{rel}: end marker {end[:60]!r} not found after {start[:60]!r}")
            write(path, text[:a] + repl + text[b:])
            print("cut", rel, f"({b - a} chars)")
        for rel, header in STUBS:
            path = os.path.join(work, rel)
            lines = read(path).split("\n")
            heads = [n for n, line in enumerate(lines) if line == header]
            if len(heads) != 1:
                raise SystemExit(f"{rel}: method {header!r} found {len(heads)} times")
            end = next(n for n in range(heads[0], len(lines)) if lines[n] == ".end method")
            lines[heads[0]:end + 1] = [header, "    .locals 0", "", "    return-void", ".end method"]
            write(path, "\n".join(lines))
            print("stubbed", rel, header)
        for rel in DELETE:
            target = os.path.join(work, rel)
            if os.path.isdir(target):
                shutil.rmtree(target)
            elif os.path.isfile(target):
                os.remove(target)
            else:
                raise SystemExit(f"nothing to delete: {rel}")
            print("deleted", rel)
        dangling = []
        for root, _dirs, files in os.walk(os.path.join(work, "smali")):
            for name in files:
                text = read(os.path.join(root, name))
                for t in DELETED_TYPES:
                    if t in text:
                        dangling.append((os.path.relpath(os.path.join(root, name), work), t))
        if dangling:
            raise SystemExit("deleted classes still referenced: " + repr(dangling[:10]))
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
        if update_url:
            path = os.path.join(work, "smali", "cra", "fork", "Updater.smali")
            text = read(path)
            real = "https://api.github.com/repos/PalpatineRex/ComicRackAndroid/releases/latest"
            if text.count(real) != 1:
                raise SystemExit("Updater.smali: release URL not found")
            write(path, text.replace(real, update_url))
            print("TEST BUILD: update check reads", update_url)
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
