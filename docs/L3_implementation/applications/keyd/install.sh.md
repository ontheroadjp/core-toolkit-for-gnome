---
name: keyd-install-sh
description: Installs keyd and places its config and the fep-toggle helper on PATH
metadata:
  type: project
---

## 目的・役割

keyd 本体のインストール、`/etc/keyd` への設定配置、および `fep-toggle`
ヘルパースクリプトの `/usr/local/bin` への配置を行う（`install.sh:1-25`）。

## 動作概要

1. `keyd` コマンドが無ければ PPA 追加・apt インストール・サービス有効化を行う
   （`install.sh:6-14`）。既にインストール済みならスキップ。
2. `/etc/keyd` を削除し、本ディレクトリ（`applications/keyd/`）へのシンボリック
   リンクとして再作成する（`install.sh:16-17`）。これにより `default.conf` の
   変更が再インストールなしで反映される。
3. `applications/keyd/fep-toggle.sh` に実行権限を付与し、`/usr/local/bin/fep-toggle`
   （拡張子なし）へシンボリックリンクする（`install.sh:21-22`）。

## 重要な設計判断

- `fep-toggle` の配置先を `/usr/local/bin` かつ拡張子なしにしているのは、
  `scripts/fep-switcher/extension.js` の `_syncKeyd()` および
  `fep-toggle.sh` 自身の再帰呼び出しが `sudo -n /usr/local/bin/fep-toggle`
  という固定パスで呼び出すため（`applications/keyd/fep-toggle.sh.md`、
  `scripts/fep-switcher/extension.js.md` 参照）。パスをずらすと同期が壊れる。
- `chmod +x` はシンボリックリンク元（リポジトリ内ファイル）に対して行うため
  `sudo` は不要。`/usr/local/bin` へのリンク作成のみ `sudo` を要する。

## 統合ポイント

- 呼び出し元: `install-all.sh`（`applications/keyd/install.sh` を呼ぶ）、
  または利用者による直接実行
- 生成物: `/etc/keyd`（symlink）、`/usr/local/bin/fep-toggle`（symlink）
- 依存: `scripts/core-gnome-settings/apply-settings.sh` が登録する
  `Ctrl+Space` キーバインドと sudoers ルールは、本スクリプトが
  `/usr/local/bin/fep-toggle` を配置済みであることを前提とする

## 注意事項・既知の制限

- `/etc/keyd` の配置と `fep-toggle` の配置はいずれも `sudo` を要する。
- 本スクリプトは `Ctrl+Space` キーバインドや sudoers ルールの設定は行わない
  （`scripts/core-gnome-settings/apply-settings.sh` の責務）。両者は別々に
  実行する必要がある。

## 変更履歴（git log より自動生成）

- 9edfbd9 feat(#47): sync keyd kj-escape state with FEP switching and automate install/keybinding/sudoers setup
- 6b93fec chore(#31): replace t480s-apps-install.sh with per-app install.sh and scripts/core-tools/install.sh
- 8045f0a chore(#29): reorganize root/ dotfiles into applications/ and gnome-extensions/
