# key-input-management diagnostics

keyd・ibus・GNOME Shell 拡張（`scripts/fep-switcher/`）・D-Bus など、キー入力/FEP切替まわりを
横断する不具合の調査用ツール置き場。

## `capture-ctrl-stuck-diagnostics.sh`

issue #51（Ctrl+Space で FEP を切り替えた際、Mozc の未確定変換と重なると Ctrl が
押しっぱなし状態になる不具合）の原因切り分けのため、keyd・libinput・ibus それぞれの
イベント/ログを個別に採取するツール。3系統は同時に別ターミナルで起動し、同じ出力先
ディレクトリを指定することでログを突き合わせる。

```bash
mkdir -p /tmp/ctrl-stuck-diagnostics

# ターミナル1（root 権限が必要な keyd 側の評価用。sudo は手動で付与する）
sudo ./diagnostics/key-input-management/capture-ctrl-stuck-diagnostics.sh /tmp/ctrl-stuck-diagnostics keyd

# ターミナル2（root 権限が必要な libinput 側。sudo は手動で付与する。libinput-tools が必要）
sudo ./diagnostics/key-input-management/capture-ctrl-stuck-diagnostics.sh /tmp/ctrl-stuck-diagnostics libinput

# ターミナル3（ibus 側。root 権限不要）
./diagnostics/key-input-management/capture-ctrl-stuck-diagnostics.sh /tmp/ctrl-stuck-diagnostics ibus
```

3つとも起動した状態で、Mozc に未確定の変換を作ってから CapsLock+Space（＝ Ctrl+Space）で
FEP を切り替え、不具合を再現する。各ターミナルで Ctrl+C を押すと停止し、
`/tmp/ctrl-stuck-diagnostics/{keyd,libinput,ibus}.log` にログが残る。

## 前提

- `libinput` モードには `libinput-tools` パッケージが必要（`sudo apt install libinput-tools`）。
  未インストールの場合はコマンドが見つからない旨のエラーで失敗する。
- `keyd`・`libinput` モードは root 権限を要するコマンドを実行するため、
  スクリプト自体を `sudo` を付けて起動する。スクリプトは sudo の昇格や認証キャッシュを
  一切行わない（起動時にユーザーが判断して付与する）。

## 既知の暫定回避策

不具合が発生した場合、もう一度 FEP を切り替える（CapsLock+Space を再度押す）と
Ctrl の押しっぱなし状態は解消する（issue #51 参照）。
