---
name: keyd-default-conf
description: keyd system-wide keymap, including the Mozc "kj"-to-Escape combo, the Ctrl+Space-to-Scroll_Lock fep-toggle remap, and the Ctrl+Shift+Space passthrough exemption
metadata:
  type: project
---

## 目的・役割

keyd のシステム全体キーマップ定義。ホームポジション改善（CapsLock/Ctrl 入替）、
ThinkPad 系トラックポイント周辺キーの矢印化、GNOME タイリング用ファンクション
キー割り当てに加え、Mozc 入力中の Vim 風エスケープコンボ（`kj`）と、Ctrl+Space
を Scroll_Lock に変換する fep-toggle 用 remap を提供する（`default.conf:1-29`）。
Ctrl+Space remap は Shift の有無を区別しないため、GNOME カスタムショートカット
`<Control><Shift>space`（Nuts Launcher）に生の Ctrl+Shift+Space を届けるための
明示的な例外バインドも定義する（`default.conf:30-38`、#56）。

## 動作概要

- `[main]` で CapsLock→LeftCtrl、LeftCtrl→LeftMeta、PageUp/PageDown→矢印、
  F1-F3→GNOME タイリングショートカットを定義する（`default.conf:4-15`）。
- `[after_k]` レイヤーで `j = macro(esc esc esc)` を定義する
  （`default.conf:17-18`）。このレイヤーは `k` に `oneshotk(after_k, k)` が
  バインドされている場合にのみ、`k` の直後の1打鍵で発火する。
- 現在の `[main]` には `k` バインドが（コメントアウトされ）存在しないため、
  `k` は keyd レベルでは常にデフォルト（素通し）であり、`after_k` レイヤー自体は
  静的には有効化されていない。実行時に `scripts/fep-switcher/extension.js`
  の `_syncKeyd()` → `applications/keyd/fep-toggle.sh --keyd-mozc` が
  `keyd bind 'main.k = oneshotk(after_k, k)'` を発行した時にだけ有効になる
  （動的バインド、`applications/keyd/fep-toggle.sh.md` 参照）。Mozc → US へ
  戻ると同じ経路で `main.k = k` に戻され、`after_k` は無効化される。
- `[control]` レイヤーで `space = scrolllock` を定義する（`default.conf:20-28`）。
  CapsLock（`leftcontrol` として動作）または右 Ctrl を押しながら Space を押すと、
  評価は keyd（evdev レイヤー、X11/Wayland/ibus より手前）で完結し、OS には
  Ctrl+Space ではなく Scroll_Lock が渡る。
- `[control+shift]` composite レイヤーで `space = C-S-space` を定義する
  （`default.conf:30-38`）。Control と Shift が同時に held の間はこのレイヤーが
  `[control]` より優先され、Ctrl+Shift+Space を押しても Scroll_Lock 変換されず、
  Control・Shift を明示的に再付与した Space（＝素の Ctrl+Shift+Space）が OS に渡る。

## 重要な設計判断

- `capslock = layer(control)` / `leftcontrol = layer(meta)` / `k = oneshotk(after_k, k)`
  はコメントアウトされたまま残されている（`default.conf:7-8,11`）。前者2つは
  レイヤー化による多機能キー案の検討メモであり未採用。後者の `k` バインドは
  static には有効化せず、FEP 状態に応じて動的に `keyd bind` で切り替える設計
  （後述）にしたため、ファイル上は無効のままにしてある。
- `kj` を Mozc 変換キャンセル用エスケープコンボにする挙動を、静的な keyd 設定
  だけでなく GNOME 拡張（FEP 切替）と同期させる必要があったため、`k` の
  バインド自体は本ファイルではなく実行時の `keyd bind` コマンドで制御する
  設計にした。US 入力中に `kj` を打つと無関係に `esc esc esc` が発火する
  事故を防ぐのが狙い（`applications/keyd/fep-toggle.sh.md`、
  `scripts/fep-switcher/extension.js.md` 参照）。
