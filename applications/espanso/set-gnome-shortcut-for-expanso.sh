#!/usr/bin/env bash
set -euo pipefail

name="Espanso Toggle"
cmd="$HOME/.local/bin/espanso-toggle"
binding="<Control><Alt>e"

base="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
path="$base/custom100/"

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['$path']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path name "$name"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path command "$cmd"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path binding "$binding"

echo "Added: $name -> $cmd ($binding)"
