---
name: fep-switcher-extension-js
description: GNOME extension exposing the FepSwitcher D-Bus service and syncing keyd on every switch
metadata:
  type: project
---

## 目的・役割

GNOME Shell 拡張。D-Bus サービス `org.gnome.Shell.Extensions.FepSwitcher` を
公開し、入力ソースを US/Mozc に切り替える `SwitchToUs()`/`SwitchToJa()` を
提供する。あわせて、切替のたびに keyd 側の `k` バインドを同期する
（`extension.js:1-76`）。

## 動作概要

- `enable()` で D-Bus オブジェクトをエクスポートし、bus name を own する
  （`extension.js:15-27`）。
- `SwitchToUs()`/`SwitchToJa()` はそれぞれ対応する入力ソース
  （xkb:us / ibus:mozc-jp）を検索し `activate()` した直後に、
  `_syncKeyd('us')`/`_syncKeyd('mozc')` を呼ぶ（`extension.js:63-75`）。
  入力ソースが見つからない場合（`source` が `undefined`）は `activate()` も
  `_syncKeyd()` も実行されない（オプショナルチェイニング `source?.activate()`
  により `_syncKeyd` の呼び出し自体はガードされていない点に注意 —
  実際には `find` が見つからなくても後続の `_syncKeyd` は実行される）。
- `_syncKeyd(mode)` は `mode === 'mozc'` かどうかで `--keyd-mozc`/`--keyd-us`
  を選び、`Gio.Subprocess.new(['/usr/bin/sudo', '-n', '/usr/local/bin/fep-toggle', arg], ...)`
  を非同期起動する（`extension.js:41-61`）。起動失敗（`sudo` 権限不足など）は
  `console.error` にログするのみで、`SwitchToUs()`/`SwitchToJa()` 自体は
  失敗させない。

## 重要な設計判断

- keyd 同期の責任を、呼び出し元（Vim プラグイン、tmux フック、
  `app-switch-us-input` 拡張、`fep-toggle.sh` の無引数モードなど）ではなく
  `FepSwitcher` 自身（本ファイル）に持たせた。これにより、
  `fep-switcher@local` の D-Bus メソッドを呼ぶ経路が増えても、呼び出し元が
  keyd 同期を意識する必要がなくなる。当初は `fep-toggle.sh` 側で keyd 同期と
  FEP 切替の両方を行っていたが、`fep-toggle.sh` を経由しない呼び出し元
  （Vim から直接 D-Bus を叩く等）では keyd が同期されない欠落があったため、
  この設計に変更した。
- `_syncKeyd()` は `Gio.Subprocess.new()` の完了を待たない（fire-and-forget）。
  待ち合わせ（wait）を入れると `SwitchToUs()`/`SwitchToJa()` の呼び出し元
  （D-Bus 越しの同期呼び出し）をブロックしうるため、意図的に非同期のままに
  してある。
- `sudo -n /usr/local/bin/fep-toggle --keyd-us|--keyd-mozc` という固定コマンド
  列を呼ぶため、`/usr/local/bin/fep-toggle` への NOPASSWD sudoers ルールが
  必須（`scripts/core-gnome-settings/apply-settings.sh.md` 参照）。

## 統合ポイント

- 呼び出し元（D-Bus 経由）: `applications/keyd/fep-toggle.sh`（無引数モード）、
  `scripts/app-switch-us-input/extension.js`、
  `scripts/tmux-switch-us-input/switch-input-to-us`、
  `scripts/vim-switch-us-input/plugin/vim-switch-us-input.vim`、
  `gnome-extensions/search-light/trigger-search-light`
- 呼び出し先: `applications/keyd/fep-toggle.sh --keyd-us|--keyd-mozc`
  （`sudo -n` 経由）
- インストール: ルート `install-all.sh` が `~/.local/share/gnome-shell/extensions/fep-switcher@local`
  へ symlink する

## 注意事項・既知の制限

- `_syncKeyd()` の `Gio.Subprocess.new()` 呼び出しが完了する前に、後続の
  キー入力が発生する可能性がある（fire-and-forget のため）。実運用上の
  タイミング問題（zsh vi-mode との相互作用など）は keyd/FepSwitcher 側の
  責務外として切り分け済み。
- `sudo -n` が NOPASSWD ルール未設定などで失敗した場合、`console.error` に
  ログが出るのみで、ユーザーへの通知は行われない。

## 変更履歴（git log より自動生成）

- 9edfbd9 feat(#47): sync keyd kj-escape state with FEP switching and automate install/keybinding/sudoers setup
- 478c73d refactor(#15): split into fep-switcher core and app-switch-us-input client
