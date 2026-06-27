#!/bin/bash

set -euo pipefail

SCRIPT_NAME="trigger-search-light"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.local/bin"
TARGET_PATH="${TARGET_DIR}/${SCRIPT_NAME}"

mkdir -p "${TARGET_DIR}"
chmod +x "${REPO_DIR}/${SCRIPT_NAME}"
ln -sf "${REPO_DIR}/${SCRIPT_NAME}" "${TARGET_PATH}"

echo "Installed ${TARGET_PATH}"
