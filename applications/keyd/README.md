# keyd

keyd を使ったキーボードリマップ設定。`install.sh` が keyd 本体のインストールと設定ディレクトリの配置を行う。

## キーマップ概要（`default.conf`）

| 元のキー | 変更後 | 補足 |
|---|---|---|
| `CapsLock` | `Left Ctrl` | ホームポジションでの Ctrl 操作 |
| `Left Ctrl` | `Left Meta` (Super) | GNOME キーバインドと干渉しないよう移動 |
| `PageUp` | `←` | ThinkPad トラックポイント周辺キーを矢印に |
| `PageDown` | `→` | 同上 |
| `F1` | `Meta+↑`（ウィンドウ最大化） | GNOME タイリング操作 |
| `F2` | `Meta+←`（左半画面） | GNOME タイリング操作 |
| `F3` | `Meta+→`（右半画面） | GNOME タイリング操作 |

## ファイル構成

| ファイル | 役割 |
|---|---|
| `default.conf` | keyd キーマップ定義（全キーボードに適用） |
| `install.sh` | keyd をインストールし、`/etc/keyd` をこのディレクトリへのシンボリックリンクに置き換える |

## インストール

```bash
./applications/keyd/install.sh
```

> **注意:** `sudo` が必要。`/etc/keyd` への配置と `keyd` サービスの有効化を行う。
