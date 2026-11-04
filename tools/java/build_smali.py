#!/usr/bin/env python3
"""Compile tools/java/**/*.java to Dalvik smali (tools/smali/cra/fork/<Name>.smali).

The generated smali is committed, so a normal build does not need the Android SDK; run this only
after changing the Java. Needs: JDK 11+, an Android SDK with build-tools (d8) and a platform
android.jar, and apktool's jar (it bundles baksmali).

Usage: build_smali.py --sdk ANDROID_SDK --apktool apktool.jar [--java javac] [--platform android-25]
"""
import argparse
import glob
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(os.path.dirname(HERE), "smali")


def run(cmd):
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        sys.stderr.write(res.stdout + res.stderr)
        raise SystemExit("failed: " + " ".join(cmd))
    return res.stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sdk", required=True)
    ap.add_argument("--apktool", required=True)
    ap.add_argument("--platform", default="android-25")
    ap.add_argument("--java-home", default=os.environ.get("JAVA_HOME", ""))
    a = ap.parse_args()
    bin_dir = os.path.join(a.java_home, "bin") if a.java_home else ""
    exe = ".exe" if os.name == "nt" else ""
    javac = os.path.join(bin_dir, "javac" + exe) if bin_dir else "javac"
    java = os.path.join(bin_dir, "java" + exe) if bin_dir else "java"
    android_jar = os.path.join(a.sdk, "platforms", a.platform, "android.jar")
    bt = sorted(glob.glob(os.path.join(a.sdk, "build-tools", "*")))[-1]
    d8_jar = os.path.join(bt, "lib", "d8.jar")
    sources = glob.glob(os.path.join(HERE, "**", "*.java"), recursive=True)
    tmp = tempfile.mkdtemp(prefix="cra_java_")
    try:
        cls = os.path.join(tmp, "cls")
        os.makedirs(cls)
        run([javac, "--release", "8", "-Xlint:-options", "-cp", android_jar, "-d", cls] + sources)
        classes = glob.glob(os.path.join(cls, "**", "*.class"), recursive=True)
        dex = os.path.join(tmp, "dex")
        os.makedirs(dex)
        run([java, "-cp", d8_jar, "com.android.tools.r8.D8", "--release", "--min-api", "21",
             "--lib", android_jar, "--output", dex] + classes)
        smali = os.path.join(tmp, "smali")
        run([java, "-cp", a.apktool, "com.android.tools.smali.baksmali.Main", "disassemble",
             "--api", "21", "-o", smali, os.path.join(dex, "classes.dex")])
        dst = os.path.join(OUT, "cra", "fork")
        for path in glob.glob(os.path.join(smali, "cra", "fork", "*.smali")):
            name = os.path.basename(path)
            shutil.copyfile(path, os.path.join(dst, name))
            print("wrote", os.path.join(dst, name))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