- `[control] space = scrolllock`（`default.conf:29`）: Mozc の未確定入力中は
  ibus がキーイベントを先取りするため、GNOME のカスタムキーバインディング
  （`<Control>space`）に生の Ctrl+Space を届けられず、単なる空白挿入で終わって
  しまっていた（issue #49）。keyd は X11/Wayland/ibus より手前（evdev）で
  動作するため、ここで Ctrl+Space を別キーへ変換すれば ibus は一切関与しない。
  変換先の候補として最初に F13-F24 を検討したが、稼働中の "us" XKB レイアウト
  （`/usr/share/X11/xkb/symbols/pc`）には F13-F24 のキーシンボル定義が存在せず、
  GNOME 側で NoSymbol となり原理的に解決不能と判明したため不採用。Scroll_Lock は
  同ファイルにキーシンボル定義があり、ロックキーだが実機で副作用（LED 点灯・
  OSD 表示）が確認されなかったため採用した。
- GNOME 側のバインド先は `scripts/core-gnome-settings/apply-settings.sh` の
  `_register_fep_toggle_keybinding`（`Scroll_Lock`）と対で維持する必要がある。
- `[control+shift]`（composite レイヤー）を空のまま定義するだけでは不十分だった
  （実機検証で確認済み、#56）。`man keyd` の COMPOSITE LAYERS の記述どおり、
  composite レイヤーは自身が明示的にバインドしたキーのみ優先し、未バインドの
  キーは通常のレイヤースタックを辿って解決されるため、`space` は依然として
  `[control]` の `space = scrolllock` にフォールスルーしてしまう。そのため
  `[control+shift]` 内で `space` を明示的にバインドする必要がある。ただし
  composite レイヤーの明示バインドは合成元のモディファイア（この場合
  Control・Shift）を出力から取り除く仕様（`man keyd` の `control+alt+h` →
  素の `left` になる例と同じ）であるため、`space = space` だけでは無変換の
  Space（モディファイアなし）になってしまう。`C-S-space` という macro shorthand
  で Control・Shift を明示的に再付与し、GNOME が期待する生の Ctrl+Shift+Space
  を再現している。

## 統合ポイント

- 配置先: `applications/keyd/install.sh` が `/etc/keyd` を本ディレクトリへの
  シンボリックリンクとして配置する。
- 実行時に上書きされる項目: `[main] k` バインドは
  `applications/keyd/fep-toggle.sh --keyd-us|--keyd-mozc` の `keyd bind`
  呼び出しにより動的に変わる。
- `[control] space = scrolllock` の変換先は
  `scripts/core-gnome-settings/apply-settings.sh` が登録する GNOME カスタム
  キーバインディング（`Scroll_Lock` → `/usr/local/bin/fep-toggle`）と対応する。
- `[control+shift] space = C-S-space` は、本リポジトリ外の別リポジトリ
  `nuts-launcher`（`~/.local/bin/trigger-nuts-launcher` にシンボリックリンク）
  を起動する GNOME カスタムキーバインディング（`<Control><Shift>space`）と対応
  する。このキーバインディング自体はユーザーが GNOME 側で手動登録したもので、
  本リポジトリのどのスクリプトも登録処理を持たない（#56）。

## 注意事項・既知の制限

- `keyd bind` による動的変更は `keyd` デーモン再起動やマシン再起動で失われ、
  ファイル上の（`k` バインドなしの）状態に戻る。次回 FEP 切替時に再同期される。
- `after_k` レイヤーはコメントアウトされた layer 化案（`capslock`/`leftcontrol`）
  とは独立した仕組みであり、両者は今回同時に検討されたが後者は未採用。
- 本ファイルの変更は `keyd` デーモンの inotify ベースの自動 reload に必ずしも
  即座に反映されない（実機検証で、複数回の連続編集のうち最初の 1 回しか自動
  reload されないケースを確認した）。変更後は `sudo keyd reload` を明示的に
  実行し、`journalctl -u keyd` で `CONFIG: parsing` が新しいタイムスタンプで
  出ていることを確認してから動作確認すること。

## 変更履歴（git log より自動生成）

- a9682b1 fix(#49): remap Ctrl+Space to Scroll_Lock so fep-toggle survives Mozc composition
- f4d961c Sync keyd kj-escape state with FEP switching and automate install/keybinding/sudoers setup (#48)
- 8045f0a chore(#29): reorganize root/ dotfiles into applications/ and gnome-extensions/
