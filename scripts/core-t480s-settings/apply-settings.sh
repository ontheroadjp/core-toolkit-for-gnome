#!/bin/bash

set -euo pipefail

if ! command -v tlp >/dev/null 2>&1; then
    echo 'TLP is required. Install and enable TLP before running this script.' >&2
    exit 1
fi

config=/etc/tlp.conf
if [[ ! -f "$config" ]]; then
    echo "TLP configuration not found: $config" >&2
    exit 1
fi

temp_config=$(mktemp)
trap 'rm -f "$temp_config"' EXIT

# Replace active thresholds while preserving unrelated configuration.
sudo cat "$config" | awk '
    !/^[[:space:]]*(START|STOP)_CHARGE_THRESH_BAT0[[:space:]]*=/ { print }
    END {
        print "START_CHARGE_THRESH_BAT0=70"
        print "STOP_CHARGE_THRESH_BAT0=85"
    }
' > "$temp_config"

# The input redirection is read by this shell; sudo applies to tee's output file.
# shellcheck disable=SC2024
sudo tee "$config" < "$temp_config" >/dev/null
sudo systemctl enable --now tlp
sudo tlp start
