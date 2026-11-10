# apply-settings.sh

ThinkPad の充電閾値を TLP の設定として永続化し、現在の設定に適用する。

TLP と設定ファイルの存在を確認し、既存の有効な BAT0 充電閾値を除いてから開始 70%、停止 85% を追加する。他の設定は保持する。TLP サービスを有効化してから設定を適用する（`scripts/core-t480s-settings/apply-settings.sh:5-32`）。

実行には sudo と TLP が必要。設定ファイルへの書き込みが途中で失敗するとファイルが不完全になる可能性がある（issue #71）。
