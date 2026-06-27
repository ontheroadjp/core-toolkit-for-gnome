# app-switch-us-input

ターミナルウィンドウがフォーカスを得たとき、自動的に US キーボード入力ソースへ切替する GNOME Shell 拡張機能。
`fep-switcher@local` の D-Bus メソッドを呼び出すクライアントとして動作する。

## 仕組み

```
ウィンドウフォーカス変化（notify::focus-window）
    ↓
フォーカスウィンドウが TERMINAL_IDENTIFIERS に含まれるか判定
    ├── 非ターミナル → 何もしない
    └── ターミナル → D-Bus で fep-switcher@local の SwitchToUs() を呼び出す
```

フォーカス変化後は GLib idle キューで非同期処理するため、GNOME Shell の動作をブロックしない。

## 対応ターミナル

Alacritty, Ghostty, COSMIC Terminal, foot, gnome-terminal, kitty, Konsole,
GNOME Console, GNOME Ptyxis, Terminator, WezTerm, xterm

## ファイル構成

| ファイル | 役割 |
|---|---|
| `extension.js` | GNOME Shell 拡張機能本体 |
| `metadata.json` | 拡張機能メタデータ（uuid: `app-switch-us-input@local`） |

## インストール

ルートの `install.sh` がシンボリックリンク作成と有効化を行う。

```bash
./install.sh
```

手動でインストールする場合:

```bash
ln -sf "$(pwd)/scripts/app-switch-us-input" \
    ~/.local/share/gnome-shell/extensions/app-switch-us-input@local
gnome-extensions enable app-switch-us-input@local
```

> **前提:** `fep-switcher@local`（`scripts/fep-switcher/`）が有効になっていること。
