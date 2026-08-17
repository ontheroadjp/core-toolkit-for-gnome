---
name: core-gnome-settings-apply-settings-sh
description: Applies GNOME gsettings, including the Scroll_Lock fep-toggle keybinding (keyd-converted Ctrl+Space) and its sudoers rule
metadata:
  type: project
---

## 目的・役割

GNOME 環境向けの `gsettings` 一括適用スクリプト。アニメーション・キー
リピート・ウィンドウ/ワークスペース切替・フォントに加え、keyd が
`Ctrl+Space` を変換した `Scroll_Lock` を `/usr/local/bin/fep-toggle` に
バインドする custom keybinding の登録と、`fep-toggle` 用の passwordless
sudo ルールの自動設置を行う（`apply-settings.sh:1-131`）。

## 動作概要

- 冒頭は機種非依存の `gsettings set`/`reset` の羅列（アニメーション、キー
  リピート、ウィンドウ/ワークスペース切替、フォント、`apply-settings.sh:1-53`）。
- `switch-input-source`（GNOME 標準の入力ソース切替キーバインド）はここでは
  `set` ではなく `reset` する（`apply-settings.sh:23`）。`Ctrl+Space` は
  代わりに custom keybinding 経由で `/usr/local/bin/fep-toggle` を起動する
  ため、標準バインドと衝突させないための reset。
- `_register_fep_toggle_keybinding()`（`apply-settings.sh:65-104`）:
  `org.gnome.settings-daemon.plugins.media-keys` の `custom-keybindings`
  スロットを `custom0`, `custom1`, ... と走査し、既に command に
  `fep-toggle` を含むスロットがあれば、その `binding` が現在の目標値
  （`Scroll_Lock`）と一致するか確認する。一致しなければ `binding` だけを
  更新（旧 `<Control>space` 登録済みの既存マシンを移行するため）、一致
  すれば何もせず終了（冪等）。スロット自体が無ければ空きスロットに
  `name`/`command`/`binding`（`Scroll_Lock`）を設定し、`custom-keybindings`
  配列に追記する。
- `_configure_fep_toggle_sudoers()`（`apply-settings.sh:112-135`）:
  `<実行ユーザー> ALL=(root) NOPASSWD: /usr/local/bin/fep-toggle` という
  1行ルールを一時ファイルに書き、`visudo -c -f` で構文検証してから
  `sudo install -m 0440 -o root -g root` で `/etc/sudoers.d/fep-toggle` に
  設置する。`/etc/sudoers.d/fep-toggle` に同一ルールが既に存在する場合は
  スキップ（冪等）。検証に失敗した場合は一時ファイルを削除して `exit 1`
  し、不正な sudoers ファイルを設置しない。
- ファイル末尾で両関数を呼び出す（`apply-settings.sh:137-138`）。

## 重要な設計判断

- sudoers ドロップインの内容を `visudo -c -f` で検証してから設置すること
  で、構文エラーのある sudoers ファイルが `/etc/sudoers.d` に置かれる事故を
  防いでいる（sudoers の構文エラーはシステム全体の `sudo` を壊しうるため）。
- 冪等性を最優先し、両関数とも「既存の設定/ルールと一致すれば何もしない」
  判定を先頭に置いている。再実行しても custom-keybinding スロットが
  重複したり、sudoers ファイルが二重に書かれたりしない。ただし
  `_register_fep_toggle_keybinding()` は「スロットの有無」だけでなく
  「binding 値の一致」も冪等判定に含める（後述）。
- ファイル冒頭は元々フラットな `gsettings` 呼び出しの羅列だったが、
  冪等な走査・検証ロジックが必要な2機能のみ関数化した。既存のフラットな
  記述スタイルは変更していない。
- `binding` の目標値は当初 `<Control>space`（生の Ctrl+Space）だったが、
  Mozc 未確定入力中に ibus がキーイベントを先取りしてしまい GNOME の
  カスタムキーバインディングまで届かない問題（issue #49）があったため、
  `applications/keyd/default.conf` の `[control] space = scrolllock` で
  評価前に変換される `Scroll_Lock` へ変更した（詳細は
  `applications/keyd/default.conf.md` 参照）。これに伴い、既に
  `<Control>space` で登録済みの既存マシンを再実行だけで `Scroll_Lock` に
  移行できるよう、スロットが既存でも `binding` が目標値と異なれば
  `gsettings set` で更新するロジックを追加した（単純な「スロットが
  あれば何もしない」判定のままだと、binding 値の変更が再実行しても永久に
  反映されない）。

## 統合ポイント

- 前提: `applications/keyd/install.sh` が `/usr/local/bin/fep-toggle` を
  配置済みであること（`applications/keyd/install.sh.md` 参照）。
- keyd が Ctrl+Space を変換した `Scroll_Lock` 押下時の呼び出し先:
  `/usr/local/bin/fep-toggle`（無引数モード、
  `applications/keyd/fep-toggle.sh.md` 参照）。変換自体は
  `applications/keyd/default.conf` の `[control]` レイヤーが担う。
- `sudo -n /usr/local/bin/fep-toggle ...` は本スクリプトが設置する sudoers
  ルールに依存する（`scripts/fep-switcher/extension.js` の `_syncKeyd()`、
  `fep-toggle.sh` の無引数モード末尾）。

## 注意事項・既知の制限

- sudoers ルール設置・`switch-input-source` の書き換えは `sudo` を要する
  （ファイル冒頭の `gsettings` 呼び出しのみなら不要だった従来の前提が
  変わっている）。
- `_configure_fep_toggle_sudoers()` は `sudo test -f`/`sudo grep` で
  既存ルールを確認するため、非対話的に `sudo` が使えない環境（NOPASSWD
  未設定の初回実行時など）ではパスワード入力を求められる。
- 3つ以上の入力ソースを運用している環境では、`switch-input-source` の
  reset により GNOME 標準の入力ソース循環手段が失われる。`fep-toggle` が
  US/Mozc の2択切替のみを代替する設計のため、他の入力ソースの切替手段は
  別途用意する必要がある。
- 本スクリプトが `binding` を更新しても、`applications/keyd/default.conf`
  側の変更が keyd デーモンに反映されていなければ Ctrl+Space は機能しない。
  `default.conf` の変更後は別途 `sudo keyd reload` が必要（自動 reload は
  信頼できないことを実機で確認済み、`default.conf.md` 参照）。

## 変更履歴（git log より自動生成）

- a9682b1 fix(#49): remap Ctrl+Space to Scroll_Lock so fep-toggle survives Mozc composition
- f4d961c Sync keyd kj-escape state with FEP switching and automate install/keybinding/sudoers setup (#48)
- edc8e10 refactor: split t480s/ into core-gnome-settings and core-t480s-settings
