#!/usr/bin/env python3
"""Compare the latest ComicRack CE build with the one this fork is at.

Reads ComicRack CE's changelog (ComicRack/Output/Changes.txt on its master branch),
finds every "Community Edition Build X.Y.Z" newer than ce-version.txt, and prints
a JSON summary: {"current", "latest", "new": [{"version", "notes"}...]}.
Used by .github/workflows/ce-watch.yml; standard library only.

Usage: ce_watch.py CHANGES.txt CURRENT_VERSION
"""
import json
import re
import sys

HEADER = re.compile(r"^Community Edition Build (\d+)\.(\d+)\.(\d+):\s*$")
ANY_HEADER = re.compile(r"^(Community Edition )?Build \d+\.\d+\.\d+:\s*$")


def parse(text: str) -> list[tuple[tuple[int, int, int], str]]:
    builds, current, lines = [], None, []
    for line in text.replace("\r\n", "\n").split("\n"):
        if ANY_HEADER.match(line):
            if current:
                builds.append((current, "\n".join(lines).strip()))
            m = HEADER.match(line)
            current = tuple(map(int, m.groups())) if m else None
            lines = []
        elif current:
            lines.append(line)
    if current:
        builds.append((current, "\n".join(lines).strip()))
    return builds


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    text = open(sys.argv[1], encoding="utf-8-sig").read()
    cur = tuple(map(int, sys.argv[2].strip().lstrip("v").split(".")))
    builds = parse(text)
    if not builds:
        raise SystemExit("no 'Community Edition Build' header found: changelog format changed?")
    latest = max(v for v, _ in builds)
    new = [{"version": ".".join(map(str, v)), "notes": n} for v, n in sorted(builds, reverse=True) if v > cur]
    print(json.dumps({"current": ".".join(map(str, cur)), "latest": ".".join(map(str, latest)), "new": new}))


if __name__ == "__main__":
    main()
