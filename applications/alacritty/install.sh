#!/bin/bash
set -Ceu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"

mkdir -p "${CONFIG_DIR}"

ln -sf "${SCRIPT_DIR}" "${CONFIG_DIR}/alacritty"

echo "Done: alacritty installed"
exit 0
