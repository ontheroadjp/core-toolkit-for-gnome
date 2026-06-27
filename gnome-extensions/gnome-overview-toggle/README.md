# gnome-overview-toggle

GNOME Shell の Overview（アクティビティ画面）をトグルするシェルスクリプト。
D-Bus 経由で `OverviewActive` プロパティを読み書きし、現在の状態を反転させる。

## 仕組み

```
Ctrl+Shift+Space
    ↓
gnome-overview-toggle
    ↓
gdbus: OverviewActive を取得
    ↓ true なら
false を Set → Overview を閉じる
    ↓ false なら
true を Set  → Overview を開く
```

## ファイル構成

| ファイル | 役割 |
|---|---|
| `gnome-overview-toggle` | Overview をトグルするシェルスクリプト本体 |
| `install.sh` | `~/.local/bin/gnome-overview-toggle` にシンボリックリンクを作成し、GNOME カスタムキーバインド（`Ctrl+Shift+Space`）に登録 |

## インストール

```bash
./gnome-extensions/gnome-overview-toggle/install.sh
```

インストール後、`Ctrl+Shift+Space` で Overview をトグルできる。
