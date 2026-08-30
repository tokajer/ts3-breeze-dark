#!/usr/bin/env bash
# Installs the Breeze Dark style into the TeamSpeak 3 configuration.
#
#   ./install.sh              # install the style
#   ./install.sh --icons      # also build and place the icon pack
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prefer a Flatpak installation, fall back to the classic path
FLATPAK="$HOME/.var/app/com.teamspeak.TeamSpeak3/.ts3client"
PLAIN="$HOME/.ts3client"

if [[ -d "$FLATPAK" ]]; then
    TS3="$FLATPAK"
elif [[ -d "$PLAIN" ]]; then
    TS3="$PLAIN"
else
    echo "No TeamSpeak 3 configuration folder found." >&2
    echo "Expected: $FLATPAK or $PLAIN" >&2
    exit 1
fi

echo "Target folder: $TS3"

# --- Style -----------------------------------------------------------------
mkdir -p "$TS3/styles/Breeze"
install -m 644 "$REPO/styles/Breeze.qss"      "$TS3/styles/Breeze.qss"
install -m 644 "$REPO/styles/Breeze_chat.qss" "$TS3/styles/Breeze_chat.qss"
install -m 644 "$REPO"/styles/Breeze/*.tpl    "$TS3/styles/Breeze/"
echo "Style installed (Breeze.qss, Breeze_chat.qss, 5 templates)"

# --- Icon pack (optional) --------------------------------------------------
if [[ "${1:-}" == "--icons" ]]; then
    echo
    python3 "$REPO/tools/build-iconpack.py" --install
fi

cat <<MSG

Done. Now in TeamSpeak:

  1. Quit the client completely and restart it
     (palette values are only read at startup)
  2. Tools -> Options -> Design -> Style: Breeze
MSG

if [[ "${1:-}" == "--icons" ]]; then
    echo "  3. Tools -> Options -> Design -> Icon pack: breeze_dark_mono"
fi
