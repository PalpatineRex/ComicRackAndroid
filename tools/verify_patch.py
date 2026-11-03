#!/usr/bin/env python3
"""Check that patch_lvl.py reproduces the cracked classes.dex exactly.

Usage: verify_patch.py PATCHED.apk CRACKED_REFERENCE.apk
Only compares classes.dex. The reference APK is never stored in this repo.
"""
import hashlib
import sys
import zipfile


def dex_of(path: str) -> bytes:
    with zipfile.ZipFile(path) as z:
        return z.read("classes.dex")


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    a, b = dex_of(sys.argv[1]), dex_of(sys.argv[2])
    print("patched  classes.dex sha256:", hashlib.sha256(a).hexdigest())
    print("cracked  classes.dex sha256:", hashlib.sha256(b).hexdigest())
    if a != b:
        diff = [i for i in range(min(len(a), len(b))) if a[i] != b[i]]
        raise SystemExit(f"MISMATCH ({len(diff)} differing bytes, lengths {len(a)}/{len(b)})")
    print("OK: identical")


if __name__ == "__main__":
    main()
