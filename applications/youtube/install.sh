#!/bin/bash
set -Ceu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

mkdir -p "$BIN_DIR" "$APP_DIR"

chmod +x "${SCRIPT_DIR}/youtube"
ln -sf "${SCRIPT_DIR}/youtube" "${BIN_DIR}/youtube"
ln -sf "${SCRIPT_DIR}/youtube.desktop" "${APP_DIR}/youtube.desktop"

update-desktop-database "$APP_DIR"

echo "Done: youtube installed"
exit 0
