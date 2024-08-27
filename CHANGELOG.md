# CHANGELOG

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

---

## [1.0.1] - 2024-08-28

### Fixed

- Corrected the registry key names for ACPI and non-ACPI devices in the `New-RegistryModificationCode` function. (1a4f83c6dccbcd2d6e9bf9607b1676f7ff8d63b2)
  - For ACPI devices, the registry keys are now `"OverrideKeyboardSubtype"` and `"OverrideKeyboardType"`.
  - For non-ACPI devices, the registry keys are now `"KeyboardSubtypeOverride"` and `"KeyboardTypeOverride"`.
- Added registry settings for `i8042prt` parameters to override keyboard layout for US. (1a4f83c6dccbcd2d6e9bf9607b1676f7ff8d63b2)
  - Set `LayerDriver JPN` to `kbd101.dll`.
  - Set `LayerDriver KOR` to `kbd101a.dll`.

---

## [1.0.0] - 2024-08-22

### Added

- Added new keyboard connection detection feature. The script automatically detects newly connected keyboards and notifies the user.
- Added keyboard layout selection feature. Users can choose between JIS or US layout when a new keyboard is detected.
- Added automatic registry modification code generation feature. Based on the selected keyboard layout, the registry modification code is automatically generated and saved as a `.reg` file.
- Added timeout feature. If no new keyboard is detected within a certain period, the script times out and displays an error message.

---

[Unreleased](https://github.com/nobShinjo/KeyboardLayoutChanger/compare/v1.0.0...HEAD)
[1.0.1](https://github.com/nobShinjo/KeyboardLayoutChanger/releases/tag/v1.0.1)
[1.0.0](https://github.com/nobShinjo/KeyboardLayoutChanger/releases/tag/v1.0.0)
