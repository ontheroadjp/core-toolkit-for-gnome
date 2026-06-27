# root

ホームディレクトリ配下の設定ファイル（dotfiles）およびシステム設定ファイルを管理するディレクトリ。
`install.sh` がリポジトリ内のパスをシンボリックリンクで実機のパスに接続する。

## ディレクトリ構造

```
root/
├── etc/
│   └── keyd/
│       └── default.conf          # keyd キーリマップ設定
└── home/user/
    ├── .config/
    │   ├── alacritty/
    │   │   ├── alacritty.toml    # Alacritty メイン設定
    │   │   └── theme/            # カラーテーマ（3種類）
    │   ├── espanso/
    │   │   ├── config/           # espanso 動作設定
    │   │   └── match/            # テキスト展開ルール
    │   ├── mpv/
    │   │   ├── mpv.conf          # mpv プレーヤー設定
    │   │   └── input.conf        # mpv キーバインド
    │   └── yt-dlp/
    │       └── config            # yt-dlp デフォルトオプション
    └── .local/
        ├── bin/
        │   └── gnome-overview-toggle  # GNOME Activities トグルスクリプト
        └── share/applications/
            └── Alacritty.desktop      # Alacritty デスクトップエントリ
```

## 各設定の概要

### keyd (`etc/keyd/default.conf`)

`keyd` によるカーネルレベルのキーリマップ設定。

| 元キー | リマップ先 |
|---|---|
| CapsLock | Left Ctrl |
| Left Ctrl | Super (Meta) |
| PageUp | Left |
| PageDown | Right |
| F1 | Super+Up (ウィンドウ最大化) |
| F2 | Super+Left (左タイル) |
| F3 | Super+Right (右タイル) |

リンク先: `/etc/keyd/default.conf`（`install.sh` が `sudo ln -sf` で接続）

### Alacritty (`.config/alacritty/`)

高速ターミナルエミュレータ Alacritty の設定。3種類のカラーテーマを収録。

| テーマファイル | 説明 |
|---|---|
| `theme/tokyo-night.toml` | Tokyo Night（ダーク） |
| `theme/tokyo-night-storm.toml` | Tokyo Night Storm（より暗め） |
| `theme/dracula.toml` | Dracula |

テーマ切替は `alacritty.toml` の `import` 行を書き換えるだけでよい（`live_config_reload = true` により即時反映）。

リンク先: `~/.config/alacritty`

### espanso (`.config/espanso/`)

テキスト展開ツール espanso の設定。

| ファイル | 内容 |
|---|---|
| `config/default.yml` | バックエンド・動作設定（Wayland Clipboard 対応） |
| `match/base.yml` | 共通トリガー（`:date` 等のサンプル） |
| `match/html.yml` | HTML スニペット |
| `match/private.yml` | 個人情報トリガー（Git 管理外） |
| `match/private.yml.example` | private.yml のテンプレート |

リンク先: `~/.config/espanso`

### mpv (`.config/mpv/`)

メディアプレーヤー mpv の設定とキーバインド。

リンク先: `~/.config/mpv`

### yt-dlp (`.config/yt-dlp/config`)

YouTube 等からの動画・音声ダウンロードツール yt-dlp のデフォルトオプション。

リンク先: `~/.config/yt-dlp/config`

### gnome-overview-toggle (`.local/bin/gnome-overview-toggle`)

`gdbus` を使って GNOME Shell の Activities Overview をトグルするスクリプト。
GNOME カスタムキーバインドに登録して使用する。

リンク先: `~/.local/bin/gnome-overview-toggle`

## インストール

ルートの `install.sh` が各シンボリックリンクを一括作成する。

```bash
./install.sh
```
