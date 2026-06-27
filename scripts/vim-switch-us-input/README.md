# vim-switch-us-input

Vim の Insert モード終了時に GNOME 入力ソースを US キーボードへ自動切替する Vim プラグイン。
`fep-switcher@local` の D-Bus メソッドを呼び出すクライアントとして動作する。

## 仕組み

```
InsertLeave オートコマンド（Insert モード終了）
    ↓
dbus-send → fep-switcher@local の SwitchToUs()
```

`job_start()` を使った非同期実行のため、GNOME Shell D-Bus サービスが応答しない場合でも
Insert モードの終了がブロックされない。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `plugin/vim-switch-us-input.vim` | Vim プラグイン本体 |
| `tests/test-vim-switch-us-input.sh` | 動作確認スクリプト |

## インストール

### vim-plug を使う場合

`~/.vimrc` の `plug#begin()` と `plug#end()` の間に追加する:

```vim
Plug 'ontheroadjp/core-toolkit-for-gnome', { 'rtp': 'scripts/vim-switch-us-input' }
```

追加後、Vim 内で `:PlugInstall` を実行。

### 手動インストール

```bash
# Vim の runtimepath が通っているディレクトリにコピーまたはリンク
ln -sf "$(pwd)/scripts/vim-switch-us-input/plugin/vim-switch-us-input.vim" \
    ~/.vim/plugin/vim-switch-us-input.vim
```

## 要件

- Vim に `+job` 機能が含まれていること（`vim-gtk3` 等、フル機能ビルドが対象）
- `fep-switcher@local`（`scripts/fep-switcher/`）が有効になっていること
- `dbus-send` コマンドが利用可能であること

> **注意:** `job_start()` は Vim に固有の機能であり、Neovim では動作しない。
