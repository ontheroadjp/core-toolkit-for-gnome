# core-t480s-settings

Lenovo ThinkPad T480s 固有のハードウェア設定を適用するスクリプト。
`thinkpad_acpi` カーネルモジュールが提供する sysfs インターフェイスに依存するため、
**ThinkPad 以外の機種では動作しない**。

## 設定内容

| 設定項目 | 値 | 備考 |
|---|---|---|
| バッテリー充電開始閾値 | 70% | TLP の `START_CHARGE_THRESH_BAT0` |
| バッテリー充電停止閾値 | 85% | TLP の `STOP_CHARGE_THRESH_BAT0` |

TLP と `/etc/tlp.conf` が必要。スクリプトは他の設定を保持しながら閾値を更新し、
TLP サービスを有効化して設定を適用する。再起動後も TLP が閾値を適用する。

## 使い方

```bash
# sudo 必須（TLP の設定とサービス操作に必要）
./scripts/core-t480s-settings/apply-settings.sh
sudo tlp-stat -b
```
