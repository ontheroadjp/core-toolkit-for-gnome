# プロジェクト概要

## 目的

Lenovo ThinkPad T480s 上の GNOME (Ubuntu) 環境を再現可能にするための
個人用シェルスクリプト・設定ファイル集。詳細な背景は
[L0_concept/concept.md](../L0_concept/concept.md) を参照。

## 技術スタック（確認済み）

| 項目 | 内容 | 根拠 |
|---|---|---|
| 言語/ランタイム | POSIX sh / bash / Python 3 | `t480s.sh:1`、`t480s_apps.sh:1` は `#!/bin/bash`、`.local/bin/gnome-overview-toggle:1` は `#!/bin/sh`、`scripts/*/*.py` は `#!/usr/bin/env python3` |
| パッケージマネージャ（プロジェクト自体） | なし | `package.json` 等のマニフェスト不在を確認 |
| OSパッケージマネージャ（実行対象） | apt（Ubuntu/Debian系） | `t480s_apps.sh:9,29,39` |
| CI | なし | `.github/` ディレクトリ不在を確認 |
| 対象デスクトップ環境 | GNOME Shell | `t480s.sh` の `org.gnome.*` schema、`.local/bin/gnome-overview-toggle` の `org.gnome.Shell` DBus 呼び出し |
| 対象ターミナルエミュレータ | Alacritty | `.config/alacritty/alacritty.toml` |

OSディストリビューションは Ubuntu 24.04.4 LTS (Noble Numbat)。
根拠: OS情報ファイル(`os-release`、`/etc` 配下)の `PRETTY_NAME="Ubuntu 24.04.4 LTS"`
（ライブシステムで確認。リポジトリ内にOS名を明記したファイルはない）。

## 主要機能（実装から確認）

1. **GNOME デスクトップ設定の一括適用** — `t480s.sh`
   - アニメーション有効化（`t480s.sh:7`）
   - キーリピート速度設定（`t480s.sh:12-14`）
   - 入力ソース切り替えを Ctrl+Space に変更（`t480s.sh:26`）
   - ウィンドウドラッグの修飾キーを Super から Ctrl に変更（`t480s.sh:31`）
   - ウィンドウの左右タイル化キーバインドを Ctrl+矢印に変更（`t480s.sh:38-39`）
   - フォントヒンティング/アンチエイリアス設定（`t480s.sh:46-47`）
   - バッテリー充電閾値を30%/85%に設定（`t480s.sh:53-54`、`sudo` 必須）

2. **開発・利用ツールのセットアップ** — `t480s_apps.sh`
   - 基本開発ツール一式の apt インストール（`t480s_apps.sh:9-20`）
   - ランチャー/暗号化/クラウドストレージ系ツール（rofi, gocryptfs, rclone）の
     導入（`t480s_apps.sh:29-33`）
   - メディア系ツール（yt-dlp, ffmpeg, mpv）の導入（`t480s_apps.sh:39-42`）
   - `keyd`（キーリマップデーモン）の条件付きインストールと有効化
     （`t480s_apps.sh:47-54`）
   - `mise` 経由での Node.js 24 のセットアップ（`t480s_apps.sh:57-63`）
   - `gh` (GitHub CLI) / `ghq` の条件付きインストール（`t480s_apps.sh:66-89`）
   - Claude Code / OpenAI Codex CLI の条件付きインストール
     （`t480s_apps.sh:92-105`）
   - Google Chrome の条件付きインストール（`t480s_apps.sh:108-117`）
   - `yt-dlp` の最新バイナリ取得・更新（`t480s_apps.sh:120-128`）

3. **Alacritty 端末設定** — `.config/alacritty/`
   - フォント・ウィンドウ装飾・配色・キーバインドの設定
     （`.config/alacritty/alacritty.toml`）
   - 3種類の配色テーマ（`tokyo-night`, `tokyo-night-storm`, `dracula`）を
     `theme/` 配下に保持し、`import` 行で切り替える方式
     （`.config/alacritty/alacritty.toml:5-6`）。現在アクティブなのは
     `tokyo-night.toml`（`alacritty.toml:5` がコメントアウトされていない行）。

4. **GNOME Overview トグルスクリプト** — `.local/bin/gnome-overview-toggle`
   - `gdbus` で `org.gnome.Shell` の `OverviewActive` プロパティを取得し、
     反転した値を設定することで Activities Overview の開閉をトグルする
     （`.local/bin/gnome-overview-toggle:3-22`）。
   - 実機上では `dconf` のカスタムキーバインド `custom0` から
     `Shift+Ctrl+Space` に割り当てられていることをライブシステムの
     `dconf dump` で確認済み（リポジトリ内にこの割り当てを記録した
     ファイルは存在しない — 詳細は
     [repository_structure.md](repository_structure.md) の未確認事項を参照）。

5. **mpv music launcher** — `scripts/mpv-player/`
   - `~/Music` 配下の音声/動画ファイルを対象に playlist を作成し、
     `mpv --no-video` で再生する（`scripts/mpv-player/mpv-player.py`）。
   - `install.sh` で `~/.local/bin/music` へのシンボリックリンクを作成する。
   - playlist は `~/Music/playlist/mpv-player.m3u` に上書き保存される。

## このプロジェクトではないもの（スコープ外であることの確認）

- Web/モバイルアプリケーションではない（フレームワーク・ビルド設定が
  存在しないことを確認済み）。
- データベース・APIサーバーを持たない（該当する実装ファイルが
  存在しないことを確認済み）。
- CIパイプラインを持たない（`.github/` 不在を確認済み）。一部の
  `scripts/` 配下 Python ツールには `unittest` ベースのテストがある。
