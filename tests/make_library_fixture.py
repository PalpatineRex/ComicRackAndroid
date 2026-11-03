#!/usr/bin/env python3
"""Generate tests/fixtures/library_sort/*.cbz: one-page comics whose ComicInfo.xml
series names exercise the library sort (invented names, no third-party content).

Expected series order with the fork (articles and accents ignored, natural numbers):
  Alpha, L'Arbre, Les Bateaux, Ecureuil (accented), La Montagne, Serie 2 (accented), Serie 10,
  The Yeti, Le Zebre
Original 1.80 order (only the/der/die/das ignored, plain text compare, accents after z):
  Alpha, L'Arbre, La Montagne, Le Zebre, Les Bateaux, Serie 10, The Yeti, Serie 2, Ecureuil

Needs: pip install pillow
"""
import io
import os
import zipfile
from xml.sax.saxutils import escape

from PIL import Image, ImageDraw, ImageFont

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fixtures", "library_sort")
SERIES = ["Le Zebre", "Serie 10", "Alpha", "Les Bateaux", "The Yeti", "La Montagne", "S\u00e9rie 2", "L'Arbre", "\u00c9cureuil"]


def cover(text: str) -> bytes:
    img = Image.new("RGB", (400, 600), (45, 45, 60))
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("DejaVuSans-Bold.ttf", 44)
    except OSError:
        font = ImageFont.load_default()
    d.rectangle([12, 12, 388, 588], outline="white", width=6)
    d.text((200, 300), text, fill="white", font=font, anchor="mm")
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=80)
    return buf.getvalue()


def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    for n, series in enumerate(SERIES):
        info = ('<?xml version="1.0"?>\n<ComicInfo>\n'
                f"  <Series>{escape(series)}</Series>\n  <Number>1</Number>\n"
                f"  <Title>{escape(series)}</Title>\n  <PageCount>1</PageCount>\n</ComicInfo>\n")
        path = os.path.join(OUT, f"cra_sort_{n:02d}.cbz")
        with zipfile.ZipFile(path, "w", zipfile.ZIP_STORED) as z:
            z.writestr(zipfile.ZipInfo("ComicInfo.xml", date_time=(2026, 11, 3, 0, 0, 0)), info)
            z.writestr(zipfile.ZipInfo("01.jpg", date_time=(2026, 11, 3, 0, 0, 0)), cover(series))
        print("wrote", path)


if __name__ == "__main__":
    main()
