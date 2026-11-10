# プロジェクト概要

## 目的

Ubuntu 24.04 LTS / GNOME 環境を再現可能にするための
シェルスクリプト・設定ファイル集。ハードウェア固有の設定（バッテリー充電閾値等）は
`scripts/core-t480s-settings/` に分離されており、それ以外のモジュールは機種を問わず利用できる。
詳細な背景は [L0_concept/concept.md](../L0_concept/concept.md) を参照。

## 技術スタック（確認済み）

| 項目 | 内容 | 根拠 |
|---|---|---|
| 言語/ランタイム | POSIX sh / bash / Python 3 / GNOME Shell JavaScript | `scripts/core-gnome-settings/apply-settings.sh:1`、`gnome-extensions/gnome-overview-toggle/gnome-overview-toggle:1`、`scripts/battery-alert/battery_alert.py:1`、`scripts/fep-switcher/extension.js` |
| パッケージマネージャ（プロジェクト自体） | なし | `package.json` 等のマニフェスト不在を確認 |
| OSパッケージマネージャ（実行対象） | apt（Ubuntu/Debian系） | `scripts/core-tools/install.sh:9-10,27-32,38-50` |
| CI | なし | `.github/` ディレクトリ不在を確認 |
| テスト | 手動実行（unittest / bash） | `tests/test_install.sh`、`tests/lint_shell.sh`、各 `scripts/*/tests/`、`applications/mpv-player/tests/` |
| 対象デスクトップ環境 | GNOME Shell | `scripts/core-gnome-settings/apply-settings.sh` の `org.gnome.*` schema、`gnome-extensions/gnome-overview-toggle/gnome-overview-toggle` の `org.gnome.Shell` DBus 呼び出し |
| 対象ターミナルエミュレータ | Alacritty | `applications/alacritty/alacritty.toml` |

OSディストリビューションは Ubuntu 24.04 LTS (Noble Numbat)。
根拠: README.md に明記。

## 主要機能（実装から確認）

1. **GNOME デスクトップ設定の一括適用** — `scripts/core-gnome-settings/apply-settings.sh`
   - アニメーション有効化（`scripts/core-gnome-settings/apply-settings.sh:30`）
   - キーリピート速度設定（`scripts/core-gnome-settings/apply-settings.sh:38-40`）
   - 入力ソース切替用のカスタムキー登録（`scripts/core-gnome-settings/apply-settings.sh:43-47,89-129`）
   - ウィンドウ切替に Ctrl+Tab を追加し、switch-panels をリセット（`scripts/core-gnome-settings/apply-settings.sh:53-56`）
   - ワークスペース切替を Ctrl+1〜4 に設定（`scripts/core-gnome-settings/apply-settings.sh:61-64`）
   - ウィンドウドラッグの修飾キーを Ctrl に設定（`scripts/core-gnome-settings/apply-settings.sh:69`）
   - フォントヒンティング/アンチエイリアス設定（`scripts/core-gnome-settings/apply-settings.sh:76-77`）
   - 機種不問。`fep-toggle` の sudoers ルール設置に `sudo` が必要（`scripts/core-gnome-settings/apply-settings.sh:131-162`）

1a. **ThinkPad 固有: バッテリー充電閾値設定** — `scripts/core-t480s-settings/apply-settings.sh`
   - TLP の充電開始/停止閾値を70%/85%に設定（`scripts/core-t480s-settings/apply-settings.sh:19-32`、`sudo` 必須）
   - TLP と ThinkPad の充電閾値対応が必要

2. **開発・利用ツールのセットアップ** — `scripts/core-tools/install.sh`
   - 基本開発ツール一式の apt インストール（`scripts/core-tools/install.sh:9-21`）
   - システムユーティリティ（hyperfine, rclone, gocryptfs）の導入（`scripts/core-tools/install.sh:27-32`）
   - システム監視ツール（htop, ncdu, nethogs, iftop, whois, arp-scan）の導入（`scripts/core-tools/install.sh:38-44`）
   - GNOME 拡張管理ツールの導入（`scripts/core-tools/install.sh:50`）
   - `mise` 経由での Node.js 24 のセットアップ（`scripts/core-tools/install.sh:85-91`）
   - `gh` (GitHub CLI) / `ghq` の条件付きインストール（`core-tools/install.sh:94-120`）
   - Claude Code / OpenAI Codex CLI の条件付きインストール（`core-tools/install.sh:124-141`）

3. **dotfiles・アプリ設定の一括インストール** — `install-all.sh`（ルート）
   - `scripts/core-tools/install.sh` を呼び出し後、各 `applications/*/install.sh` を順に実行
   - GNOME 拡張（fep-switcher, app-switch-us-input）のシンボリックリンクと有効化
   - `scripts/tmux-switch-us-input/switch-input-to-us` を `~/.local/bin/` にリンク
   - （`install-all.sh` 全体を確認済み）

