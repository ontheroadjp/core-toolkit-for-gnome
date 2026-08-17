#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 <output-dir> <keyd|libinput|ibus>" >&2
  echo "  keyd:      keyd monitor -t              (run this script with sudo)" >&2
  echo "  libinput:  libinput debug-events         (run this script with sudo; requires libinput-tools)" >&2
  echo "  ibus:      journalctl --user -u org.freedesktop.IBus.session.GNOME -f" >&2
  exit 1
}

[ "$#" -eq 2 ] || usage

output_dir="$1"
mode="$2"

case "$mode" in
  keyd)
    cmd=(keyd monitor -t)
    ;;
  libinput)
    cmd=(libinput debug-events)
    ;;
  ibus)
    cmd=(journalctl --user -u org.freedesktop.IBus.session.GNOME -f)
    ;;
  *)
    usage
    ;;
esac

mkdir -p "$output_dir"
log_file="$output_dir/$mode.log"

echo "Capturing '$mode' events to $log_file"
echo "Reproduce the bug now, then press Ctrl+C to stop."
"${cmd[@]}" 2>&1 | tee "$log_file"
