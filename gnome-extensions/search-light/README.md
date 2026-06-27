# search-light

入力ソースを US キーボードに切替した後、GNOME Shell の search-light オーバーレイをトリガーするスクリプト。
日本語入力が有効な状態でも英字でそのまま検索を開始できるようにする。

## 仕組み

```
trigger-search-light
    ↓
1. gdbus で fep-switcher@local の SwitchToUs() を呼び出す
    ↓ 50ms 待機（入力ソース切替の完了を待つ）
2. gdbus で org.gnome.Shell.Eval を呼び出し
   searchLight._toggle_search_light() を実行
```

`fep-switcher@local` GNOME 拡張機能と search-light 拡張機能の両方が有効になっている必要がある。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `trigger-search-light` | 入力ソース切替 + search-light トグルを行うシェルスクリプト |
| `install.sh` | `~/.local/bin/trigger-search-light` にシンボリックリンクを作成 |

## インストール

```bash
./gnome-extensions/search-light/install.sh
```

インストール後、GNOME カスタムキーバインドに `trigger-search-light` を登録して使用する。

```bash
# キーバインド登録例（Super+Space）
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/customN/ name 'Search Light'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/customN/ command 'trigger-search-light'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/customN/ binding '<Super>space'
```

> **前提:** `fep-switcher@local` 拡張機能（`scripts/fep-switcher/`）が有効になっていること。
> search-light 拡張機能は別途 GNOME Extension Manager 等でインストール・有効化すること。
