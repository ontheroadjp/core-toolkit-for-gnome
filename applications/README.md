# applications

アプリケーション単位の補助スクリプト・設定・デスクトップエントリを管理するディレクトリ。
各サブディレクトリが独立した機能を持ち、それぞれに `install.sh` を提供する。

## サブディレクトリ一覧

| ディレクトリ | 概要 |
|---|---|
| [`alacritty/`](alacritty/README.md) | Alacritty ターミナルエミュレータの設定ファイル |
| [`chrome/`](chrome/README.md) | Chrome DevTools Protocol (CDP) を有効化した Chrome 専用プロファイル起動ラッパー |
| [`espanso/`](espanso/README.md) | espanso のトグルスクリプトと GNOME キーバインド登録 |
| [`keyd/`](keyd/README.md) | keyd キーボードリマップ設定（CapsLock → Ctrl 等） |
| [`mpv-player/`](mpv-player/README.md) | カレントディレクトリの音楽/動画ファイルを fzf で選んで mpv 再生する Python スクリプト（`music`/`video` モード対応） |
| [`youtube/`](youtube/README.md) | CDP 経由で既存の YouTube タブを再利用して開く CLI ランチャー |
| [`yt-dlp/`](yt-dlp/README.md) | yt-dlp の設定ファイル（メタデータ埋め込み・mp4 出力等） |
| [`icons/`](icons/) | 各アプリケーションで使用するアイコン素材 |

## インストール方針

各サブディレクトリの `install.sh` はそれぞれ独立しており、必要なものだけ個別に実行できる。

```bash
# 例: Chrome CDP ラッパーのインストール
./applications/chrome/install.sh

# 例: mpv-player のインストール
./applications/mpv-player/install.sh
```
