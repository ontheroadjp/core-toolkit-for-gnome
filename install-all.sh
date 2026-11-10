#!/bin/bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failed=0

run_step() {
    local name="$1"
    shift
    if "$@"; then
        printf 'SUCCESS: %s\n' "$name"
    else
        printf 'FAILED: %s\n' "$name" >&2
        failed=1
    fi
}

# shellcheck disable=SC2317  # Invoked indirectly by run_step.
install_extension() {
    local name="$1" source="$2"
    local target="${HOME}/.local/share/gnome-shell/extensions/${name}"
    rm -rf "$target" && ln -sf "$source" "$target" && gnome-extensions enable "$name"
}

# ----------------------------------
# core tools (no config in this repo)
# ----------------------------------
run_step "core-tools" "${REPO_DIR}/scripts/core-tools/install.sh"

# ----------------------------------
# keyd
# ----------------------------------
run_step "keyd" "${REPO_DIR}/applications/keyd/install.sh"

# ----------------------------------
# alacritty
# ----------------------------------
run_step "alacritty" "${REPO_DIR}/applications/alacritty/install.sh"

# ----------------------------------
# mpv
# ----------------------------------
run_step "mpv-player" "${REPO_DIR}/applications/mpv-player/install.sh"

# ----------------------------------
# yt-dlp
# ----------------------------------
run_step "yt-dlp" "${REPO_DIR}/applications/yt-dlp/install.sh"

# ----------------------------------
# espanso
# ----------------------------------
run_step "espanso" "${REPO_DIR}/applications/espanso/install.sh"

# ----------------------------------
# chrome
# ----------------------------------
run_step "chrome" "${REPO_DIR}/applications/chrome/install.sh"

# ----------------------------------
# dolphin
# ----------------------------------
run_step "dolphin" "${REPO_DIR}/applications/dolphin/install.sh"

# ----------------------------------
# settings > keyboard > custom shortcuts
# ----------------------------------
# Uncomment to install gnome-overview-toggle and register keyboard shortcut:
# "${REPO_DIR}/gnome-extensions/gnome-overview-toggle/install.sh"

# ----------------------------------
# fep-switcher (GNOME extension: core)
# ----------------------------------
run_step "fep-switcher" install_extension "fep-switcher@local" "${REPO_DIR}/scripts/fep-switcher"

# ----------------------------------
# app-switch-us-input (GNOME extension: window focus client)
# ----------------------------------
run_step "app-switch-us-input" install_extension "app-switch-us-input@local" "${REPO_DIR}/scripts/app-switch-us-input"

# ----------------------------------
# tmux-switch-us-input
# ----------------------------------
run_step "tmux-switch-us-input" ln -sf "${REPO_DIR}/scripts/tmux-switch-us-input/switch-input-to-us" "${HOME}/.local/bin/switch-input-to-us"

# ----------------------------------
# Manual steps
# ----------------------------------
printf '\033[0;36m'
cat <<'EOF'

=== Manual step: scripts/core-gnome-settings ===
Run the following to apply GNOME settings (machine-agnostic, no sudo required):

  scripts/core-gnome-settings/apply-settings.sh

=== Manual step: scripts/core-t480s-settings ===
Run the following to apply T480s-specific settings (requires sudo internally):

  scripts/core-t480s-settings/apply-settings.sh

=== Manual step: ~/.tmux.conf ===
Add the following line to enable auto-switch to US input on pane focus:

  set-hook -g after-select-pane 'run-shell "switch-input-to-us"'

NOTE: On Wayland, newly installed GNOME extensions take effect after logout/login.

EOF
printf '\033[0m'

exit "$failed"
