#!/usr/bin/env python3
"""Add the JPEG XL native libraries (jxl-coder, libjxl) to the APK under lib/<abi>/.

Usage: add_native.py IN.apk OUT.apk [--aar PATH] [--abis arm64-v8a,armeabi-v7a,x86]

The library is jxl-coder 2.6.1 (github.com/awxkee/jxl-coder, Apache-2.0 / BSD-3; libjxl and
Brotli inside). Its release AAR is downloaded from Maven Central if --aar does not exist yet
(default: a cache file next to this script) and checked against the SHA-256 below. Only the
.so files are used; the Kotlin classes are replaced by com.awxkee.jxlcoder.JxlCoder (tools/java).
"""
import hashlib
import os
import sys
import urllib.request
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
URL = ("https://repo1.maven.org/maven2/io/github/awxkee/jxl-coder/2.6.1/"
       "jxl-coder-2.6.1-release.aar")
SHA256 = "5cf6ce13eccb227ce3d4f3a142cdc0e02023803d592caeade532c3450e59e7fa"
DEFAULT_ABIS = "arm64-v8a,armeabi-v7a,x86"
CACHE = os.path.join(HERE, ".cache", "jxl-coder-2.6.1-release.aar")
LIBS = ["libjxlcoder.so", "libjxl.so", "libjxl_cms.so", "libjxl_threads.so",
        "libbrotlicommon.so", "libbrotlidec.so", "libbrotlienc.so"]


def sha256(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def get_aar(path: str | None) -> str:
    path = path or CACHE
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        print("downloading", URL)
        urllib.request.urlretrieve(URL, path)
    got = sha256(path)
    if got != SHA256:
        raise SystemExit(f"{path}: SHA-256 {got} is not the expected {SHA256}")
    return path


def main() -> None:
    args = sys.argv[1:]
    aar = None
    abis = DEFAULT_ABIS
    while "--aar" in args:
        i = args.index("--aar")
        aar = args[i + 1]
        del args[i:i + 2]
    while "--abis" in args:
        i = args.index("--abis")
        abis = args[i + 1]
        del args[i:i + 2]
    if len(args) != 2:
        raise SystemExit(__doc__)
    src, dst = args
    abi_list = [a for a in abis.split(",") if a]
    with zipfile.ZipFile(get_aar(aar)) as za, zipfile.ZipFile(src) as zin, \
            zipfile.ZipFile(dst, "w") as zout:
        for info in zin.infolist():
            if info.filename.startswith("lib/"):
                raise SystemExit("the base APK already has native libraries: " + info.filename)
            out = zipfile.ZipInfo(info.filename, date_time=info.date_time)
            out.compress_type = info.compress_type
            out.external_attr = info.external_attr
            zout.writestr(out, zin.read(info.filename))
        for abi in abi_list:
            for lib in LIBS:
                name = f"jni/{abi}/{lib}"
                out = zipfile.ZipInfo(f"lib/{abi}/{lib}", date_time=(2026, 1, 1, 0, 0, 0))
                out.compress_type = zipfile.ZIP_DEFLATED
                out.external_attr = 0o644 << 16
                zout.writestr(out, za.read(name))
            print("added lib/" + abi)
    print("wrote", dst)


if __name__ == "__main__":
    main()
