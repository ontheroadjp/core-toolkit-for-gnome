# `applications/mpv-player/install.sh`

## 目的・役割

`mpv-player.py` を `~/.local/bin/mpv-player` に配置し、必要な apt パッケージ
（`ffmpeg`, `mpv`）を導入するインストーラ。`sudo` を要する（`install.sh:8`）。

## 動作の概要と主要ロジック

1. `sudo apt install -y ffmpeg mpv`（`install.sh:8`）
2. `${BIN_DIR}`（`~/.local/bin`）と `${CONFIG_DIR}`（`~/.config`）を作成
3. `mpv-player.py` に実行権限を付与し、`${BIN_DIR}/mpv-player` へ `ln -sfn` で
   シンボリックリンクを作成（`install.sh:12-13`）
4. `applications/mpv-player/` ディレクトリ自体を `~/.config/mpv` へ
   シンボリックリンク（`mpv.conf` / `input.conf` を mpv に認識させるため）

## 重要な設計判断

### コマンドは単一の `mpv-player`（`music`/`video` はサブコマンド引数）

以前は `mpv-music-player.py` と `mpv-video-player.sh` をそれぞれ
`~/.local/bin/mpv-music-player` / `mpv-video-player` としてリンクしていたが、
本体スクリプトの統合に伴い単一コマンド `mpv-player` に戻した。
利用者は `mpv-player music` / `mpv-player video` として呼び出す。

### `ln -sf` ではなく `ln -sfn`

シンボリックリンク先がディレクトリの場合に `ln -sf` だとリンク先ディレクトリの
配下に作成されてしまう曖昧さがあるため、`-n` でリンク自体を張り替える
（分割前から継続している既存の設計判断）。

## 統合ポイント

- 呼び出し元: ルートの `install-all.sh`（`applications/mpv-player/install.sh` を呼ぶ）
- 呼び出し先: `applications/mpv-player/mpv-player.py`
- テスト: `tests/test_install.sh`（`mpv-player.py` の存在確認、install-all.sh からの
  呼び出し確認、shellcheck/`bash -n` 構文チェック）

## 注意事項・既知の制限

- `sudo apt install` を無条件実行するため、AI が自律的に実行することは想定しない
  （`CLAUDE.md` 参照）

## 変更履歴（git log より自動生成）

- 778b08c refactor(#40): merge mpv-video-player.sh into mpv-player.py with music/video mode
- e59fb39 fix(mpv-player): split mpv wrapper into music and video players
- 6b93fec chore(#31): replace t480s-apps-install.sh with per-app install.sh and scripts/core-tools/install.sh
- 8045f0a chore(#29): reorganize root/ dotfiles into applications/ and gnome-extensions/
- 32bfb58 refactor(mpv-player): move from scripts/ to applications/
