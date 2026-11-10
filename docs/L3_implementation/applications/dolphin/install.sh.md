# `applications/dolphin/install.sh`

## 目的・動作

Dolphin の apt パッケージと、XWayland 起動用のユーザー desktop entry を導入する。既存エントリーは保存済み checksum と一致する場合のみ更新し、未管理・編集済みファイルや symlink は保護する（`applications/dolphin/install.sh:4-20`）。

## 設計と制限

システム entry の想定外の Exec や action は拒否し、生成時に Exec と D-Bus 起動指定を変更する。更新の反映には再実行が必要（`applications/dolphin/install.sh:21-48`）。

## 統合

`install-all.sh` と個別実行から呼び出す。手順は `applications/dolphin/README.md` に記載する。

## 変更履歴（git log より自動生成）

- 588948d feat(#75): configure dolphin xwayland launch
