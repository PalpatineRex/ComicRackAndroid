#!/usr/bin/env python3
"""Generate tests/fixtures/cra_test_pages.cbz, a test comic for the ported CE features.

Pages (stored in this shuffled order inside the archive):
  page 10.jpg              -> must be shown 4th (natural sort; old order put it 2nd)
  page 3.avif              -> AVIF, 3rd (Android 12+)
  __MACOSX/._page 1.jpg    -> macOS metadata, must be ignored
  page 1.jpg               -> 1st
  ._page 2.jpg             -> AppleDouble file, must be ignored
  page 2.heic              -> HEIC, 2nd (Android 9+)
Expected on Android 13: 4 pages, PAGE 1 (JPG), PAGE 2 (HEIC), PAGE 3 (AVIF), PAGE 10 (JPG).

Needs: pip install pillow pillow-heif   (Pillow >= 11.2 for AVIF)
"""
import io
import os
import zipfile

import pillow_heif
from PIL import Image, ImageDraw, ImageFont

pillow_heif.register_heif_opener()
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fixtures", "cra_test_pages.cbz")
W, H = 600, 900


def page(number: int, fmt: str, color: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGB", (W, H), color)
    d = ImageDraw.Draw(img)
    try:
        big = ImageFont.truetype("DejaVuSans-Bold.ttf", 150)
        small = ImageFont.truetype("DejaVuSans-Bold.ttf", 70)
    except OSError:
        big = small = ImageFont.load_default()
    d.text((W // 2, H // 2 - 90), f"PAGE {number}", fill="white", font=big if number < 10 else small, anchor="mm")
    d.text((W // 2, H // 2 + 120), fmt, fill="white", font=small, anchor="mm")
    d.rectangle([20, 20, W - 20, H - 20], outline="white", width=12)
    return img


def encode(img: Image.Image, fmt: str) -> bytes:
    buf = io.BytesIO()
    img.save(buf, format={"JPG": "JPEG", "HEIC": "HEIF", "AVIF": "AVIF"}[fmt], quality=80)
    return buf.getvalue()


def main() -> None:
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    entries = [
        ("page 10.jpg", encode(page(10, "JPG", (40, 90, 160)), "JPG")),
        ("page 3.avif", encode(page(3, "AVIF", (150, 60, 40)), "AVIF")),
        ("__MACOSX/._page 1.jpg", b"\x00\x05\x16\x07 AppleDouble metadata, not an image"),
        ("page 1.jpg", encode(page(1, "JPG", (30, 120, 60)), "JPG")),
        ("._page 2.jpg", b"\x00\x05\x16\x07 AppleDouble metadata, not an image"),
        ("page 2.heic", encode(page(2, "HEIC", (110, 50, 140)), "HEIC")),
    ]
    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_STORED) as z:
        for name, data in entries:
            z.writestr(zipfile.ZipInfo(name, date_time=(2026, 11, 3, 0, 0, 0)), data)
    print("wrote", OUT, os.path.getsize(OUT), "bytes")


if __name__ == "__main__":
    main()
