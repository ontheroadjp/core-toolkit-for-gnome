---
name: keyd-fep-toggle-sh
description: Dual-purpose script syncing keyd's k-binding and driving the Ctrl+Space FEP toggle
metadata:
  type: project
---

## 目的・役割

keyd の `k` バインド同期と、`Ctrl+Space` キーバインドから起動される FEP
（入力ソース）トグルの両方を担う 2 役スクリプト（`fep-toggle.sh:1-38`）。

## 動作概要

- 引数 `--keyd-us` / `--keyd-mozc` で呼ばれた場合（`fep-toggle.sh:4-13`）:
  root 権限で `keyd bind` を直接 `exec` し、`main.k` を `k`（US 時）または
  `oneshotk(after_k, k)`（Mozc 時）に切り替える。このモードは
  `scripts/fep-switcher/extension.js` の `_syncKeyd()` から
  `sudo -n /usr/local/bin/fep-toggle --keyd-us|--keyd-mozc` として呼ばれる
  （`scripts/fep-switcher/extension.js.md` 参照）。
- 引数なしで呼ばれた場合（`fep-toggle.sh:16-38`）: `Ctrl+Space`
  キーバインド（`scripts/core-gnome-settings/apply-settings.sh.md` 参照）から
  起動される想定。現在の `ibus engine` を見て Mozc↔US の逆方向へ切り替える:
  1. `gdbus call` で `fep-switcher@local` の `SwitchToUs()`/`SwitchToJa()` を呼ぶ
  2. 続けて `sudo -n /usr/local/bin/fep-toggle --keyd-us|--keyd-mozc` で
     自分自身を再帰的に sudo 起動し、keyd 側も同期する

## 重要な設計判断

- keyd 側の同期は `extension.js` の `_syncKeyd()`（D-Bus 経由の全呼び出し元で
  保証）と、本スクリプトの無引数モード末尾の直接呼び出しの二重に見えるが、
  実質は同じ経路（`gdbus call` → `FepSwitcher.SwitchToUs/Ja()` → `_syncKeyd()`）
  を通るため冗長ではない。無引数モードの末尾呼び出しは、D-Bus 呼び出し自体が
  失敗した場合のフォールバック的な位置づけではなく、実装上そのまま残っている
  点に注意（将来的な整理候補）。
- `--keyd-us`/`--keyd-mozc` モードは `keyd bind` を直接 `exec` するだけで
  D-Bus には触れない。呼び出し元（`extension.js`）が既に `sudo -n` 経由で
  root として起動しているため、内部で再度 `sudo` を挟まない。
- `sudo -n`（パスワード入力なし）を前提とするため、`/usr/local/bin/fep-toggle`
  への NOPASSWD sudoers ルールが必須（`scripts/core-gnome-settings/apply-settings.sh.md`
  の `_configure_fep_toggle_sudoers()` が自動設置する）。

## 統合ポイント

- 呼び出し元: `scripts/fep-switcher/extension.js` の `_syncKeyd()`
  （`sudo -n ... --keyd-us|--keyd-mozc`）、GNOME `Ctrl+Space` カスタム
  キーバインド（無引数）
- 呼び出し先: `keyd bind`、`gdbus call`（`org.gnome.Shell.Extensions.FepSwitcher`）
- 配置: `applications/keyd/install.sh` が `/usr/local/bin/fep-toggle`
  （拡張子なし）へシンボリックリンクする

## 注意事項・既知の制限

- `/usr/local/bin/keyd` のパスをハードコードしている（`fep-toggle.sh:6,10`）。
  keyd のインストール先が変わった場合は追従しない。
- 無引数モードは `ibus engine` の出力にのみ依存して切替方向を決める。
  `ibus` が未起動、または `mozc-jp` 以外の非 US エンジンが選択されている場合の
  挙動は「Mozc 以外は全て US 扱い」となる（`fep-toggle.sh:16-38` の `case` 文）。
