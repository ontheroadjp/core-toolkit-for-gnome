#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config"

if [ -e "${CONFIG_DIR}/mpv" ] || [ -L "${CONFIG_DIR}/mpv" ]; then
    if [ ! -L "${CONFIG_DIR}/mpv" ] || [ "$(readlink "${CONFIG_DIR}/mpv")" != "$SCRIPT_DIR" ]; then
        echo "Existing configuration preserved: ${CONFIG_DIR}/mpv" >&2
        exit 1
    fi
fi

sudo apt install -y ffmpeg mpv

mkdir -p "${BIN_DIR}" "${CONFIG_DIR}"

chmod +x "${SCRIPT_DIR}/mpv-player.py"
ln -sfn "${SCRIPT_DIR}/mpv-player.py" "${BIN_DIR}/mpv-player"

ln -sfn "${SCRIPT_DIR}" "${CONFIG_DIR}/mpv"

echo "Done: mpv-player installed"
exit 0
