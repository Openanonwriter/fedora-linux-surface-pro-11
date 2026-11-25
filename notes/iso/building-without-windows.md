# Building without Windows

The upstream build runs inside Windows (WSL) on the Surface and asks Windows for everything. These changes let it run on plain Fedora. Work is on the local branch `windows-free-build` in `~/src/pr4` (not pushed).

## Hardware detection (step 05)

When there is no `powershell.exe`, `scripts/05-detect-hardware.sh` reads:

| Value | Source |
|---|---|
| Product, SKU, family, board, firmware version | `/sys/class/dmi/id/` |
| Chip | `dmidecode -s processor-version`, or the device tree's `compatible` |
| Panel vendor | bytes 8 and 9 of `/sys/class/drm/card*-eDP-*/edid` |
| Bluetooth address | `/etc/sp11/bluetooth-address`, else the firmware variable ([Bluetooth address without Windows](../firmware/bluetooth-address-without-windows.md)) |

Result on this unit: LCD variant, `qcom/x1p64100-microsoft-denali.dtb`.

Detail: sysfs reports the EDID file's size as 0, so test its content, not its size.

## Microsoft's package as a driver store (step 10)

`scripts/msi-driverstore.py` unpacks the [Microsoft driver package](../firmware/microsoft-driver-package.md) into `build/msi-driverstore/Windows/System32/DriverStore/FileRepository/<driver>.inf_msi/`. The folder names match a real Windows driver store (`surfacepro_ext_adsp8380`, `qcnspmcdm_ext_cdsp8380`, `qcdx8380`, `surfacepro_snscfgcrd8380`), so the firmware and sensor steps work unchanged. `scripts/lib.sh` points `WINDOWS_ROOT` there when no Windows is mounted.

This is for per-unit builds and tests. The public ISO uses [Redistributable mode](redistributable-mode.md) instead.

## Sensor step without an exported registry (step 45)

With no Windows there is no registry to export. The package then ships an empty registry folder ([Generic sensor configuration test](../firmware/generic-sensor-configuration-test.md)).

## Steps run so far on Fedora

`00-setup-host`, `05-detect-hardware`, `10-fetch-sources`, `30-build-support-rpm`, `45-build-sensors-rpms`. Running: `20-build-kernel` ([Kernel build](kernel-build.md)).

Not yet run: `25` (Secure Boot, to be skipped), `40` (touch and pen package), `47` (display library), `50` (ISO), and the verification steps `35`, `46`, `48`, which need the ISO's file system.
