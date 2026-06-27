# alacritty

Alacritty ターミナルエミュレータの設定ファイルと GNOME デスクトップエントリを管理するディレクトリ。
`install.sh` が設定ディレクトリをシンボリックリンクとして `~/.config/alacritty` に配置する。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `alacritty.toml` | Alacritty 本体設定（フォント・テーマ・キーバインド） |
| `theme/` | カラーテーマ TOML ファイル群（tokyo-night 等） |
| `Alacritty.desktop` | GNOME アプリケーションメニュー用デスクトップエントリ |
| `install.sh` | `~/.config/alacritty` と `~/.local/share/applications/Alacritty.desktop` にシンボリックリンクを作成 |

## インストール

```bash
./applications/alacritty/install.sh
```

インストール後、Alacritty の設定変更はこのリポジトリの `alacritty.toml` を直接編集すればよい（`live_config_reload = true` のため即時反映される）。
