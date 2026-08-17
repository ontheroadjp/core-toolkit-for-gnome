# diagnostics

このディレクトリには、`applications/` や `scripts/` にある単一コンポーネントに閉じない、
複数コンポーネントを横断する調査・診断用ツールを置く。通常のインストール対象ではなく、
特定の issue の原因調査のために手動実行する。

## サブディレクトリ

| ディレクトリ | 対象 |
|---|---|
| `key-input-management/` | keyd・ibus・GNOME Shell 拡張（`scripts/fep-switcher/` 等）・D-Bus など、キー入力/FEP切替まわりを横断する診断ツール |
