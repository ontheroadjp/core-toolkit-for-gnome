#!/bin/bash
set -Ceu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

mkdir -p "$BIN_DIR" "$APP_DIR"

chmod +x "${SCRIPT_DIR}/google-chrome-cdp"
ln -sf "${SCRIPT_DIR}/google-chrome-cdp" "${BIN_DIR}/google-chrome-cdp"
ln -sf "${SCRIPT_DIR}/google-chrome-cdp.desktop" "${APP_DIR}/google-chrome-cdp.desktop"

update-desktop-database "$APP_DIR"

echo "Done: google-chrome-cdp installed"
exit 0
