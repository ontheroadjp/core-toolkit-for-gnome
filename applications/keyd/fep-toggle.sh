#!/bin/sh

# keyd Operations When Called as root
case "$1" in
  --keyd-us)
    exec /usr/local/bin/keyd bind 'main.k = k' >/dev/null
    ;;

  --keyd-mozc)
    exec /usr/local/bin/keyd bind \
      'main.k = oneshotk(after_k, k)' >/dev/null
    ;;
esac

# Normal FEP Switching
case "$(ibus engine)" in
  mozc-jp)
    # Mozc -> US
    gdbus call --session \
      --dest org.gnome.Shell.Extensions.FepSwitcher \
      --object-path /org/gnome/Shell/Extensions/FepSwitcher \
      --method org.gnome.Shell.Extensions.FepSwitcher.SwitchToUs \
      >/dev/null

    # sudo -n /usr/local/bin/fep-toggle --keyd-us
    ;;

  *)
    # US -> Mozc
    gdbus call --session \
      --dest org.gnome.Shell.Extensions.FepSwitcher \
      --object-path /org/gnome/Shell/Extensions/FepSwitcher \
      --method org.gnome.Shell.Extensions.FepSwitcher.SwitchToJa \
      >/dev/null

    # sudo -n /usr/local/bin/fep-toggle --keyd-mozc
    ;;
esac
