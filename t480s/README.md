# t480s

Lenovo ThinkPad T480s (Ubuntu 24.04 LTS / GNOME) の初期セットアップスクリプト群。
マシンを再現可能な状態にするため、アプリケーションのインストールと GNOME デスクトップ設定の一括適用を担う。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `t480s-apps-install.sh` | 開発ツール・CLI ツール・アプリケーションを一括インストール |
| `t480s-settings.sh` | GNOME デスクトップ設定を `gsettings` で一括適用 |

## t480s-apps-install.sh

`apt` および各ツールの公式インストーラ経由で以下を順番にインストールする（冪等性あり）。

| # | 対象 | 手段 |
|---|---|---|
| 1 | build-essential / curl / git / tmux / fzf / bat / vim-gtk3 / jq / yq | apt |
| 2 | hyperfine / rclone / gocryptfs / gpaste-2 | apt |
| 3 | htop / nethogs / iftop / whois / arp-scan | apt |
| 4 | ffmpeg / mpv | apt |
| 5 | gnome-shell-extension-manager | apt |
| 6 | keyd | PPA (`ppa:keyd-team/ppa`) |
| 7 | mise + Node.js 24 | 公式インストーラ + mise |
| 8 | gh (GitHub CLI) | GitHub 公式 apt リポジトリ |
| 9 | ghq | GitHub リリースバイナリ |
| 10 | Claude Code | 公式インストーラ |
| 11 | Codex CLI | npm (mise 経由の Node.js) |
| 12 | Google Chrome | 公式 .deb パッケージ |
| 13 | yt-dlp | GitHub リリースバイナリ |
| 14 | espanso | 公式 Wayland .deb パッケージ |

### 使い方

```bash
# sudo・ネットワーク必須
./t480s/t480s-apps-install.sh
```

各ステップは既にインストール済みの場合スキップする。

## t480s-settings.sh

`gsettings` および `/sys/class/power_supply/BAT0/` への書き込みで以下を設定する。

| 設定項目 | 値 |
|---|---|
| GNOME アニメーション | 有効 |
| キーリピート遅延 | 180ms |
| キーリピート間隔 | 10ms |
| IME 切替キー | `Ctrl+Space` |
| ワークスペース切替 | `Ctrl+1〜4` |
| ウィンドウドラッグ修飾キー | `Ctrl` |
| フォントヒンティング | full |
| フォントアンチエイリアス | grayscale |
| バッテリー充電開始閾値 | 30% |
| バッテリー充電停止閾値 | 85% |

### 使い方

```bash
# sudo 必須（バッテリー充電閾値の書き込みに必要）
./t480s/t480s-settings.sh
```

> **注意:** バッテリー充電閾値はシステム再起動後にリセットされる。
> 永続化には `tlp` のインストールと設定が必要（スクリプト末尾のコメント参照）。
