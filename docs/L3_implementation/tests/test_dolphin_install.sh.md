# `tests/test_dolphin_install.sh`

## 目的・動作

一時 HOME とパッケージ確認のスタブを使い、Dolphin entry の生成、再実行、ユーザー編集検出と保護を検証する（`tests/test_dolphin_install.sh:4-30`）。

## 制限

システムに Dolphin の desktop entry が必要。GNOME 起動とドラッグ＆ドロップは実機確認する。

## 変更履歴（git log より自動生成）

- 588948d feat(#75): configure dolphin xwayland launch
