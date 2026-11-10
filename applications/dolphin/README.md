# Dolphin on XWayland

Run `applications/dolphin/install.sh` or `./install-all.sh` to install the apt package and create a user desktop entry that launches Dolphin with `QT_QPA_PLATFORM=xcb`. Package installation requires sudo. The entry is generated from `/usr/share/applications/org.kde.dolphin.desktop` under `${XDG_DATA_HOME:-~/.local/share}/applications`.

After a Dolphin package update, rerun the installer to refresh the copy. It refreshes only an unmodified copy it previously generated. An existing or user-edited entry is never overwritten: inspect and back it up, then remove it before rerunning if you want the generated entry. The recorded checksum is stored under `${XDG_STATE_HOME:-~/.local/state}/gnome-toolkit/`.

To verify, exit existing Dolphin processes, launch Dolphin from the Dock and Nuts Launcher, and check its process environment for `QT_QPA_PLATFORM=xcb`. Open two windows and test copying and moving files by drag-and-drop. Existing Dolphin processes may continue to use their original environment. The reported GNOME/Wayland environment is needed to verify this behavior.

To remove the override, delete the user `org.kde.dolphin.desktop` and `gnome-toolkit/dolphin-desktop.sha256` checksum after backing up any desired changes. This restores the system desktop entry; uninstalling the Dolphin package is separate.
