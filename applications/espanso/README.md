# espanso

espanso（テキスト展開ツール）のトグルスクリプトと GNOME キーバインド登録ユーティリティ。
テキスト展開ルール本体は [`root/home/user/.config/espanso/`](../../root/home/user/.config/espanso/) で管理する。

## 仕組み

`espanso-toggle` が `espanso status` で動作状態を確認し、起動中なら停止・停止中なら起動する。
操作結果は `notify-send` でデスクトップ通知として表示される。

```
Ctrl+Alt+E
    ↓
espanso-toggle
    ↓ 起動中なら
espanso stop  → 通知「stopped」
    ↓ 停止中なら
espanso start → 通知「started」
```

## ファイル構成

| ファイル | 役割 |
|---|---|
| `espanso-toggle` | espanso を起動/停止するトグルスクリプト |
| `install.sh` | `espanso-toggle` を `~/.local/bin/` にシンボリックリンク |
| `set-gnome-shortcut-for-expanso.sh` | GNOME カスタムキーバインドに `Ctrl+Alt+E` を登録 |

## インストール

```bash
# トグルスクリプトを ~/.local/bin/ に配置
./applications/espanso/install.sh

# GNOME キーバインドを登録（Ctrl+Alt+E → espanso-toggle）
./applications/espanso/set-gnome-shortcut-for-expanso.sh
```

> **前提:** espanso 本体は `t480s/t480s-apps-install.sh` でインストール済みであること。
> espanso サービスの初回登録は別途手動で行う:
> ```bash
> espanso service register
> espanso service start
> ```
