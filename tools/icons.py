"""Zeichnet fadenkreuz.ico und editor.ico, jede Größe einzeln (pixelscharf).

Aufruf: python tools/icons.py [vorschau.png]
"""
import io
import struct
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

GROESSEN = [16, 20, 24, 32, 40, 48, 64, 128, 256]
SS = 8  # Überabtastung, danach Box-Verkleinerung: Rechtecke auf Pixelkanten bleiben scharf

GRUEN = (51, 255, 136)
GRUEN_RING = (51, 255, 136, 215)


def params(s):
    """Dicke, Lücke, Armlänge, Ringradius, Ringbreite, Eckenradius - pro Größe von Hand."""
    return {
        16: (2, 2, 7, 0, 0, 3),
        20: (2, 3, 9, 0, 0, 4),
        24: (2, 3, 11, 0, 0, 5),
        32: (2, 4, 14, 9, 1.6, 6),
        40: (2, 5, 17, 11.5, 2, 8),
        48: (4, 6, 21, 14, 2.6, 9),
        64: (4, 8, 28, 19, 3.2, 12),
        128: (8, 16, 56, 38, 6, 24),
        256: (14, 32, 112, 76, 11, 48),
    }[s]


def hintergrund(s, oben, unten, rand, raster=False):
    k = s * SS
    verlauf = Image.new("RGBA", (k, k))
    px = verlauf.load()
    for y in range(k):
        f = y / (k - 1)
        c = tuple(round(oben[i] + (unten[i] - oben[i]) * f) for i in range(3)) + (255,)
        for x in range(k):
            px[x, y] = c
    maske = Image.new("L", (k, k), 0)
    r = params(s)[5] * SS
    ImageDraw.Draw(maske).rounded_rectangle([0, 0, k - 1, k - 1], radius=r, fill=255)
    bild = Image.new("RGBA", (k, k), (0, 0, 0, 0))
    bild.paste(verlauf, (0, 0), maske)
    if raster:
        # eigene Ebene + alpha_composite: direkt gezeichnet würde die Linie die Deckkraft ersetzen
        linien = Image.new("RGBA", (k, k), (0, 0, 0, 0))
        dl = ImageDraw.Draw(linien)
        n = 8
        for i in range(1, n):
            p = round(i * k / n)
            dl.line([(p, 0), (p, k)], fill=(255, 255, 255, 22), width=SS)
            dl.line([(0, p), (k, p)], fill=(255, 255, 255, 22), width=SS)
        linien.putalpha(Image.composite(linien.getchannel("A"), Image.new("L", (k, k), 0), maske))
        bild = Image.alpha_composite(bild, linien)
    d = ImageDraw.Draw(bild)
    breite = max(SS, round(k / 64))
    d.rounded_rectangle([breite // 2, breite // 2, k - 1 - breite // 2, k - 1 - breite // 2],
                        radius=r, outline=rand, width=breite)
    return bild


def kreuz(s, ring=True, luecke=True):
    """Grüne Ebene: vier Arme, Mittelpunkt, optional Ring - in Überabtastung."""
    k = s * SS
    t, g, L, rr, rw, _ = params(s)
    if not luecke:
        g = t // 2
    ebene = Image.new("RGBA", (k, k), (0, 0, 0, 0))
    d = ImageDraw.Draw(ebene)
    c = s / 2
    def rect(x0, y0, x1, y1):
        d.rectangle([round(x0 * SS), round(y0 * SS), round(x1 * SS) - 1, round(y1 * SS) - 1], fill=GRUEN + (255,))
    if ring and rr:   # zuerst, damit die Arme ihn sauber überdecken
        d.ellipse([(c - rr) * SS, (c - rr) * SS, (c + rr) * SS, (c + rr) * SS],
                  outline=GRUEN_RING, width=round(rw * SS))
    h = t / 2
    rect(c + g, c - h, c + L, c + h)
    rect(c - L, c - h, c - g, c + h)
    rect(c - h, c + g, c + h, c + L)
    rect(c - h, c - L, c + h, c - g)
    rect(c - h, c - h, c + h, c + h)
    return ebene


def leuchten(ebene, s):
    if s < 48:
        return None
    glow = ebene.filter(ImageFilter.GaussianBlur(s * SS / 28))
    a = glow.getchannel("A").point(lambda v: round(v * 0.55))
    glow.putalpha(a)
    return glow


def stift(s):
    """Bleistift diagonal unten rechts, Spitze zur Mitte."""
    k = s * SS
    ebene = Image.new("RGBA", (k, k), (0, 0, 0, 0))
    d = ImageDraw.Draw(ebene)
    import math
    p0 = (0.57 * k, 0.57 * k)          # Spitze, lässt den Mittelpunkt frei
    p1 = (0.87 * k, 0.87 * k)          # Ende, bleibt in der runden Ecke
    laenge = math.dist(p0, p1)
    ux, uy = (p1[0] - p0[0]) / laenge, (p1[1] - p0[1]) / laenge
    nx, ny = -uy, ux
    w = (0.20 if s >= 32 else 0.26) * k / 2

    def pkt(a, b):  # a: entlang, b: quer
        return (p0[0] + ux * a + nx * b, p0[1] + uy * a + ny * b)

    def band(a0, a1, farbe):
        d.polygon([pkt(a0, -w), pkt(a1, -w), pkt(a1, w), pkt(a0, w)], fill=farbe)

    spitze = laenge * 0.26
    rand = max(SS, round(k * 0.035))
    # dunkler Umriss für Abstand zum Kreuz
    umriss = [pkt(0, 0), pkt(spitze, -w), pkt(laenge, -w), pkt(laenge, w), pkt(spitze, w)]
    d.polygon(umriss, outline=(10, 12, 15, 255), width=rand * 2)
    d.polygon([pkt(0, 0), pkt(spitze, -w), pkt(spitze, w)], fill=(236, 205, 160, 255))   # Holz
    d.polygon([pkt(0, 0), pkt(spitze * 0.38, -w * 0.38), pkt(spitze * 0.38, w * 0.38)], fill=(40, 40, 46, 255))  # Mine
    band(spitze, laenge * 0.80, (255, 184, 77, 255))                                        # Körper
    if s >= 32:   # Glanzlinie
        d.line([pkt(spitze, 0), pkt(laenge * 0.80, 0)], fill=(255, 210, 130, 255), width=max(SS, round(k * 0.012)))
    band(laenge * 0.80, laenge * 0.88, (160, 168, 178, 255))                                # Zwinge
    band(laenge * 0.88, laenge, (255, 122, 138, 255))                                       # Radierer
    return ebene


def fertig(ebenen, s):
    k = s * SS
    bild = Image.new("RGBA", (k, k), (0, 0, 0, 0))
    for e in ebenen:
        if e is not None:
            bild = Image.alpha_composite(bild, e)
    return bild.reduce(SS)


def fadenkreuz_icon(s):
    hg = hintergrund(s, (30, 34, 41), (16, 18, 22), (60, 68, 80, 255))
    kr = kreuz(s)
    return fertig([hg, leuchten(kr, s), kr], s)


def editor_icon(s):
    hg = hintergrund(s, (28, 34, 48), (15, 18, 26), (62, 74, 96, 255), raster=True)
    kr = kreuz(s, ring=False)
    return fertig([hg, leuchten(kr, s), kr, stift(s)], s)


def als_ico(bilder, ziel):
    daten = []
    for b in bilder:
        puffer = io.BytesIO()
        b.save(puffer, "PNG", optimize=True)
        daten.append(puffer.getvalue())
    kopf = struct.pack("<HHH", 0, 1, len(bilder))
    eintraege, offset = b"", 6 + 16 * len(bilder)
    for b, d in zip(bilder, daten):
        w = b.width if b.width < 256 else 0
        eintraege += struct.pack("<BBBBHHII", w, w, 0, 0, 1, 32, len(d), offset)
        offset += len(d)
    Path(ziel).write_bytes(kopf + eintraege + b"".join(daten))


def main():
    wurzel = Path(__file__).resolve().parent.parent
    kreuze = [fadenkreuz_icon(s) for s in GROESSEN]
    editoren = [editor_icon(s) for s in GROESSEN]
    als_ico(kreuze, wurzel / "src" / "fadenkreuz.ico")
    als_ico(editoren, wurzel / "editor" / "editor.ico")
    editoren[GROESSEN.index(64)].save(wurzel / "editor" / "editor-symbol.png", optimize=True)   # Fenstersymbol des Editors
    print("src/fadenkreuz.ico, editor/editor.ico, editor/editor-symbol.png geschrieben")

    if len(sys.argv) > 1:
        # Vorschau je Zeile: alle Größen 1:1, das 32er 8-fach vergrößert, das 256er auf hellem Grund
        breite = sum(GROESSEN) + 10 * len(GROESSEN) + 256 * 2 + 60
        tafel = Image.new("RGBA", (breite, 2 * 300), (24, 26, 30, 255))
        for zeile, satz in enumerate([kreuze, editoren]):
            x = 10
            y = zeile * 300 + 22
            for b in satz:
                tafel.alpha_composite(b, (x, y + 256 - b.height))
                x += b.width + 10
            x += 20
            tafel.alpha_composite(satz[3].resize((256, 256), Image.NEAREST), (x, y))   # 32er vergrößert
            x += 266
            hell = Image.new("RGBA", (256 + 20, 256 + 20), (215, 218, 222, 255))
            hell.alpha_composite(satz[-1], (10, 10))
            tafel.alpha_composite(hell, (x - 10, y - 10))
        tafel.convert("RGB").save(sys.argv[1])
        print("Vorschau:", sys.argv[1])


if __name__ == "__main__":
    main()
