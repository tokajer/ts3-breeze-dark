#!/usr/bin/env bash
# Installiert den Breeze-Dark-Style in die TeamSpeak-3-Konfiguration.
#
#   ./install.sh              # Style installieren
#   ./install.sh --icons      # zusaetzlich das Icon-Pack bauen und ablegen
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Flatpak-Installation bevorzugen, sonst klassischer Pfad
FLATPAK="$HOME/.var/app/com.teamspeak.TeamSpeak3/.ts3client"
PLAIN="$HOME/.ts3client"

if [[ -d "$FLATPAK" ]]; then
    TS3="$FLATPAK"
elif [[ -d "$PLAIN" ]]; then
    TS3="$PLAIN"
else
    echo "Kein TeamSpeak-3-Konfigurationsordner gefunden." >&2
    echo "Erwartet: $FLATPAK oder $PLAIN" >&2
    exit 1
fi

echo "Zielordner: $TS3"

# --- Style -----------------------------------------------------------------
mkdir -p "$TS3/styles/Breeze"
install -m 644 "$REPO/styles/Breeze.qss"      "$TS3/styles/Breeze.qss"
install -m 644 "$REPO/styles/Breeze_chat.qss" "$TS3/styles/Breeze_chat.qss"
install -m 644 "$REPO"/styles/Breeze/*.tpl    "$TS3/styles/Breeze/"
echo "Style installiert (Breeze.qss, Breeze_chat.qss, 5 Vorlagen)"

# --- Icon-Pack (optional) --------------------------------------------------
if [[ "${1:-}" == "--icons" ]]; then
    echo
    python3 "$REPO/tools/build-iconpack.py" --install
fi

cat <<EOF

Fertig. Jetzt in TeamSpeak:

  1. Client komplett beenden und neu starten
     (Palettenwerte werden nur beim Start gelesen)
  2. Extras -> Optionen -> Design -> Style: Breeze
EOF

if [[ "${1:-}" == "--icons" ]]; then
    echo "  3. Extras -> Optionen -> Design -> Icon-Pack: breeze_dark_mono"
fi
