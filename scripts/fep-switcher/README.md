# fep-switcher

GNOME Shell 拡張機能として動作する入力ソース切替 D-Bus サービス。
`SwitchToUs()` / `SwitchToJa()` メソッドを D-Bus 経由で公開するコアコンポーネントであり、
自身はイベント処理を持たない。

## 仕組み

GNOME Shell 内で動作し、セッション D-Bus に以下のインターフェースを登録する。

| D-Bus 要素 | 値 |
|---|---|
| バス名 | `org.gnome.Shell.Extensions.FepSwitcher` |
| オブジェクトパス | `/org/gnome/Shell/Extensions/FepSwitcher` |
| インターフェース | `org.gnome.Shell.Extensions.FepSwitcher` |
| メソッド | `SwitchToUs()` / `SwitchToJa()` |

`SwitchToUs()` は GNOME 入力ソース一覧から `type=xkb, id=us` を探してアクティブにする。
`SwitchToJa()` は `type=ibus, id=mozc-jp` を探してアクティブにする。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `extension.js` | GNOME Shell 拡張機能本体 |
| `metadata.json` | 拡張機能メタデータ（uuid: `fep-switcher@local`） |

## インストール

ルートの `install.sh` がシンボリックリンク作成と有効化を行う。

```bash
./install.sh
```

手動でインストールする場合:

```bash
ln -sf "$(pwd)/scripts/fep-switcher" \
    ~/.local/share/gnome-shell/extensions/fep-switcher@local
gnome-extensions enable fep-switcher@local
```

> **注意:** Wayland 環境では新規インストールした拡張機能はログアウト/ログイン後に有効になる。

## D-Bus 呼び出し例

```bash
# US 入力へ切替
gdbus call --session \
    --dest org.gnome.Shell.Extensions.FepSwitcher \
    --object-path /org/gnome/Shell/Extensions/FepSwitcher \
    --method org.gnome.Shell.Extensions.FepSwitcher.SwitchToUs

# 日本語入力へ切替
gdbus call --session \
    --dest org.gnome.Shell.Extensions.FepSwitcher \
    --object-path /org/gnome/Shell/Extensions/FepSwitcher \
    --method org.gnome.Shell.Extensions.FepSwitcher.SwitchToJa
```