4. **Alacritty 端末設定** — `applications/alacritty/`
   - フォント・ウィンドウ装飾・配色・キーバインドの設定
     （`applications/alacritty/alacritty.toml`）
   - 3種類の配色テーマ（`tokyo-night`, `tokyo-night-storm`, `dracula`）を
     `theme/` 配下に保持し、`import` 行で切り替える方式
     （`alacritty.toml:5-6`）。現在アクティブなのは
     `tokyo-night.toml`（`alacritty.toml:5` がコメントアウトされていない行）。

5. **GNOME Overview トグルスクリプト** — `gnome-extensions/gnome-overview-toggle/`
   - `gdbus` で `org.gnome.Shell` の `OverviewActive` プロパティを取得し、
     反転した値を設定することで Activities Overview の開閉をトグルする。
   - `gnome-extensions/gnome-overview-toggle/install.sh` が
     `~/.local/bin/gnome-overview-toggle` へのシンボリックリンクと
     GNOME カスタムキーバインドを登録する。

6. **バッテリー低下通知** — `scripts/battery-alert/`
   - `battery_alert.py`（標準ライブラリのみ）が `/sys/class/power_supply/BAT*`
     を読み、放電中に新たに越えたしきい値のうち最も低いものを1回通知し、越えた全しきい値を記録する（`scripts/battery-alert/battery_alert.py:90-112`）。
   - systemd timer（`.config/systemd/user/battery-alert.timer`）が定期実行。
   - `tests/test_battery_alert.py` に `unittest` ベースのテストがある。

7. **mpv music/video launcher** — `applications/mpv-player/`
   - 実行時のカレントディレクトリ配下からモード別にファイルを選び playlist を作成する（`applications/mpv-player/mpv-player.py:284-312`）。
   - `install.sh` で `~/.local/bin/mpv-player` へのシンボリックリンクを作成する（`applications/mpv-player/install.sh`）。

8. **FEP 入力ソース切替（4コンポーネント構成）** — `scripts/fep-switcher/` 他
   - `fep-switcher`: D-Bus サービス `SwitchToUs()` / `SwitchToJa()` を提供
   - `app-switch-us-input`: ウィンドウフォーカス時に US へ切替
   - `tmux-switch-us-input`: tmux pane 切替時に US へ切替
   - `vim-switch-us-input`: Vim Insert mode 終了時に US へ切替

9. **オフライン音声入力** — `scripts/voice-input/`
   - `Ctrl+Shift+=` で録音トグル、whisper.cpp で文字起こし後 Wayland クリップボードへコピー。
   - systemd ユーザーサービスでモデルを常駐。

10. **テキスト展開** — `applications/espanso/`
    - espanso（Wayland 対応 Inject backend）でテキスト展開。
    - `applications/espanso/install.sh` が `~/.config/espanso` へのシンボリックリンクを作成。

11. **Chrome CDP 専用プロファイル起動** — `applications/chrome/`
    - `--remote-debugging-port=9222` と専用 `--user-data-dir` を付与した Google Chrome
      ラッパー（`google-chrome-cdp`）。通常の Chrome プロファイルとは分離される。
    - `install-all.sh:70` から呼び出される。未インストール時は Chrome の `.deb` を取得して導入する。

11a. **Dolphin の XWayland 起動** — `applications/dolphin/install.sh`
    - Dolphin を導入し、システムの desktop entry を基にユーザーエントリーを生成する。未管理・編集済みの既存エントリーは保護する。

12. **YouTube CDP ランチャー** — `applications/youtube/`
    - `applications/chrome/` の CDP エンドポイント（`localhost:9222`）へ接続し、既存の
      YouTube タブがあれば再利用してナビゲート、なければ `google-chrome-cdp` を新規起動する
      （`applications/youtube/youtube`）。
    - `install-all.sh` からは呼び出されない（個別実行が必要）。

13. **search-light トリガー（US入力切替つき）** — `gnome-extensions/search-light/`
    - `fep-switcher@local` で入力ソースを US に切り替えた後、外部の search-light GNOME 拡張の
      オーバーレイをトグルする（`trigger-search-light`）。
    - `install-all.sh` からは呼び出されない（個別実行が必要）。

## このプロジェクトではないもの（スコープ外であることの確認）

- Web/モバイルアプリケーションではない（フレームワーク・ビルド設定が
  存在しないことを確認済み）。
- データベース・APIサーバーを持たない（該当する実装ファイルが
  存在しないことを確認済み）。
- CIパイプラインを持たない（`.github/` 不在を確認済み）。一部の
  `scripts/` と `applications/` 配下の Python/bash ツールには手動実行前提の
  テストがある。
