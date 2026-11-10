#!/bin/bash
set -euo pipefail

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
SOURCE=/usr/share/applications/org.kde.dolphin.desktop
TARGET="$APP_DIR/org.kde.dolphin.desktop"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gnome-toolkit"
CHECKSUM="$STATE_DIR/dolphin-desktop.sha256"

if ! dpkg-query -W -f='${Status}' dolphin 2>/dev/null | grep -q '^install ok installed$'; then
    sudo apt install -y dolphin
fi
mkdir -p "$APP_DIR" "$STATE_DIR"
if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    if [ ! -f "$CHECKSUM" ] || [ -L "$TARGET" ] || [ "$(sha256sum "$TARGET")" != "$(cat "$CHECKSUM")" ]; then
        echo "Dolphin desktop entry has existing or user-edited content: $TARGET" >&2
        echo "It was not overwritten. Inspect and back it up before removing it and rerunning this installer." >&2
        exit 1
    fi
fi
if [ ! -f "$SOURCE" ]; then
    echo "Dolphin system desktop entry not found: $SOURCE" >&2
    exit 1
fi
tmp=$(mktemp "$APP_DIR/.dolphin-desktop.XXXXXXXX")
trap 'rm -f "$tmp"' EXIT
# Reject unfamiliar launch commands rather than silently changing their semantics.
if ! awk '
    /^\[Desktop Entry\]$/ { main=1; next }
    /^\[/ { main=0 }
    /^Exec=/ { if (!main) bad=1 }
    main && /^Exec=/ { count++; if ($0 != "Exec=dolphin %u") bad=1 }
    END { exit !(count == 1 && !bad) }
' "$SOURCE"; then
    echo "Unsupported Dolphin desktop entry Exec; inspect $SOURCE before installing." >&2
    exit 1
fi
awk '
    /^\[Desktop Entry\]$/ { main=1; print; next }
    /^\[/ { main=0 }
    main && /^DBusActivatable=/ { print "DBusActivatable=false"; next }
    main && /^Exec=/ { print "Exec=env QT_QPA_PLATFORM=xcb dolphin %u"; next }
    { print }
' "$SOURCE" > "$tmp"
chmod 644 "$tmp"
mv "$tmp" "$TARGET"
sha256sum "$TARGET" > "$CHECKSUM"
echo "Dolphin XWayland desktop entry installed: $TARGET"
