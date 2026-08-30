#!/usr/bin/env python3
"""Erzeugt ein Breeze-Dark-taugliches Icon-Pack fuer TeamSpeak 3.

TeamSpeaks Pack "default_mono_2014" zeichnet seine Glyphen in #404547.
Auf dem Breeze-Dark-Hintergrund #31363b ist das praktisch unsichtbar --
die Icons erscheinen als dunkle Kloetze. Dieses Skript liest das
installierte Original, faerbt die SVGs um und schreibt ein neues Zip.

Die Originalgrafiken gehoeren TeamSpeak Systems GmbH und liegen deshalb
nicht im Repository. Das Pack wird lokal aus deiner Installation gebaut.

    python3 tools/build-iconpack.py --install
"""

from __future__ import annotations

import argparse
import os
import re
import sys
import tempfile
import zipfile
from pathlib import Path

# Quellfarbe -> Breeze-Dark-Entsprechung.
# Weiss wird mit umgekehrt: es dient im Original als Aussparung *auf* dem
# dunklen Glyph (etwa das X im Trennen-Icon). Bleibt es weiss, verschwindet
# es im nun hellen Glyph.
COLOR_MAP = {
    "404547": "#EFF0F1",  # Hauptglyph (dunkelgrau) -> Breeze-Text
    "101719": "#BDC3C7",  # fast schwarz -> gedimmtes Grau
    "00325A": "#3DAEE9",  # dunkles Navy -> Breeze-Blau
    "FFFFFF": "#31363B",  # Aussparung -> Fensterfarbe
    "FEFEFE": "#31363B",
    "9BA096": "#C6CBC2",  # Olivgrau -> aufgehellt
    "B7B9BA": "#5A5F63",  # helles Grau -> abgedunkelt
}

HEX = re.compile(r"#([0-9a-fA-F]{6})\b")

# Emoticons sind bunte Smileys und bleiben unangetastet.
SKIP_DIRS = {"emoticons"}

def gfx_dirs() -> list[Path]:
    """Moegliche gfx-Ordner auf Linux, Windows und macOS."""
    home = Path.home()
    dirs: list[Path] = []

    # Linux: Flatpak-Installation (Systemweit und pro Benutzer)
    for base in (
        Path("/var/lib/flatpak/app/com.teamspeak.TeamSpeak3"),
        home / ".local/share/flatpak/app/com.teamspeak.TeamSpeak3",
    ):
        if base.is_dir():
            dirs += sorted(d for d in base.glob("*/*/*/files/extra/gfx") if d.is_dir())

    # Linux: klassische Installation und Benutzerordner
    dirs += [
        home / ".var/app/com.teamspeak.TeamSpeak3/.ts3client/gfx",
        home / ".ts3client/gfx",
        Path("/opt/teamspeak3/gfx"),
        Path("/usr/share/teamspeak3/gfx"),
    ]

    # Windows
    if appdata := os.environ.get("APPDATA"):
        dirs.append(Path(appdata) / "TS3Client" / "gfx")
    for var in ("ProgramFiles", "ProgramFiles(x86)"):
        if pf := os.environ.get(var):
            dirs.append(Path(pf) / "TeamSpeak 3 Client" / "gfx")

    # macOS
    dirs.append(Path("/Applications/TeamSpeak 3 Client.app/Contents/Resources/gfx"))

    return dirs


def find_source(explicit: str | None, name: str) -> Path:
    """Sucht das Original-Zip in den ueblichen Installationspfaden."""
    if explicit:
        p = Path(explicit).expanduser()
        if not p.is_file():
            sys.exit(f"Nicht gefunden: {p}")
        return p

    for d in gfx_dirs():
        candidate = d / name
        if candidate.is_file():
            return candidate

    sys.exit(
        f"{name} nicht gefunden. Pfad bitte mit --source angeben, etwa:\n"
        "  Linux:   --source /var/lib/flatpak/app/com.teamspeak.TeamSpeak3/"
        "x86_64/stable/<hash>/files/extra/gfx/default_mono_2014.zip\n"
        '  Windows: --source "C:\\Program Files\\TeamSpeak 3 Client\\gfx\\'
        'default_mono_2014.zip"'
    )


def config_dir() -> Path:
    """Benutzerkonfiguration von TeamSpeak 3."""
    home = Path.home()
    if appdata := os.environ.get("APPDATA"):
        win = Path(appdata) / "TS3Client"
        if win.is_dir():
            return win
    flatpak = home / ".var/app/com.teamspeak.TeamSpeak3/.ts3client"
    if flatpak.is_dir():
        return flatpak
    return home / ".ts3client"


def recolor(text: str) -> str:
    return HEX.sub(lambda m: COLOR_MAP.get(m.group(1).upper(), m.group(0)), text)


def build(source: Path, output: Path) -> tuple[int, int]:
    with tempfile.TemporaryDirectory() as tmp:
        work = Path(tmp) / "pack"
        work.mkdir()
        with zipfile.ZipFile(source) as z:
            z.extractall(work)

        changed = kept = 0
        for f in sorted(work.rglob("*")):
            if not f.is_file():
                continue
            rel = f.relative_to(work)
            if f.suffix.lower() == ".svg" and not (set(rel.parts) & SKIP_DIRS):
                f.write_text(recolor(f.read_text(encoding="utf-8", errors="replace")), encoding="utf-8")
                changed += 1
            else:
                kept += 1

        output.parent.mkdir(parents=True, exist_ok=True)
        if output.exists():
            output.unlink()
        with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as z:
            for f in sorted(work.rglob("*")):
                if f.is_file():
                    z.write(f, f.relative_to(work))
        return changed, kept


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--source", help="Pfad zu default_mono_2014.zip (sonst automatische Suche)")
    ap.add_argument("--pack-name", default="default_mono_2014", help="Name des Quell-Packs")
    ap.add_argument("--output", default="breeze_dark_mono.zip", help="Zieldatei")
    ap.add_argument(
        "--install",
        action="store_true",
        help="direkt in den gfx-Ordner der TeamSpeak-Konfiguration schreiben",
    )
    args = ap.parse_args()

    source = find_source(args.source, args.pack_name + ".zip")
    print(f"Quelle: {source}")

    if args.install:
        output = config_dir() / "gfx" / Path(args.output).name
    else:
        output = Path(args.output).expanduser()

    changed, kept = build(source, output)
    print(f"{changed} SVGs umgefaerbt, {kept} Dateien unveraendert uebernommen")
    print(f"Geschrieben: {output}")
    if args.install:
        print("\nAktivieren: Extras -> Optionen -> Design -> Icon-Pack -> "
              f"{output.stem}")


if __name__ == "__main__":
    main()
