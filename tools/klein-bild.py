"""Setzt vier Bildschirmfotos (Kreuz in Originalgröße auf grauem, lila, weißem und
schwarzem Grund) zu einem 2×2-Bild zusammen: docs/klein.webp.

Jede Kachel ist die Bildschirmmitte in voller Höhe (609 × 720 von 1280 × 720), das Kreuz
also im echten Verhältnis zur Bildschirmhöhe. So hat das 2×2-Bild 0,85 : 1 und füllt auf
der Website (Spalte 747 px) genau die Lücke neben dem Editor-Bild bei voller Höhe 380 px.
Auch im Website-Repo als assets/anleitung/fadenkreuz-klein.webp.
Die Lücken bleiben durchsichtig, damit der Seitengrund durchscheint.
Aufruf: python tools/klein-bild.py grau.webp lila.webp weiss.webp schwarz.webp
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw

KACHEL = (609, 720)    # Mitte eines 16:9-Bildschirms in voller Höhe
LUECKE = 16
RADIUS = 10


def kachel(pfad):
    bild = Image.open(pfad).convert('RGB')
    # Mittig auf das Kachelformat zuschneiden, dann verkleinern: das Kreuz bleibt in der Mitte.
    b, h = bild.size
    ziel = KACHEL[0] / KACHEL[1]
    if b / h > ziel:
        nb = round(h * ziel)
        bild = bild.crop(((b - nb) // 2, 0, (b - nb) // 2 + nb, h))
    elif b / h < ziel:
        nh = round(b / ziel)
        bild = bild.crop((0, (h - nh) // 2, b, (h - nh) // 2 + nh))
    return bild.resize(KACHEL, Image.LANCZOS)


def main(pfade):
    if len(pfade) != 4:
        sys.exit('Bitte genau vier Bilder angeben (grau, lila, weiß, schwarz).')
    gb = 2 * KACHEL[0] + LUECKE
    gh = 2 * KACHEL[1] + LUECKE
    gesamt = Image.new('RGBA', (gb, gh), (0, 0, 0, 0))
    maske = Image.new('L', KACHEL, 0)
    ImageDraw.Draw(maske).rounded_rectangle((0, 0, KACHEL[0] - 1, KACHEL[1] - 1), RADIUS, fill=255)
    for i, pfad in enumerate(pfade):
        x = (i % 2) * (KACHEL[0] + LUECKE)
        y = (i // 2) * (KACHEL[1] + LUECKE)
        gesamt.paste(kachel(pfad), (x, y), maske)
    ziel = Path(__file__).resolve().parent.parent / 'docs' / 'klein.webp'
    gesamt.save(ziel, 'WEBP', lossless=True, method=6)
    print(ziel, gesamt.size, ziel.stat().st_size, 'Bytes')


if __name__ == '__main__':
    main(sys.argv[1:])
