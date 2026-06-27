# tmux-switch-us-input

tmux のペイン切替時に GNOME 入力ソースを US キーボードへ自動切替するシェルスクリプト。
`fep-switcher@local` の D-Bus メソッドを呼び出すクライアントとして動作する。

## 仕組み

```
tmux ペイン切替（after-select-pane フック）
    ↓
switch-input-to-us
    ↓
gdbus call → fep-switcher@local の SwitchToUs()
```

スクリプト自体は単純な `gdbus call` の1コマンドのみ。
tmux の `set-hook` でペイン切替のたびに実行される。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `switch-input-to-us` | D-Bus 経由で US 入力へ切替するシェルスクリプト |

## インストール

ルートの `install.sh` が `~/.local/bin/switch-input-to-us` へのシンボリックリンクを作成する。

```bash
./install.sh
```

その後、`~/.tmux.conf` に以下を追記してリロードする:

```tmux
set-hook -g after-select-pane 'run-shell "switch-input-to-us"'
```

```bash
# tmux 設定のリロード
tmux source ~/.tmux.conf
# または tmux 内で prefix + r（リロードキーバインドが設定済みの場合）
```

## 手動実行

```bash
switch-input-to-us
```

> **前提:** `fep-switcher@local`（`scripts/fep-switcher/`）が有効になっていること。
