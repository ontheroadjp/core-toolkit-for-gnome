#!/bin/bash
set -Ceu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"

if [ -e "${CONFIG_DIR}/alacritty" ] || [ -L "${CONFIG_DIR}/alacritty" ]; then
    if [ ! -L "${CONFIG_DIR}/alacritty" ] || [ "$(readlink "${CONFIG_DIR}/alacritty")" != "$SCRIPT_DIR" ]; then
        echo "Existing configuration preserved: ${CONFIG_DIR}/alacritty" >&2
        exit 1
    fi
fi

mkdir -p "${CONFIG_DIR}"

ln -sfn "${SCRIPT_DIR}" "${CONFIG_DIR}/alacritty"

echo "Done: alacritty installed"
exit 0
