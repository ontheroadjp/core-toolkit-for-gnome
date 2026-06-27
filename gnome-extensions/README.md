# gnome-extensions

GNOME Shell 拡張機能の補助スクリプトを管理するディレクトリ。
拡張機能本体（`fep-switcher`・`app-switch-us-input`）は [`scripts/`](../scripts/) で管理し、
このディレクトリは外部拡張機能を操作するためのラッパースクリプトを置く。

## サブディレクトリ一覧

| ディレクトリ | 概要 |
|---|---|
| [`gnome-overview-toggle/`](gnome-overview-toggle/README.md) | GNOME Overview（アクティビティ画面）をキーバインドでトグルするスクリプト |
| [`search-light/`](search-light/README.md) | 入力ソースを US に切替後 search-light オーバーレイをトリガーするスクリプト |

## 関連するスクリプト側の GNOME 拡張機能

入力ソース切替の GNOME 拡張機能本体は `scripts/` 以下にある。

| 拡張機能 | 場所 | 役割 |
|---|---|---|
| `fep-switcher@local` | `scripts/fep-switcher/` | D-Bus 経由で入力ソース切替を提供するコア |
| `app-switch-us-input@local` | `scripts/app-switch-us-input/` | ターミナルフォーカス時に US へ自動切替 |
