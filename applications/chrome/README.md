# chrome

Chrome DevTools Protocol (CDP) を有効化した専用プロファイルの Google Chrome を起動するラッパー。
通常の Chrome とは完全に分離したプロファイルで動作するため、開発・自動化用途に汚染されることがない。

## 仕組み

`google-chrome-cdp` スクリプトが以下のオプションを付与して Chrome を起動する。

| オプション | 値 | 目的 |
|---|---|---|
| `--remote-debugging-port` | `9222` | CDP エンドポイントを公開 |
| `--user-data-dir` | `~/.config/google-chrome-cdp` | 通常 Chrome と分離した専用プロファイル |
| `--class` | `google-chrome-cdp` | ウィンドウクラスで識別可能にする |

起動後は `http://localhost:9222` で CDP API にアクセスできる。`youtube` スクリプト等がこの CDP エンドポイントを利用してタブ操作を自動化する。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `google-chrome-cdp` | Chrome を CDP 有効・専用プロファイルで起動するシェルスクリプト |
| `google-chrome-cdp.desktop` | GNOME アプリケーションメニュー用デスクトップエントリ |
| `install.sh` | `~/.local/bin/` と `~/.local/share/applications/` にシンボリックリンクを作成 |

## インストール

```bash
./applications/chrome/install.sh
```

インストール後、以下の方法で起動できる。

```bash
# CLI から起動
google-chrome-cdp

# URL を渡して開く
google-chrome-cdp https://example.com
```

GNOME のアプリケーションメニューには `(CDP) Google Chrome` として表示される。
