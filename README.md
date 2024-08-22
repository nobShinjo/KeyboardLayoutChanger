# KeyboardLayoutChanger README

[日本語 README](README_JP.md)

## Overview

KeyboardLayoutChanger is a PowerShell script that automatically generates registry files to switch between US and JIS keyboard layouts on a per-keyboard basis on Windows machines.

## Release Notes

[CHANGELOG](CHANGELOG.md)

## Features

- Removes common override settings for keyboard layouts.
- Changes the common keyboard layout setting to PCAT_101KEY.

    ```reg
    [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters]
    "OverrideKeyboardIdentifier"="PCAT_101KEY"
    "OverrideKeyboardSubtype"=-
    "OverrideKeyboardType"=-
    ```

- Adds override settings for JIS or US layouts to the HID/Device Parameters of connected keyboards.
  Modifies the registry under HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\HID\.

  - JIS Layout

    ```reg
    "KeyboardSubtypeOverride"=dword:00000002
    "KeyboardTypeOverride"=dword:00000007
    ```

  - US Layout

    ```reg
    "KeyboardSubtypeOverride"=dword:00000000
    "KeyboardTypeOverride"=dword:00000007
    ```

## Usage

To use the KeyboardLayoutChanger.ps1 script, follow these steps:

1. Open the PowerShell console.
1. Navigate to the directory where the script is located.
1. Run the following command to execute the script.

    ```powershell
    PS> .\KeyboardLayoutChanger.ps1
    ```

1. Disconnect the keyboard you want to change the layout for (unplug the USB cable or dongle, or turn off the keyboard).

1. Follow the on-screen instructions and enter `Y` when you are ready to proceed.

    ```powershell
    Are you ready to proceed? (Y/N):: Y
    ```

1. The currently connected keyboards will be displayed in a list.

    ```powershell
    Getting initial list of connected keyboards...
    Currently connected keyboards:
    - HID Keyboard Device: (HID\******\******)
    - HID Keyboard Device: (HID\******\******)
    - HID Keyboard Device: (HID\******\******)
    ```

1. Enter the desired keyboard layout for the existing keyboards.

    ```powershell
    Enter the desired keyboard layout for existing keyboards (JIS/US):: JIS
    ```

1. Connect the new keyboard for which you want to set the layout. The waiting time for connection is 60 seconds. If it times out, the process will terminate abnormally.

    ```powershell
    Checking for new keyboard connections...
    New keyboard detected with the following HIDs:
    - HID Keyboard Device: (HID\{********-****-****-****-***********}_*********\*********)
    - HID Keyboard Device: (HID\{********-****-****-****-***********}_*********\*********)
    ```

1. Follow the on-screen instructions and enter the desired keyboard layout for the newly connected keyboard.

    ```powershell
     Enter the desired keyboard layout (JIS/US):: US
    ```

1. A registry file `keyboard_layout_change.reg` will be generated to change the keyboard layout for the target keyboard.

    ```powershell
    Registry modification code has been saved to [CurrentPath]\keyboard_layout_change.reg
    ```

1. Verify the output of the registry file and double-click `keyboard_layout_change.reg` to apply the changes.
1. Restart your PC.
1. Confirm that the keyboard layout has been correctly changed.

### Example Output

```powershell
PS> .\KeyboardLayoutChanger.ps1
Please, disconnect all keyboards except the one with the default layout.
Are you ready to proceed? (Y/N):: Y
Getting initial list of connected keyboards...
Currently connected keyboards:
- HID Keyboard Device: (HID\******\******)
- HID Keyboard Device: (HID\******\******)
- HID Keyboard Device: (HID\******\******)
- Standard PS/2 Keyboard: (ACPI\******\******)
Enter the desired keyboard layout for existing keyboards (JIS/US):: JIS
Checking for new keyboard connections...
New keyboard detected with the following HIDs:
- HID Keyboard Device: (HID\{********-****-****-****-***********}_*********\*********)
- HID Keyboard Device: (HID\{********-****-****-****-***********}_*********\*********)
Enter the desired keyboard layout (JIS/US):: US
Registry modification code has been saved to [CurrentPath]\keyboard_layout_change.reg
```

## Requirements

The KeyboardLayoutChanger.ps1 script has the following requirements:

- Windows operating system
- PowerShell version 3.0 or later

## License

This script is licensed under the MIT License. For more details, see the [LICENSE](LICENSE) file.
