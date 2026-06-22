#!/bin/bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.local/bin"
TARGET_PATH="${TARGET_DIR}/espanso-toggle"

mkdir -p "${TARGET_DIR}"
chmod +x "${REPO_DIR}/espanso-toggle"
ln -sf "${REPO_DIR}/espanso-toggle" "${TARGET_PATH}"

echo "Installed ${TARGET_PATH}"
