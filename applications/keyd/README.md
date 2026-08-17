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
| `Ctrl+Space` | `Scroll_Lock` | Mozc 変換中に ibus が生の Ctrl+Space を先取りしてしまうのを避けるため、GNOME に渡す前に無関係なキーへ変換する |
| `Ctrl+Shift+Space` | 変換なし（Ctrl+Shift+Space のまま） | 上記の remap は Shift を区別しないため、`[control+shift]` composite layer で `space = C-S-space` を明示バインドし、GNOME 側の `<Control><Shift>space`（Nuts Launcher）に生のキー入力が届くようにしている（#56） |

Mozc 入力中のみ、`k` の直後に `j` を押すと未確定文字を破棄して Escape を送る
（Vim 風の "kj" コンボ）。この挙動は `default.conf` に静的には書かれておらず、
`scripts/fep-switcher/extension.js` が入力ソース切替のたびに `fep-toggle` 経由で
`keyd bind` を発行し、Mozc 選択時のみ動的に有効化する（US 選択時は無効化される）。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `default.conf` | keyd キーマップ定義（全キーボードに適用） |
| `fep-toggle.sh` | keyd の `k` バインド同期（`--keyd-us`/`--keyd-mozc`）と、keyd が `Ctrl+Space` を変換した `Scroll_Lock` から起動される FEP トグルを兼ねるスクリプト |
| `install.sh` | keyd をインストールし、`/etc/keyd` をこのディレクトリへのシンボリックリンクに置き換え、`fep-toggle.sh` を `/usr/local/bin/fep-toggle` へ配置する |

## インストール

```bash
./applications/keyd/install.sh
```

> **注意:** `sudo` が必要。`/etc/keyd` への配置、`keyd` サービスの有効化、
> `/usr/local/bin/fep-toggle` の配置を行う。`Scroll_Lock`（keyd が変換した `Ctrl+Space`）
> キーバインドと `fep-toggle` 用の sudoers 設定は
> `scripts/core-gnome-settings/apply-settings.sh` が別途行う。
> `default.conf` を変更した場合は `sudo keyd reload` で反映する。

## 既知の問題（issue #51）

Mozc に未確定の変換がある状態で Ctrl+Space（CapsLock+Space）を押して FEP を
切り替えると、以降のキー入力が Ctrl を押していないのに Ctrl+`<key>` として認識される
「Ctrl が押しっぱなし」状態になることがある。`sudo keyd monitor -t` では evdev レベルの
イベントは常に正しく対になっており、keyd 自体（evdev レベル）は原因ではないと確認済み。
未確定の変換がある状態で FEP を切り替えると、その未確定文字列は破棄されず確定・挿入
されたうえで切替が行われる。

**暫定回避策**: もう一度 FEP を切り替える（Ctrl+Space をもう一度押す）と解消する。

**試して効果がなかった対応（issue #58）**:
- `Scroll_Lock` の代わりに `Pause` へ変換する: `Scroll_Lock+Any` が `LockMods`
  という特殊なロック系アクションとして解釈される（`/usr/share/X11/xkb/compat/misc`）
  ことが原因ではという仮説のもと検証したが、このルールを持たない通常のキーである
  `Pause` に変えても症状は解消しなかった。
- FEP 切替の前に `Escape` を1回送り、Mozc の未確定文字列を先にキャンセルしてから
  切り替える: 未確定入力の有無に関係なく、通常のタイピング中でも数秒おきに
  勝手に FEP が切り替わる別の重大な回帰を引き起こしたため撤回した。原因は
  特定できていない。
- FEP 切替そのものを3回連続で実行する（D-Bus 経由・keyd macro 経由いずれも）:
  最終的な入力ソースは正しく戻るが、症状は解消しなかった。D-Bus 経由（`fep-toggle.sh`
  から `gdbus call` で `fep-switcher@local` を直接複数回呼ぶ）の場合、実際の
  キーイベントを一切発生させないため、原理的にコンポジタ側のモディファイア状態を
  変え得ないと考えられる。

原因調査・過去の対応状況は issue #51 とその native sub-issue（#52〜#54）、
および #58 を参照。
