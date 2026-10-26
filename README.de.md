# Fadenkreuz 🎯

**Dein eigenes Fadenkreuz exakt in der Bildschirmmitte – selbst gezeichnet, mit rund 1 MB Arbeitsspeicher.** Ein winziges Windows-Overlay, das über deinem Spiel liegt, jeden Klick durchlässt und zeigt, was du im Editor gezeichnet hast. Ab Werk Neongrün auf Schwarz.

![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-33ff88) ![RAM](https://img.shields.io/badge/RAM-rund%201%20MB-0b0d0c) ![Sprache](https://img.shields.io/badge/Sprache-Deutsch-33ff88) ![Lizenz](https://img.shields.io/badge/Lizenz-MIT-0b0d0c)

[English version](README.md)

![Der Editor: ein grünes Kreuz mit dünnem schwarzem Rand auf kariertem Raster, rechts eigene Fadenkreuze und Vorlagen, darunter eine 4-fache Vorschau vor einer Spielszene](docs/editor.webp)

---

## Wofür

Manche Spiele haben kein Fadenkreuz, ein schlechtes oder blenden es beim Schießen aus der Hüfte aus. Fadenkreuz legt dein eigenes darüber: genau in die Mitte des Hauptbildschirms, immer im Vordergrund, und Klicks gehen direkt ans Spiel durch.

Werkzeuge wie Crosshair X machen das über die Xbox Game Bar – das funktioniert gut, aber die Game Bar selbst braucht viel Arbeitsspeicher, und beim Spielen ist davon oft nichts übrig. Fadenkreuz ist ein 55 KB kleines Windows-Programm ohne Laufzeitumgebung. Im Betrieb braucht es rund 1 MB, davon nur etwa 0,2 MB für sich allein; der Rest sind Windows-Bibliotheken, die sich alle Programme teilen.

## Zwei Teile, getrennt installierbar

| | |
|---|---|
| **Fadenkreuz** – das Overlay | in C geschrieben, ohne Frameworks. Liest `Dokumente\Fadenkreuz\fadenkreuz.bmp` und übernimmt jede Änderung innerhalb einer Sekunde. |
| **Editor** – zum Zeichnen | eine einzelne Seite, die sich als eigenes, schlankes Edge-Fenster öffnet. Sie braucht nur Speicher, solange sie offen ist. |

Im Installer wählst du beide oder nur einen der beiden. Sie hängen nicht voneinander ab: Das Overlay läuft ohne Editor, und der Editor zeichnet auch, wenn das Overlay aus ist.

## So geht’s los

1. Lade **`Fadenkreuz-Setup-1.0.0.exe`** aus den [Releases](../../releases/latest). Windows meldet „Unbekannter Herausgeber“ – das Setup ist nicht signiert, weil das Geld kostet. Weiter mit **Weitere Informationen → Trotzdem ausführen**.
2. Wähle **nur für mich** (ohne Adminrechte) oder **für alle Benutzer**, dann die Teile, die du willst.
3. Starte **Fadenkreuz**: In der Bildschirmmitte erscheint ein grünes Kreuz.
4. Öffne den **Fadenkreuz-Editor**, zeichne, klick einmal auf **Speichern unter …** und speichere als `fadenkreuz.bmp` in `Dokumente\Fadenkreuz`. Der Editor merkt sich die Datei; mit **live** erscheint jeder Strich innerhalb einer Sekunde auf dem Bildschirm.

## Tasten

| | |
|---|---|
| <kbd>Strg</kbd>+<kbd>Alt</kbd>+<kbd>F9</kbd> | Fadenkreuz aus- und wieder einblenden |
| <kbd>Strg</kbd>+<kbd>Alt</kbd>+<kbd>F10</kbd> | **im Spiel** drücken: ab dann erscheint das Kreuz nur, solange dieses Spiel vorne ist. Noch einmal drücken streicht das Spiel wieder. |
| <kbd>Strg</kbd>+<kbd>Alt</kbd>+<kbd>F12</kbd> | beenden – oder Fadenkreuz einfach ein zweites Mal starten |

## Der Editor

![Die Vorlage „Oval weiß“: ein weißes Oval mit geglätteten Kanten und weichem schwarzem Rand vor einer Szene](docs/oval.webp)

- **Werkzeuge:** Stift, Radierer, Linie, Ring, gefülltes Oval, Füllen und Pipette; die rechte Maustaste radiert immer.
- **Spiegeln** links/rechts, oben/unten oder 4-fach – ein symmetrisches Kreuz in wenigen Strichen.
- **Umrandung** 0 bis 4 Pixel in jeder Farbe und Deckkraft, auf Wunsch weich auslaufend.
- **Vorlagen:** Kreuz, Kreuz + Punkt, Punkt, Punkt rund, T, X, Ring + Punkt und **Oval weiß** – ein weißes Oval mit geglätteten Kanten und weichem schwarzem Rand. Größe, Dicke und Lücke sind einstellbar.
- **Meine Fadenkreuze:** eigene Entwürfe unter einem Namen merken, mit einem Klick laden und alle zusammen als Datei sichern (oder wieder einlesen, etwa auf einem anderen PC).
- **Vorschau** in echter Größe (1:1), 2× oder 4× vor einer Spielszene, dunkel oder hell.
- Rückgängig und Wiederholen, einstellbare Feldgröße, ein pixelgenaues Raster mit markierter Mitte.

Edge und Chrome speichern direkt in die Datei. Firefox kann das nicht und lädt das Bild stattdessen herunter.

## Nur in bestimmten Spielen

Drück <kbd>Strg</kbd>+<kbd>Alt</kbd>+<kbd>F10</kbd>, während ein Spiel vorne ist, und Fadenkreuz trägt es in `Dokumente\Fadenkreuz\programme.txt` ein. Solange die Liste Einträge hat, erscheint das Kreuz nur, während eines dieser Programme vorne ist – wechselst du auf den Desktop, verschwindet es. Leere Liste heißt: immer sichtbar. Die Datei lässt sich auch von Hand bearbeiten, ein `.exe`-Name pro Zeile.

## Über allem (auf Wunsch)

Normalerweise ist das Kreuz ein „immer oben“-Fenster: über deinem Spiel, aber unter Startmenü, Taskleisten-Fenstern und manchen Overlays. Installierst du **für alle Benutzer**, bietet das Setup **Über allem anzeigen** an.

Das erlaubt Windows (es heißt *UIAccess*, wie bei der Bildschirmtastatur) nur signierten Programmen im Ordner *Programme*. Darum legt das Setup ein Zertifikat an, das nur auf diesem PC gilt, signiert Fadenkreuz damit und löscht den privaten Schlüssel sofort wieder – damit kann niemand etwas anderes signieren. Beim Deinstallieren verschwindet das Zertifikat wieder. Geht dabei etwas schief, bleibt die normale Fassung.

## Grenzen

- **Nur der Hauptbildschirm.**
- Spiele im **exklusiven Vollbild** übermalen jedes Overlay. Stell das Spiel auf *randloses Fenster* bzw. *Vollbild im Fenster*.
- **Anti-Cheat:** Fadenkreuz fasst das Spiel nicht an – es ist ein eigenes Fenster. Trotzdem mögen einige Wettkampf-Spiele keine Overlays; prüf das vor Ranglisten-Spielen.
- Editor und Setup sprechen Deutsch (das Setup auch Englisch).

## Bildformat

`fadenkreuz.bmp` ist ein 32-Bit-BMP mit Transparenz, oder ein 24-Bit-BMP, in dem Magenta `#FF00FF` als durchsichtig gilt – damit geht sogar Paint. Bei ungerader Größe landet der Mittelpixel genau in der Bildschirmmitte.

Wo Fadenkreuz seine Dateien sucht, in dieser Reihenfolge: ein Ordner oder eine `.bmp` als Argument → der Ordner aus einer `datenordner.txt` neben der exe → der Ordner der exe, wenn dort schon eine `fadenkreuz.bmp` liegt (tragbar) → `Dokumente\Fadenkreuz`.

## Privatsphäre

Fadenkreuz geht nie ins Internet: keine Zählung, keine Update-Prüfung, kein Konto. Der Editor ist eine lokale Datei ohne fremde Quellen. Deine Presets liegen im Speicher des Browsers und in Dateien, die du selbst sicherst.

## Selbst bauen

Du brauchst Visual Studio oder die Build Tools mit den C++-Werkzeugen und für den Installer [Inno Setup 6](https://jrsoftware.org/isinfo.php). Dann:

```
bauen.bat
```

Das ergibt `build\fadenkreuz.exe`, `build\fadenkreuz-oben.exe` (die UIAccess-Fassung) und `build\Fadenkreuz-Setup-1.0.0.exe`. Die Icons zeichnet `tools\icons.py` (Python mit Pillow).

| Ordner | Inhalt |
|---|---|
| `src/` | das Overlay in C, Ressourcen, Icon |
| `editor/` | die Editor-Seite und ihr Icon |
| `installer/` | Inno-Setup-Skript und der UIAccess-Helfer |
| `tools/` | Icon-Generator |
| `docs/` | Bildschirmfotos |

## Lizenz

MIT – siehe [LICENSE](LICENSE). © 2026 Dennis_mit_2n

Teil der Werkstatt auf **[dennismit2n.github.io](https://dennismit2n.github.io/)**.
