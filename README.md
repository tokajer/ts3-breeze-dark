# TS3 Breeze Dark

Ein durchgängiges **KDE-Breeze-Dark**-Theme für den TeamSpeak-3-Client unter Linux.

![Screenshot des TeamSpeak-Clients im Breeze-Dark-Theme](docs/screenshot.png)

Anders als die meisten TS3-Dark-Themes färbt dieses nicht nur die offensichtlichen
Widgets ein, sondern deckt auch die drei Stellen ab, an denen sonst helle Reste
durchschlagen:

- **Chatverlauf und Info-Fenster** über eine eigene `Breeze_chat.qss`. Fehlt diese
  Datei, greift TeamSpeaks helles `default_chat.qss` — dunkelblaue Links und
  schwarze Schrift auf dunklem Grund.
- **Baum-Tooltips** über umgestellte Vorlagen. Die mitgelieferten Templates sind
  hart auf Weiß/Schwarz verdrahtet.
- **Die Qt-Palette** über Werte, die TeamSpeak aus dem Stylesheet-Kommentar
  ausliest. Damit werden auch Dinge dunkel, die per QSS gar nicht erreichbar sind:
  Links im Chat, nativ gezeichnete Pfeile, Platzhaltertexte und die
  Zustandsfarben im Serverbaum (Freund, Blockiert, Aufnahme, Abwesend, Stumm).

## Installation

### Linux

```bash
git clone <repo-url> ts3-breeze-dark
cd ts3-breeze-dark
./install.sh --icons
```

Das Skript erkennt Flatpak- und klassische Installation automatisch.

### Windows

In PowerShell, im entpackten Ordner:

```powershell
git clone <repo-url> ts3-breeze-dark
cd ts3-breeze-dark
.\install.ps1 -Icons
```

Falls PowerShell die Ausführung blockiert, für diese eine Sitzung erlauben:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Bei einer **portablen Installation** liegt die Konfiguration im Programmordner
statt unter `%APPDATA%`. Dann den Pfad mitgeben:

```powershell
.\install.ps1 -Icons -ConfigPath "D:\TeamSpeak3"
```

`-Icons` benötigt Python 3. Ohne Python wird der Style trotzdem installiert und
nur das Icon-Pack übersprungen.

### Danach (alle Systeme)

1. TeamSpeak **komplett beenden und neu starten** — Palettenwerte werden nur beim
   Start gelesen, ein Umschalten im laufenden Client genügt nicht.
2. Extras → Optionen → Design → **Style: Breeze**
3. Mit `--icons` / `-Icons` zusätzlich: Extras → Optionen → Design →
   **Icon-Pack: breeze_dark_mono**

### Manuell

Diese drei Dinge in den Konfigurationsordner kopieren:

```
styles/Breeze.qss
styles/Breeze_chat.qss
styles/Breeze/*.tpl
```

