#!/bin/bash

# -----------------------------------------
# gnome animation
# -----------------------------------------
gsettings set org.gnome.desktop.interface enable-animations true

# -----------------------------------------
# key repeat settings
#                   Fast    Slightly Faster     Normal  Slow
# deray:            140,    200,                250,    300
# repeat-interval:  10,     20,                 30,     40
# -----------------------------------------
gsettings set org.gnome.desktop.peripherals.keyboard repeat true
gsettings set org.gnome.desktop.peripherals.keyboard delay 180
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 10

# -----------------------------------------
# FEP toggle to Ctrl + Space
# GNOME 標準の switch-input-source は使わず、/usr/local/bin/fep-toggle を
# 起動する custom keybinding として登録する（後段の _register_fep_toggle_keybinding）
# -----------------------------------------
gsettings reset org.gnome.desktop.wm.keybindings switch-input-source

# -----------------------------------------
# Window switching (Ctrl+Tab, keep Alt+Tab)
# switch-panels reset to default (Ctrl+Alt+Tab)
# -----------------------------------------
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab', '<Control>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab', '<Shift><Control>Tab']"
gsettings reset org.gnome.desktop.wm.keybindings switch-panels
gsettings reset org.gnome.desktop.wm.keybindings switch-panels-backward

# -----------------------------------------
# Change workspace
# -----------------------------------------
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['<Control>1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['<Control>2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['<Control>3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['<Control>4']"

# -----------------------------------------
# window drag with super to ctrl
# -----------------------------------------
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier "'<Ctrl>'"

# -----------------------------------------
# font
# gsettings set org.gnome.desktop.interface font-hinting 'slight'
# gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
# -----------------------------------------
gsettings set org.gnome.desktop.interface font-hinting 'full'
gsettings set org.gnome.desktop.interface font-antialiasing 'grayscale'

# -----------------------------------------
# fep-toggle: Ctrl+Space custom keybinding
# applications/keyd/install.sh が /usr/local/bin/fep-toggle を配置する前提
# -----------------------------------------
_register_fep_toggle_keybinding() {
    local dconf_base="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
    local command="/usr/local/bin/fep-toggle"
    local binding="<Control>space"

    local existing_list
    existing_list=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || echo "@as []")

    local idx=0
    while [[ "$existing_list" == *"${dconf_base}/custom${idx}/"* ]]; do
        local slot_cmd
        slot_cmd=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${dconf_base}/custom${idx}/" command 2>/dev/null || echo "")
        if [[ "$slot_cmd" == *"fep-toggle"* ]]; then
            echo "fep-toggle keybinding already registered at ${dconf_base}/custom${idx}/. Skipped."
            return
        fi
        idx=$((idx + 1))
    done

    local slot="${dconf_base}/custom${idx}/"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${slot}" name 'fep-toggle'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${slot}" command "${command}"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${slot}" binding "${binding}"

    local new_list
    if [ "$existing_list" = "@as []" ] || [ "$existing_list" = "[]" ]; then
        new_list="['${slot}']"
    else
        new_list="${existing_list%]}, '${slot}']"
    fi
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$new_list"

    echo "Done: fep-toggle keybinding registered (${binding} -> ${command})"
}

# -----------------------------------------
# fep-toggle: passwordless sudo rule
# extension.js / fep-toggle.sh が `sudo -n /usr/local/bin/fep-toggle` を
# 呼ぶための NOPASSWD ルールを、検証の上 /etc/sudoers.d に設置する
# -----------------------------------------
_configure_fep_toggle_sudoers() {
    local sudoers_file="/etc/sudoers.d/fep-toggle"
    local rule
    rule="$(id -un) ALL=(root) NOPASSWD: /usr/local/bin/fep-toggle"

    if sudo test -f "$sudoers_file" && sudo grep -qF "$rule" "$sudoers_file"; then
        echo "fep-toggle sudoers rule already present. Skipped."
        return
    fi

    local tmp_file
    tmp_file="$(mktemp)"
    echo "$rule" > "$tmp_file"

    if ! visudo -c -f "$tmp_file" >/dev/null 2>&1; then
        echo "ERROR: generated sudoers rule failed validation. Aborting." >&2
        rm -f "$tmp_file"
        exit 1
    fi

    sudo install -m 0440 -o root -g root "$tmp_file" "$sudoers_file"
    rm -f "$tmp_file"
    echo "Done: fep-toggle sudoers rule installed at ${sudoers_file}"
}

_register_fep_toggle_keybinding
_configure_fep_toggle_sudoers
