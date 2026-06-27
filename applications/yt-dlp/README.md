# yt-dlp

yt-dlp の設定ファイルと自動インストールスクリプト。
`install.sh` が yt-dlp 本体のインストールと設定ディレクトリの配置を行う。

## 設定概要（`config`）

| オプション | 内容 |
|---|---|
| `--js-runtimes node` | JavaScript ランタイムとして Node.js を使用 |
| `--embed-metadata` | ダウンロードファイルにメタデータを埋め込む |
| `--embed-thumbnail` | サムネイルをファイルに埋め込む |
| `--merge-output-format mp4` | 動画と音声をマージする際の出力形式を mp4 に統一 |

## ファイル構成

| ファイル | 役割 |
|---|---|
| `config` | yt-dlp のデフォルトオプション設定 |
| `install.sh` | yt-dlp をインストール（未導入時）またはアップグレードし、`~/.config/yt-dlp` にシンボリックリンクを作成 |

## インストール

```bash
./applications/yt-dlp/install.sh
```

> **注意:** インストール時は `sudo` が必要。既にインストール済みの場合はアップグレードを実行する。
