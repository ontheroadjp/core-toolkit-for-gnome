# `install-all.sh`

## 目的・動作

各アプリのインストーラーを呼び出し、GNOME 拡張と補助スクリプトを設定する。Dolphin インストーラーが失敗した場合は処理を停止する（`install-all.sh` の dolphin 節）。

## 統合・制限

システムパッケージ導入やユーザー設定への変更を伴う。個別手順は各モジュールを参照。

## 変更履歴（git log より自動生成）

- 588948d feat(#75): configure dolphin xwayland launch
- d3f2eab chore: rename install.sh to install-all.sh and add manual steps for settings scripts
