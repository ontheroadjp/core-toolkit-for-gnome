# `install-all.sh`

## 目的・動作

各アプリのインストーラーを呼び出し、GNOME 拡張と補助スクリプトを設定する。各処理の終了直後に成功または失敗を表示し、失敗しても後続処理を実行する。いずれかが失敗した場合は、手動手順の表示後に終了コード 1 を返す（`install-all.sh` の `run_step`）。

## 統合・制限

システムパッケージ導入やユーザー設定への変更を伴う。成否は各コマンドの終了コードに基づくため、個別インストーラー内で検出されない失敗は表示されない。個別手順は各モジュールを参照。

## 変更履歴（git log より自動生成）

- 19a3c13 fix(#77): report installation results as steps finish
- 1b4144a feat(#75): configure dolphin xwayland launch (#76)
- d3f2eab chore: rename install.sh to install-all.sh and add manual steps for settings scripts