| System | Konfigurationsordner |
|---|---|
| Windows | `%APPDATA%\TS3Client\` |
| Windows, portabel | Programmordner der Installation |
| Linux, Flatpak | `~/.var/app/com.teamspeak.TeamSpeak3/.ts3client/` |
| Linux, klassisch | `~/.ts3client/` |
| macOS | `~/Library/Application Support/TeamSpeak 3/` |

Unter Windows erreichst du den Ordner am schnellsten über `Win`+`R` und die
Eingabe `%APPDATA%\TS3Client`.

Zwei Namensregeln, die der Client fest verdrahtet hat:

- Der Ordner unter `styles/` muss exakt so heißen wie die `.qss` ohne Endung —
  die Vorlagen werden unter `styles/<Stylename>/` gesucht.
- Die Chat-Datei muss `<Stylename>_chat.qss` heißen.

## Aufbau

| Datei | Zweck |
|---|---|
| `styles/Breeze.qss` | Widgets, Qt-Palette, TeamSpeak-spezifische Objektnamen |
| `styles/Breeze_chat.qss` | Chatverlauf und Info-Fenster (HTML-Teilmenge) |
| `styles/Breeze/*.tpl` | Vorlagen für Info-Fenster und Baum-Tooltips |
| `tools/build-iconpack.py` | erzeugt ein dunkeltaugliches Icon-Pack |
| `install.sh` | Installation unter Linux und macOS |
| `install.ps1` | Installation unter Windows |

## Farben

| Rolle | Wert |
|---|---|
| Fenster | `#31363b` |
| Ansicht / Base | `#232629` |
| Wechselzeile | `#2a2e32` |
| Text | `#eff0f1` |
| Text gedimmt | `#bdc3c7` |
| Deaktiviert | `#7f8c8d` |
| Rahmen | `#4d5257`, `#76797c` |
| Akzent / Link | `#3daee9` |
| Positiv | `#27ae60` |
| Neutral | `#f67400` |
| Negativ | `#da4453` |

## Icon-Pack

TeamSpeaks Pack `default_mono_2014` zeichnet seine Glyphen in `#404547`. Gegen den
Fensterhintergrund `#31363b` ist das ein Kontrastverhältnis nahe 1:1 — die Icons
erscheinen als dunkle Klötze. `tools/build-iconpack.py` liest das installierte
Original, färbt die SVGs um und legt `breeze_dark_mono.zip` ab.

Weiß wird dabei mit umgekehrt: im Original dient es als Aussparung *auf* dem
dunklen Glyph, etwa das X im Trennen-Icon. Bliebe es weiß, verschwände es im nun
hellen Glyph.

Die umgefärbten Grafiken liegen **nicht** im Repository — es sind abgeleitete
Werke aus TeamSpeaks Icon-Pack. Das Skript baut sie lokal aus deiner Installation.

Es findet das Original selbst; falls nicht, den Pfad mitgeben:

```bash
# Linux
python3 tools/build-iconpack.py --install

# Windows
python tools\build-iconpack.py --install
python tools\build-iconpack.py --install --source "C:\Program Files\TeamSpeak 3 Client\gfx\default_mono_2014.zip"
```

Ohne `--install` landet das Zip im aktuellen Ordner und kann von Hand nach
`gfx\` im Konfigurationsordner kopiert werden.

## Notizen zu Qt 5

TeamSpeak 3 nutzt Qt 5. Zwei Fallstricke, die dort anders wirken als in Qt 6 und
die beim Anpassen dieses Themes teuer waren:

**Teilweise gestylte Subcontrols werden schwarz.** Sobald ein Widget per
Stylesheet angefasst wird, zeichnet Qt seine Subcontrols über das Stylesheet. Jede
Zone, für die keine Füllfarbe definiert ist, bleibt ungemalt — und ungemalte
Fläche ist schwarz. Betroffen sind unter anderem:

- `QToolButton::menu-button` — Knöpfe mit Aufklappmenü teilt Qt in Hauptfläche und
  Menüzone. Wird nur `QToolButton` gestylt, erscheint die Menüzone als schwarzer
  Balken.
- `QSlider::add-page` / `::sub-page` — beide Seiten brauchen eine Farbe, nicht nur
  die gefüllte.
- `QScrollBar::add-page` / `::sub-page`, `QToolBar::handle`, `QToolBar::separator`.

**Selbstgebaute CSS-Dreieck-Pfeile funktionieren nicht.** Das gängige Muster

```css
QComboBox::down-arrow {
    image: none;
    width: 0; height: 0;
    border-left: 4px solid transparent;
    border-right: 4px solid transparent;
    border-top: 5px solid #eff0f1;
}
```

rendert unter Qt 5 die transparenten Rahmen als schwarze Fläche. Dieses Theme
verzichtet deshalb komplett auf eigene Pfeile und überlässt sie Qt — über die
gesetzte Palette werden sie automatisch hell.

Wer eigene Regeln ergänzt: der schnellste Test bei schwarzen Flächen ist, das
Stylesheet testweise zu leeren und neu zu starten. Im hellen Standard-Theme sieht
man sofort, welches Element an der Stelle eigentlich sitzt.

## Palettenwerte im Stylesheet

TeamSpeak parst zwei Muster aus der `.qss` — auch aus Kommentaren:

```
QPalette::<Rolle>       = <Farbe>;
CustomColor::<Name>     = <Farbe>;
```

Unterstützt sind die Qt-Rollen (`Window`, `Base`, `Text`, `Highlight`, `Link` …)
sowie `ClientFriend`, `ClientBlocked`, `ClientRecording`, `ClientAway` und
`ClientMuted`. Die Blockdefinition steht im Kopf von `Breeze.qss`.

## Lizenz

Die Stylesheets und Skripte stehen unter der MIT-Lizenz (siehe `LICENSE`).

Die Vorlagen unter `styles/Breeze/` basieren auf den mit TeamSpeak 3
ausgelieferten Templates (© TeamSpeak Systems GmbH) und sind lediglich umgefärbt.
Die Icon-Grafiken gehören ebenfalls TeamSpeak Systems GmbH und werden nicht
mitverteilt.

## If you like my work you can

[![Buy me a coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=☕&slug=tokajer&button_colour=1e4c7a&font_colour=ffffff&font_family=Inter&outline_colour=ffffff&coffee_colour=FFDD00)](https://www.buymeacoffee.com/tokajer)
