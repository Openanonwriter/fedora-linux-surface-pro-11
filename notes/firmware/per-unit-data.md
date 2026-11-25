# Per-unit data

Things that exist only on each Surface and are not in the [Microsoft driver package](microsoft-driver-package.md).

| Item | What it is | Without it |
|---|---|---|
| `factory_color_calibration.bin` | light and colour sensor factory calibration | the generic "golden" calibration is used |
| `sns_surface_calibration_accel.json`, `_gyro.json` | accelerometer and gyroscope bias | defaults with zero bias; this unit's accelerometer bias is about 0.12 m/s² |
| `tdm_uid.bin`, `acs_multiplier.bin`, `dev_runtime_mod.bin` | a unit ID and two small values | the framework carries on without them |
| Bluetooth address | the unit's Bluetooth identity | derived from the firmware, see [Bluetooth address without Windows](bluetooth-address-without-windows.md) |

> [!WARNING] This unit's only copy
> Windows is no longer installed here. This unit's files are saved in `~/sp11-firmware-ms/per-unit-backup/` (132 KB, with a README). Copy that folder somewhere safe. Do not publish it; it identifies the unit.

## Not from Microsoft at all

Audio topology and UCM profiles (community project), Wi-Fi board data (Fedora's firmware, patched), touch and pen settings, and the sensor registry, which the DSP rebuilds itself.

Tested: [Generic sensor configuration test](generic-sensor-configuration-test.md).
