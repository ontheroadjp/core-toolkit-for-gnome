# youtube

Chrome DevTools Protocol (CDP) を利用して YouTube を効率的に開く CLI ランチャー。
既に CDP Chrome で YouTube タブが開いている場合は新しいウィンドウを開かず、既存タブを再利用してナビゲートする。

## 仕組み

```
youtube [検索キーワード]
    ↓
http://localhost:9222 (CDP) へ接続確認
    ├── 接続不可 → google-chrome-cdp を新規起動
    └── 接続可
            ├── YouTube タブあり → CDP の Page.navigate で既存タブを遷移
            └── YouTube タブなし → google-chrome-cdp で新規タブを開く
```

CDP 接続には `google-chrome-cdp`（`applications/chrome/`）が起動済みである必要がある。
WebSocket フレームの送受信はスクリプト内の Python インラインコードで実装しており、外部ライブラリは不要。

## 使い方

```bash
# YouTube のトップページを開く
youtube

# キーワードで検索する
youtube lo-fi music
```

引数を渡すと `https://www.youtube.com/results?search_query=<URL エンコード済みキーワード>` に遷移する。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `youtube` | メインスクリプト（bash + Python インライン） |
| `youtube.desktop` | GNOME アプリケーションメニュー用デスクトップエントリ |
| `install.sh` | `~/.local/bin/` と `~/.local/share/applications/` にシンボリックリンクを作成 |

## インストール

```bash
./applications/youtube/install.sh
```

> **前提:** `applications/chrome/install.sh` で `google-chrome-cdp` がインストール済みであること。
