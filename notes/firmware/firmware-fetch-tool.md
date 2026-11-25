# Firmware fetch tool

`sp11-firmware-fetch`, in `~/sp11-firmware-ms/` and `~/src/pr4/payload/`. Python standard library plus `msiinfo` (msitools) and `7z`.

It is the piece that lets an ISO ship with nothing from Microsoft: the user runs it once after installing.

## What it does

1. Finds the current link on Microsoft's page, or takes a local file with `--msi`.
2. Installs the two Microsoft-only firmware files; takes the other four from Fedora's `qcom-firmware` (or all six from Microsoft with `--all-from-microsoft`).
3. Builds the full sensor payload: the JSON files, `json.lst` and `sns_reg.conf` with Windows line endings removed, the six platform identity files, and an empty registry folder.
4. Sets the Bluetooth address from the firmware if none is set ([Bluetooth address without Windows](bluetooth-address-without-windows.md)).
5. On a live system, rebuilds the initramfs and asks for a reboot.

It never overwrites existing sensor files or an existing Bluetooth address unless `--force` is given, so a unit's own calibration is safe.

## Options

`--msi FILE`, `--keep DIR`, `--root DIR`, `--payload-dir DIR`, `--all-from-microsoft`, `--force`, `--no-firmware`, `--no-sensors`, `--no-bluetooth`, `--no-initramfs`, `--print-url`.

The payload folder is chosen from the device tree: `denali-lcd` or `denali-oled` under `/usr/share/qcom/x1e80100/Microsoft/`.

## Verified

Run into a scratch folder against the saved package:

- 72 of 72 comparable sensor files byte-identical to what the project's build installed;
- all six firmware files identical to the running ones;
- the derived Bluetooth address equals the real one;
- a second run changes nothing.

## Not yet tested

- A real download through the tool (only the link and size were checked).
- A live install on `/` with the initramfs rebuild.
