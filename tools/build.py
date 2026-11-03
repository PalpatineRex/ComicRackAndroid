#!/usr/bin/env python3
"""Build the fork APK end to end: patch, verify, sign.

Usage:
  build.py --base ComicRack.1.80.apk --ce-version 0.9.186 [--rev N]
           --apktool apktool.jar --key key.pem --cert cert.pem --out OUT.apk

Steps (each tool is also usable alone, see docs/PLAN.md):
  patch_lvl -> patch_fork -> patch_manifest -> patch_dex_strings -> verify_build -> sign_v1
Needs Python 3.10+, Java (for apktool), and pip packages: cryptography, androguard, loguru.
Stops at the first failure; nothing is signed if verification fails.
"""
import os
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from patch_manifest import fork_version  # noqa: E402


def take(args: list[str], flag: str, default=None, required=True):
    if flag in args:
        i = args.index(flag)
        value = args[i + 1]
        del args[i:i + 2]
        return value
    if required and default is None:
        raise SystemExit(f"missing {flag}\n\n{__doc__}")
    return default


def step(*cmd: str) -> None:
    print("==>", " ".join(os.path.basename(c) if c.endswith(".py") else c for c in cmd[1:3]), flush=True)
    res = subprocess.run([sys.executable, *cmd[1:]] if cmd[0] == "py" else list(cmd))
    if res.returncode != 0:
        raise SystemExit(f"step failed: {' '.join(cmd)}")


def main() -> None:
    args = sys.argv[1:]
    base = take(args, "--base")
    ce = take(args, "--ce-version")
    rev = take(args, "--rev", "0")
    apktool = take(args, "--apktool")
    key = take(args, "--key")
    cert = take(args, "--cert")
    out = take(args, "--out")
    if args:
        raise SystemExit(f"unknown arguments: {args}")
    name, code = fork_version(ce, int(rev))
    print(f"building {name} (versionCode {code}) from CE {ce}")
    t = lambda n: os.path.join(HERE, n)  # noqa: E731
    with tempfile.TemporaryDirectory(prefix="cra_build_") as tmp:
        s = [os.path.join(tmp, f"s{i}.apk") for i in range(1, 5)]
        step("py", t("patch_lvl.py"), base, s[0])
        step("py", t("patch_fork.py"), s[0], s[1])
        step("py", t("patch_manifest.py"), s[1], s[2], "--ce-version", ce, "--rev", rev)
        step("py", t("patch_dex_strings.py"), s[2], s[3], "--apktool", apktool)
        step("py", t("verify_build.py"), s[3], "--version-name", name, "--version-code", str(code))
        step("py", t("sign_v1.py"), "sign", s[3], out, key, cert)
    print(f"done: {out} ({name}, {code})")


if __name__ == "__main__":
    main()
