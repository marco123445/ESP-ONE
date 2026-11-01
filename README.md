# ESP-ONE – DIY-WLAN-Lautsprecher aus dem 3D-Drucker

Kompakter 2-Weg-WLAN-Lautsprecher mit ESP32 und DSP-Verstärker, Gehäuse komplett 3D-gedruckt. Ohne Tasten am Gerät, bedient wird er nur übers Handy bzw. über Home Assistant.

![Vorschau](bilder/vorschau.png)

> **Status:** Konstruktion abgeschlossen, Teile bestellt. Der erste Prototyp ist **noch nicht gebaut und nicht gemessen**. Die DSP-Einstellung (Frequenzweiche, EQ, Hubschutz) wird nach der Messung der Passivmembran ergänzt. Bis dahin den Hochtöner nicht anschliessen (siehe unten).

## Eigenschaften

| | |
|---|---|
| Streaming | Spotify Connect, AirPlay (v1), Multiroom über Music Assistant / Home Assistant (squeezelite-esp32) |
| Stereo | Zwei Lautsprecher als Stereopaar (links/rechts) möglich |
| Prinzip | 2-Weg aktiv: 4"-Tiefmitteltöner + 1"-Hochtöner mit Waveguide + 4"-Passivmembran |
| Verstärker | TI TAS5805M mit eingebautem DSP (Frequenzweiche ca. 2,5 kHz, EQ, Hubschutz) |
| Gehäuse | 154 × 232 × 134 mm, netto 2,57 L, 8-mm-Sandwichwände mit Rippen (Wandresonanzen um 5 kHz) |
| Strom | 18-V-Netzteil, Standby geschätzt ca. 0,6–1 W |
| Druck | 3 Teile + Passprobe, Bambu Lab P1S (256 mm Bauraum), aussen ohne Stützen, ca. 17 h und 0,7 kg pro Lautsprecher |
| Montage | nur M3-Zylinderkopfschrauben und M3-Gewindeeinsätze, alles wieder zerlegbar |

## Teile

Vollständige Liste: **[TEILELISTE.md](TEILELISTE.md)**

Hauptteile pro Lautsprecher:
- Sonocotta **Louder ESP32**, Variante ESP32-WROVER-N8R8 mit externer Antenne (TAS5805M)
- **Visaton W 100 S – 4 Ω** (Art. 9020), **Visaton G 25 NDWG – 8 Ω** (Art. 1188)
- 4"-Passivmembran, Rahmen 105 mm, Ausschnitt 95 mm, Lochkreis 113 mm
- Netzteil **Mean Well GST60A18-P1J**, MKP-Kondensator 22 µF
- 26 × Gewindeeinsatz M3 × L5 × OD4,5; M3-Zylinderkopf: 6 × 10 mm, 9 × 12 mm, 8 × 8 mm, 3 × 6 mm

## Drucken

| Datei | Lage auf dem Bett | Hinweis |
|---|---|---|
| `druck/…/…1_Passprobe.3mf` | flach | **zuerst drucken**: prüft Ausschnitte, Lochbilder, Platinenlöcher, Gewindeeinsatz |
| `druck/…/…2_Korpus.3mf` | Front nach unten | Baumstützen nur ab Druckbett (nur in den zwei Lautsprecher-Taschen) |
| `druck/…/…3_Rueckwand.3mf` | Aussenseite nach unten | ohne Stützen |
| `druck/…/…4_Frontkappe.3mf` | Sichtseite nach unten | ohne Stützen |

- `druck/bambu_PLA/`: fertig geslicte Projekte für **Bambu PLA Basic**
- `druck/bambu_PETG/`: dieselben Teile für **Bambu PETG HF**
- Beide Varianten: P1S, 0,4-mm-Düse, Texture-PEI-Platte
- `druck/stl/`: die nackten STL-Dateien für andere Slicer

**Wichtige Einstellungen**, wenn du selbst slicest:
- Korpus: 0,24 mm, **3 Wandlinien** (die 8-mm-Wand wird so zum steifen Sandwich), 15 % Gyroid
- Rückwand: 0,24 mm, 15 % Gyroid
- Kappe und Passprobe: 0,28 mm, 2 Wände

Bambu Studio warnt „Betttemperatur höher als Erweichungstemperatur“. Das ist bei PLA und PETG normal: Glasdeckel ab oder Fronttür einen Spalt offen lassen.

## Montage

**Bildanleitung: [anleitung/BILDANLEITUNG.pdf](anleitung/BILDANLEITUNG.pdf)**: 10 Seiten, alle Gewindeeinsätze direkt aus dem CAD markiert.

| | | |
|---|---|---|
| ![](anleitung/seiten/seite_01.png) | ![](anleitung/seiten/seite_04.png) | ![](anleitung/seiten/seite_06.png) |

Verdrahtung (alles + an +, der Kondensator kommt in die Plus-Leitung des Hochtöners):

![Verdrahtung](bilder/verdrahtung.png)

## Firmware

- Louder ESP32 mit **squeezelite-esp32** flashen (Web-Installer von Sonocotta).
- Board-Konfiguration: `model=I2S,bck=26,ws=25,do=22,sda=21,scl=27,i2c=45`
- Die DSP-Einstellung für den TAS5805M kommt als `dac_controlset` (JSON) in den NVS-Editor von squeezelite. Sie wird nach der Messung der Passivmembran erstellt und hier ergänzt.

> ⚠ **Hochtöner erst anschliessen, wenn die DSP-Einstellung geladen ist.** Ohne Frequenzweiche bekommt er Bass und kann trotz Kondensator beschädigt werden. Ein erster Test geht nur mit dem Tieftöner.

## CAD

- `cad/espone.scad`: parametrisches OpenSCAD-Modell (Korpus, Rückwand, Frontkappe, Passprobe). Teil wählen mit `part = "body" | "back" | "cap" | "testfit" | "preview"`.
- `cad/kollisionspruefung.scad`: schneidet die Teile paarweise, ein leeres Ergebnis heisst kollisionsfrei. Dafür in `espone.scad` `part = "none"` setzen.
- `cad/render.py`: einfacher Renderer für Vorschaubilder aus STL-Dateien (Python, numpy, Pillow).

| Front | Rückseite | Explosion |
|---|---|---|
| ![](bilder/front.png) | ![](bilder/rueckseite.png) | ![](bilder/explosion.png) |
