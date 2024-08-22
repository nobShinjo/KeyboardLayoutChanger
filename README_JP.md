# KeyboardLayoutChanger README

## 概要

KeyboardLayoutChangerは、Windowsマシン上でキーボードごとにUS/JIS配列のキーボードレイアウトを変えて利用するためのレジストリファイルを自動生成するPowerShellスクリプトです。

## 変更履歴

[CHANGELOG](CHANGELOG.md)

## 機能

- キーボードレイアウトの共通Override設定を削除します。
- キーボードレイアウトの共通設定をPCAT_101KEYへ変更します。

    ```reg
    [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters]
    "OverrideKeyboardIdentifier"="PCAT_101KEY"
    "OverrideKeyboardSubtype"=-
    "OverrideKeyboardType"=-
    ```

- 接続されたキーボードのHID/Device ParameterへJIS配列、またはUS配列のOverride設定を追加します。
  HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\HID\以下を変更する

  - JIS配列

    ```reg
    "KeyboardSubtypeOverride"=dword:00000002
    "KeyboardTypeOverride"=dword:00000007
    ```

  - US配列

    ```reg
    "KeyboardSubtypeOverride"=dword:00000000
    "KeyboardTypeOverride"=dword:00000007
    ```

## 使用方法

KeyboardLayoutChanger.ps1スクリプトを使用するには、以下の手順に従ってください：

1. PowerShellコンソールを開きます。
1. スクリプトがあるディレクトリに移動します。
1. 次のコマンドを実行してスクリプトを実行します。

    ```powershell
    PS> .\KeyboardLayoutChanger.ps1
    ```

1. キーボードレイアウトを変更したい対象キーボード接続を切断します。(USBケーブルやドングルを抜く。またはキーボード電源をOFFしてください。)

1. 画面の指示に従って、準備が整ったら処理を続行する `Y`を入力してください。

    ```powershell
    Are you ready to proceed? (Y/N):: Y
    ```

1. 現在接続中の既存のキーボードが表示され、リスト表示されます。

    ```powershell
    Getting initial list of connected keyboards...
    Currently connected keyboards:
    - HID キーボード デバイス: (HID\******\******)
    - HID キーボード デバイス: (HID\******\******)
    - HID キーボード デバイス: (HID\******\******)
    ```

1. 現在接続中の既存のキーボードのレイアウトを入力してください。

    ```powershell
    Enter the desired keyboard layout for existing keyboards (JIS/US):: JIS
    ```

1. キーボードレイアウトを設定したいキーボードを新しく接続してください。接続待ち時間は60秒です。タイムアウトしたら異常終了します。

    ```powershell
    Checking for new keyboard connections...
    New keyboard detected with the following HIDs:
    - HID キーボード デバイス: (HID\{********-****-****-****-***********}_*********\*********)
    - HID キーボード デバイス: (HID\{********-****-****-****-***********}_*********\*********)
    ```

    ```powershell
    Checking for new keyboard connections...
    New keyboard detected with the following HIDs:
    - HID キーボード デバイス: (HID\{********-****-****-****-***********}_*********\*********)
    - HID キーボード デバイス: (HID\{********-****-****-****-***********}_*********\*********)
    ```

1. 画面の指示に従って、新しく接続したキーボードの希望するキーボードレイアウトを入力します。

    ```powershell
     Enter the desired keyboard layout (JIS/US):: US
    ```

1. 対象のキーボードのキーボードレイアウトを変更するレジストリファイル　`keyboard_layout_change.reg` が出力されます。

    ```powershell
    Registry modification code has been saved to [CurrentPath]\keyboard_layout_change.reg
    ```

1. レジストリファイルの出力結果を確認し、`keyboard_layout_change.reg` をダブルクリックして、変更を反映してください。
1. PCを再起動してください。
1. キーボード配列が正しく変更されていることを確認してください。

### 出力例

```powershell
PS> .\KeyboardLayoutChanger.ps1
Please, disconnect all keyboards except the one with the default layout.
Are you ready to proceed? (Y/N):: Y
Getting initial list of connected keyboards...
Currently connected keyboards:
- HID キーボード デバイス: (HID\******\******)
- HID キーボード デバイス: (HID\******\******)
- HID キーボード デバイス: (HID\******\******)
- 標準 PS/2 キーボード: (ACPI\******\******)
Enter the desired keyboard layout for existing keyboards (JIS/US):: JIS
Checking for new keyboard connections...
New keyboard detected with the following HIDs:
- HID キーボード デバイス: (HID\{********-****-****-****-***********}_*********\*********)
- HID キーボード デバイス: (HID\{********-****-****-****-***********}_*********\*********)
Enter the desired keyboard layout (JIS/US):: US
Registry modification code has been saved to [CurrentPath]\keyboard_layout_change.reg
```

## 必要条件

KeyboardLayoutChanger.ps1スクリプトには、以下の必要条件があります：

- Windowsオペレーティングシステム
- PowerShellバージョン3.0以降

## ライセンス

このスクリプトはMITライセンスの下でライセンスされています。詳細については、[LICENSE](LICENSE)ファイルを参照してください。
