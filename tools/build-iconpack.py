#!/usr/bin/env python3
"""Builds an icon pack suitable for Breeze Dark from TeamSpeak 3's own pack.

TeamSpeak's "default_mono_2014" pack draws its glyphs in #404547. Against the
Breeze Dark background #31363b that is practically invisible -- the icons show
up as dark blobs. This script reads the installed original, recolors the SVGs
and writes a new zip.

The original graphics belong to TeamSpeak Systems GmbH and are therefore not
part of the repository. The pack is built locally from your installation.

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

# Source color -> Breeze Dark equivalent.
# White is inverted along with the rest: in the original it is a cut-out *on
# top of* the dark glyph (the X in the disconnect icon, for example). Left
# white it would disappear into the now-light glyph.
COLOR_MAP = {
    "404547": "#EFF0F1",  # main glyph (dark gray) -> Breeze text
    "101719": "#BDC3C7",  # near black -> dimmed gray
    "00325A": "#3DAEE9",  # dark navy -> Breeze blue
    "FFFFFF": "#31363B",  # cut-out -> window color
    "FEFEFE": "#31363B",
    "9BA096": "#C6CBC2",  # olive gray -> lightened
    "B7B9BA": "#5A5F63",  # light gray -> darkened
}

HEX = re.compile(r"#([0-9a-fA-F]{6})\b")

# Emoticons are colorful smileys and stay untouched.
SKIP_DIRS = {"emoticons"}

def gfx_dirs() -> list[Path]:
    """Possible gfx folders on Linux, Windows and macOS."""
    home = Path.home()
    dirs: list[Path] = []

    # Linux: Flatpak installation (system-wide and per user)
    for base in (
        Path("/var/lib/flatpak/app/com.teamspeak.TeamSpeak3"),
        home / ".local/share/flatpak/app/com.teamspeak.TeamSpeak3",
    ):
        if base.is_dir():
            dirs += sorted(d for d in base.glob("*/*/*/files/extra/gfx") if d.is_dir())

    # Linux: classic installation and user folder
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
    """Locates the original zip in the usual installation paths."""
    if explicit:
        p = Path(explicit).expanduser()
        if not p.is_file():
            sys.exit(f"Not found: {p}")
        return p

    for d in gfx_dirs():
        candidate = d / name
        if candidate.is_file():
            return candidate

    sys.exit(
        f"{name} not found. Pass the path with --source, for example:\n"
        "  Linux:   --source /var/lib/flatpak/app/com.teamspeak.TeamSpeak3/"
        "x86_64/stable/<hash>/files/extra/gfx/default_mono_2014.zip\n"
        '  Windows: --source "C:\\Program Files\\TeamSpeak 3 Client\\gfx\\'
        'default_mono_2014.zip"'
    )


def config_dir() -> Path:
    """TeamSpeak 3 user configuration folder."""
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
    ap.add_argument("--source", help="path to default_mono_2014.zip (autodetected otherwise)")
    ap.add_argument("--pack-name", default="default_mono_2014", help="name of the source pack")
    ap.add_argument("--output", default="breeze_dark_mono.zip", help="output file")
    ap.add_argument(
        "--install",
        action="store_true",
        help="write straight into the gfx folder of the TeamSpeak configuration",
    )
    args = ap.parse_args()

    source = find_source(args.source, args.pack_name + ".zip")
    print(f"Source: {source}")

    if args.install:
        output = config_dir() / "gfx" / Path(args.output).name
    else:
        output = Path(args.output).expanduser()

    changed, kept = build(source, output)
    print(f"{changed} SVGs recolored, {kept} files copied unchanged")
    print(f"Written: {output}")
    if args.install:
        print("\nActivate: Tools -> Options -> Design -> Icon pack -> "
              f"{output.stem}")


if __name__ == "__main__":
    main()
