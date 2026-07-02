#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config"

sudo apt install -y ffmpeg mpv

mkdir -p "${BIN_DIR}" "${CONFIG_DIR}"

chmod +x "${SCRIPT_DIR}/mpv-music-player.py"
chmod +x "${SCRIPT_DIR}/mpv-video-player.sh"
ln -sfn "${SCRIPT_DIR}/mpv-music-player.py" "${BIN_DIR}/mpv-music-player"
ln -sfn "${SCRIPT_DIR}/mpv-video-player.sh" "${BIN_DIR}/mpv-video-player"

ln -sfn "${SCRIPT_DIR}" "${CONFIG_DIR}/mpv"

echo "Done: mpv-player installed"
exit 0
