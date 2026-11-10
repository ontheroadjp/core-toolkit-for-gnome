# core-gnome-settings

Ubuntu / GNOME 向けの設定を `gsettings` で一括適用するスクリプト。
ThinkPad に限らず、GNOME が動作する環境であれば機種を問わず利用できる。

## 設定内容

| 設定項目 | 値 |
|---|---|
| GNOME アニメーション | 有効 |
| キーリピート遅延 | 180ms |
| キーリピート間隔 | 10ms |
| IME 切替キー | `Ctrl+Space`（custom keybinding、`/usr/local/bin/fep-toggle` を起動） |
| Mozc 起動時の入力モード | ひらがな（`active_on_launch: True`） |
| ウィンドウ切替 | `Alt+Tab` + `Ctrl+Tab`（backward: `Shift+Alt+Tab` + `Shift+Ctrl+Tab`） |
| switch-panels | デフォルトにリセット |
| ワークスペース切替 | `Ctrl+1〜4` |
| ウィンドウドラッグ修飾キー | `Ctrl` |
| フォントヒンティング | full |
| フォントアンチエイリアス | grayscale |

前提: `applications/keyd/install.sh` が `/usr/local/bin/fep-toggle` を
配置済みであること（IME 切替キーバインドの起動先）。

## 使い方

```bash
./scripts/core-gnome-settings/apply-settings.sh
```

`gsettings` の適用自体は `sudo` 不要だが、`Ctrl+Space` キーバインドの登録に
加えて `fep-toggle` 用の passwordless sudo ルール（`/etc/sudoers.d/fep-toggle`）
を `visudo -c` 検証の上で自動設置するため、実行時に `sudo` を要する。
いずれも再実行しても重複登録されない（冪等）。GNOME の設定は即時反映される。
Mozc の設定は IBus の再起動または再ログイン後に反映される。
