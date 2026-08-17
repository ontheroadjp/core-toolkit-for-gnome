import Gio from 'gi://Gio';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Keyboard from 'resource:///org/gnome/shell/ui/status/keyboard.js';

const DBUS_IFACE = `
<node>
  <interface name="org.gnome.Shell.Extensions.FepSwitcher">
    <method name="SwitchToUs"/>
    <method name="SwitchToJa"/>
  </interface>
</node>`;

export default class FepSwitcherExtension extends Extension {
    enable() {
        this._inputSourceManager = Keyboard.getInputSourceManager();

        this._dbusImpl = Gio.DBusExportedObject.wrapJSObject(DBUS_IFACE, this);
        this._dbusImpl.export(Gio.DBus.session, '/org/gnome/Shell/Extensions/FepSwitcher');
        this._ownerId = Gio.bus_own_name_on_connection(
            Gio.DBus.session,
            'org.gnome.Shell.Extensions.FepSwitcher',
            Gio.BusNameOwnerFlags.NONE,
            () => {},
            () => {}
        );
    }

    disable() {
        if (this._ownerId) {
            Gio.bus_unown_name(this._ownerId);
            this._ownerId = 0;
        }
        if (this._dbusImpl) {
            this._dbusImpl.unexport();
            this._dbusImpl = null;
        }
        this._inputSourceManager = null;
    }

    _syncKeyd(mode) {
        const arg = mode === 'mozc'
            ? '--keyd-mozc'
            : '--keyd-us';

        try {
            Gio.Subprocess.new(
                [
                    '/usr/bin/sudo',
                    '-n',
                    '/usr/local/bin/fep-toggle',
                    arg,
                ],
                Gio.SubprocessFlags.NONE
            );
        } catch (e) {
            console.error(
                `[FepSwitcher] Failed to sync keyd (${mode}): ${e}`
            );
        }
    }

    SwitchToUs() {
        const source = Object.values(this._inputSourceManager.inputSources)
            .find(s => s.type === 'xkb' && s.id === 'us');
        source?.activate();
        this._syncKeyd('us');
    }

    SwitchToJa() {
        const source = Object.values(this._inputSourceManager.inputSources)
            .find(s => s.type === 'ibus' && s.id === 'mozc-jp');
        source?.activate();
        this._syncKeyd('mozc');
    }
}
