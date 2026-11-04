#!/usr/bin/env python3
"""Generate tests/fixtures/cra_test_rar5.cbr: a RAR5 archive (stored entries) with three JPEG pages.

Used to check RAR5 support on a device or emulator: the comic must open and show 3 pages,
PAGE 1, PAGE 2, PAGE 10 in that order. (Stored entries only: the LZ decoder is covered by the
RAR5 samples listed in docs/PLAN.md.)

Needs: pip install pillow
"""
import io
import os
import struct
import zlib

from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fixtures", "cra_test_rar5.cbr")


def vint(n):
    out = bytearray()
    while True:
        b = n & 0x7F
        n >>= 7
        out.append(b | (0x80 if n else 0))
        if not n:
            return bytes(out)


def block(htype, hflags, fields, data_size=None):
    body = vint(htype) + vint(hflags)
    if data_size is not None:
        body += vint(data_size)
    body += fields
    head = vint(len(body)) + body
    return struct.pack("<I", zlib.crc32(head) & 0xFFFFFFFF) + head


def jpeg(label, color):
    img = Image.new("RGB", (600, 900), color)
    ImageDraw.Draw(img).text((200, 400), label, fill=(255, 255, 255))
    buf = io.BytesIO()
    img.save(buf, "JPEG", quality=80)
    return buf.getvalue()


def main():
    pages = [("page 10.jpg", jpeg("PAGE 10", (160, 40, 40))),
             ("page 1.jpg", jpeg("PAGE 1", (40, 90, 160))),
             ("page 2.jpg", jpeg("PAGE 2", (40, 140, 70)))]
    out = bytearray(b"Rar!\x1a\x07\x01\x00")
    out += block(1, 0, vint(0))
    for name, data in pages:
        nb = name.encode()
        fields = (vint(4) + vint(len(data)) + vint(0x20) + struct.pack("<I", zlib.crc32(data) & 0xFFFFFFFF)
                  + vint(0) + vint(1) + vint(len(nb)) + nb)
        out += block(2, 2, fields, data_size=len(data)) + data
    out += block(5, 0, vint(0))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "wb") as f:
        f.write(out)
    print("wrote", OUT, len(out))


if __name__ == "__main__":
    main()
