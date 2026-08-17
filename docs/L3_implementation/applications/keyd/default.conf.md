---
name: keyd-default-conf
description: keyd system-wide keymap, including the Mozc "kj"-to-Escape combo
metadata:
  type: project
---

## 目的・役割

keyd のシステム全体キーマップ定義。ホームポジション改善（CapsLock/Ctrl 入替）、
ThinkPad 系トラックポイント周辺キーの矢印化、GNOME タイリング用ファンクション
キー割り当てに加え、Mozc 入力中の Vim 風エスケープコンボ（`kj`）を提供する
（`default.conf:1-21`）。

## 動作概要

- `[main]` で CapsLock→LeftCtrl、LeftCtrl→LeftMeta、PageUp/PageDown→矢印、
  F1-F3→GNOME タイリングショートカットを定義する（`default.conf:4-15`）。
- `[after_k]` レイヤーで `j = macro(backspace esc esc)` を定義する
  （`default.conf:17-18`）。このレイヤーは `k` に `oneshotk(after_k, k)` が
  バインドされている場合にのみ、`k` の直後の1打鍵で発火する。
- 現在の `[main]` には `k` バインドが（コメントアウトされ）存在しないため、
  `k` は keyd レベルでは常にデフォルト（素通し）であり、`after_k` レイヤー自体は
  静的には有効化されていない。実行時に `scripts/fep-switcher/extension.js`
  の `_syncKeyd()` → `applications/keyd/fep-toggle.sh --keyd-mozc` が
  `keyd bind 'main.k = oneshotk(after_k, k)'` を発行した時にだけ有効になる
  （動的バインド、`applications/keyd/fep-toggle.sh.md` 参照）。Mozc → US へ
  戻ると同じ経路で `main.k = k` に戻され、`after_k` は無効化される。

## 重要な設計判断

- `capslock = layer(control)` / `leftcontrol = layer(meta)` / `k = oneshotk(after_k, k)`
  はコメントアウトされたまま残されている（`default.conf:7-8,11`）。前者2つは
  レイヤー化による多機能キー案の検討メモであり未採用。後者の `k` バインドは
  static には有効化せず、FEP 状態に応じて動的に `keyd bind` で切り替える設計
  （後述）にしたため、ファイル上は無効のままにしてある。
- `kj` を Mozc 変換キャンセル用エスケープコンボにする挙動を、静的な keyd 設定
  だけでなく GNOME 拡張（FEP 切替）と同期させる必要があったため、`k` の
  バインド自体は本ファイルではなく実行時の `keyd bind` コマンドで制御する
  設計にした。US 入力中に `kj` を打つと無関係に `backspace esc esc` が発火する
  事故を防ぐのが狙い（`applications/keyd/fep-toggle.sh.md`、
  `scripts/fep-switcher/extension.js.md` 参照）。

## 統合ポイント

- 配置先: `applications/keyd/install.sh` が `/etc/keyd` を本ディレクトリへの
  シンボリックリンクとして配置する。
- 実行時に上書きされる項目: `[main] k` バインドは
  `applications/keyd/fep-toggle.sh --keyd-us|--keyd-mozc` の `keyd bind`
  呼び出しにより動的に変わる。

## 注意事項・既知の制限

- `keyd bind` による動的変更は `keyd` デーモン再起動やマシン再起動で失われ、
  ファイル上の（`k` バインドなしの）状態に戻る。次回 FEP 切替時に再同期される。
- `after_k` レイヤーはコメントアウトされた layer 化案（`capslock`/`leftcontrol`）
  とは独立した仕組みであり、両者は今回同時に検討されたが後者は未採用。
