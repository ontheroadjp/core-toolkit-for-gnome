---
name: core-gnome-settings-apply-settings-sh
description: Applies GNOME gsettings, including the Ctrl+Space fep-toggle keybinding and its sudoers rule
metadata:
  type: project
---

## 目的・役割

GNOME 環境向けの `gsettings` 一括適用スクリプト。アニメーション・キー
リピート・ウィンドウ/ワークスペース切替・フォントに加え、`Ctrl+Space` を
`/usr/local/bin/fep-toggle` にバインドする custom keybinding の登録と、
`fep-toggle` 用の passwordless sudo ルールの自動設置を行う
（`apply-settings.sh:1-125`）。

## 動作概要

- 冒頭は機種非依存の `gsettings set`/`reset` の羅列（アニメーション、キー
  リピート、ウィンドウ/ワークスペース切替、フォント、`apply-settings.sh:1-53`）。
- `switch-input-source`（GNOME 標準の入力ソース切替キーバインド）はここでは
  `set` ではなく `reset` する（`apply-settings.sh:23`）。`Ctrl+Space` は
  代わりに custom keybinding 経由で `/usr/local/bin/fep-toggle` を起動する
  ため、標準バインドと衝突させないための reset。
- `_register_fep_toggle_keybinding()`（`apply-settings.sh:59-92`）:
  `org.gnome.settings-daemon.plugins.media-keys` の `custom-keybindings`
  スロットを `custom0`, `custom1`, ... と走査し、既に command に
  `fep-toggle` を含むスロットがあれば何もせず終了（冪等）。なければ空き
  スロットに `name`/`command`/`binding`（`<Control>space`）を設定し、
  `custom-keybindings` 配列に追記する。
- `_configure_fep_toggle_sudoers()`（`apply-settings.sh:99-122`）:
  `<実行ユーザー> ALL=(root) NOPASSWD: /usr/local/bin/fep-toggle` という
  1行ルールを一時ファイルに書き、`visudo -c -f` で構文検証してから
  `sudo install -m 0440 -o root -g root` で `/etc/sudoers.d/fep-toggle` に
  設置する。`/etc/sudoers.d/fep-toggle` に同一ルールが既に存在する場合は
  スキップ（冪等）。検証に失敗した場合は一時ファイルを削除して `exit 1`
  し、不正な sudoers ファイルを設置しない。
- ファイル末尾で両関数を呼び出す（`apply-settings.sh:124-125`）。

## 重要な設計判断

- sudoers ドロップインの内容を `visudo -c -f` で検証してから設置すること
  で、構文エラーのある sudoers ファイルが `/etc/sudoers.d` に置かれる事故を
  防いでいる（sudoers の構文エラーはシステム全体の `sudo` を壊しうるため）。
- 冪等性を最優先し、両関数とも「既存の設定/ルールと一致すれば何もしない」
  判定を先頭に置いている。再実行しても custom-keybinding スロットが
  重複したり、sudoers ファイルが二重に書かれたりしない。
- ファイル冒頭は元々フラットな `gsettings` 呼び出しの羅列だったが、
  冪等な走査・検証ロジックが必要な2機能のみ関数化した。既存のフラットな
  記述スタイルは変更していない。

## 統合ポイント

- 前提: `applications/keyd/install.sh` が `/usr/local/bin/fep-toggle` を
  配置済みであること（`applications/keyd/install.sh.md` 参照）。
- `Ctrl+Space` 押下時の呼び出し先: `/usr/local/bin/fep-toggle`
  （無引数モード、`applications/keyd/fep-toggle.sh.md` 参照）。
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

## 変更履歴（git log より自動生成）

- 9edfbd9 feat(#47): sync keyd kj-escape state with FEP switching and automate install/keybinding/sudoers setup
- edc8e10 refactor: split t480s/ into core-gnome-settings and core-t480s-settings
