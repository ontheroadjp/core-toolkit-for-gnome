#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -e /etc/keyd ] || [ -L /etc/keyd ]; then
    if [ ! -L /etc/keyd ] || [ "$(readlink /etc/keyd)" != "$SCRIPT_DIR" ]; then
        echo "Existing keyd configuration preserved: /etc/keyd. Back it up and move it before installing." >&2
        exit 1
    fi
fi

if ! command -v keyd >/dev/null 2>&1; then
    sudo add-apt-repository ppa:keyd-team/ppa
    sudo apt update
    sudo apt install -y keyd
    sudo systemctl enable --now keyd
    echo "Done: keyd installed."
else
    echo "keyd is already installed. Skipped."
fi

if [ -e /etc/keyd ] || [ -L /etc/keyd ]; then
    if [ ! -L /etc/keyd ] || [ "$(readlink /etc/keyd)" != "$SCRIPT_DIR" ]; then
        echo "Existing keyd configuration preserved: /etc/keyd. Back it up and move it before installing." >&2
        exit 1
    fi
else
    sudo ln -s "${SCRIPT_DIR}" /etc/keyd
fi

echo "Done: keyd config installed"

chmod +x "${SCRIPT_DIR}/fep-toggle.sh"
sudo ln -sf "${SCRIPT_DIR}/fep-toggle.sh" /usr/local/bin/fep-toggle

echo "Done: fep-toggle installed at /usr/local/bin/fep-toggle"
exit 0
