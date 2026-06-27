# mpv-player

`~/Music` 配下の音声・動画ファイルを fzf でインタラクティブに選択し、mpv で再生する Python スクリプト。

## 仕組み

1. `~/Music` を再帰的にスキャンし、対応する拡張子のメディアファイルを列挙する
2. fzf で選択またはキーワード絞り込みを行う
3. 選択結果を `~/Music/playlist/mpv-player.m3u` に書き出す
4. mpv を `--no-video` で起動し音声のみ再生する

メインメニューは以下の3モードを提供する。

| 選択 | 動作 |
|---|---|
| `1` | fzf でファイルを個別選択してプレイリスト作成 |
| `2` | fzf でキーワード絞り込み → 全件をプレイリストに追加 |
| `3` | 前回のプレイリストをそのまま再生 |

再生モード選択（`A`: 通常 / `B`: リピート / `C`: シャッフル）も対話的に行う。

## 対応拡張子

mp3, flac, aac, m4a, ogg, opus, wav, aiff, ape, wma, mkv, mp4, avi, mov, webm など主要な音声・動画形式に対応。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `mpv-player.py` | メインスクリプト（標準ライブラリ + fzf + mpv のみ） |
| `install.sh` | `~/.local/bin/mpv-player` にシンボリックリンクを作成 |

## インストール

```bash
./applications/mpv-player/install.sh
```

インストール後:

```bash
mpv-player
```

> **前提:** `fzf` と `mpv` がインストール済みであること（`t480s/t480s-apps-install.sh` で導入済み）。
