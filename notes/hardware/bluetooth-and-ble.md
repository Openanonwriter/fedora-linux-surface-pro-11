# Bluetooth and BLE

## The controller

| | |
|---|---|
| Chip | WCN7850 combo (Wi-Fi and Bluetooth), Bluetooth side on a UART, device tree `qcom,wcn7850-bt` |
| Interface | `hci0` |
| Firmware | `qca/hmtbtfw20.tlv` and `qca/hmtnv20.bin`, from Fedora's firmware packages (not Microsoft) |
| Firmware build | `BTFW.HAMILTON.2.0.1-00349-WOS_PATCHZ-2` |
| Stack | BlueZ 5.88, Bluetooth core version 13 (5.4), manufacturer 29 (Qualcomm) |

Kernel log at boot shows AOSP extensions v0.98, quality reports, and "HFP non-HCI data transport is supported".

## BLE capabilities reported by the controller

- Classic (BR/EDR) and Low Energy are both enabled.
- Roles: central and peripheral.
- Advertising: 16 instances; secondary channels 1M, 2M and Coded (long range).
- LE Audio building blocks are on: `cis-central`, `cis-peripheral`, `iso-broadcaster`, `sync-receiver`.
- LL privacy and periodic advertising sync transfer (`past-sender`, `past-receiver`) are on.
- Wide-band speech and secure connections are on.
- Services registered by default: GAP, GATT, Device Information, A2DP source and sink, AVRCP, Handsfree and Handsfree gateway.

```bash
bluetoothctl show
sudo btmgmt info
```

> [!WARNING] Not tested with a device
> No Bluetooth or BLE device has been paired or connected during this work. The list above is what the controller reports, not a test result. When last checked, Bluetooth was switched off (soft-blocked in `rfkill`, `Powered: no`) and no devices were paired.

## The address

The controller has no usable address of its own. See [Bluetooth address without Windows](../firmware/bluetooth-address-without-windows.md).

- `sp11-bluetooth-address@hci0.service` runs `/usr/libexec/sp11/sp11-bt-apply`, which sets the public address before `bluetooth.service` starts. The log shows `set-public-address status 0x00 (success)`.
- The address comes from `/etc/sp11/bluetooth-address`.

## Pairings shared with Windows

The upstream project can export Windows' pairing keys for the Surface Pro Flex Keyboard and the Slim Pen 2 (both BLE devices) and import them into BlueZ, so they work in both systems without pairing again:

- export, in Windows: `scripts/70-export-bt-pairings.sh`
- import, in Fedora: `sudo /usr/libexec/sp11/sp11-bt-import-pairings`

Not used here: Windows is gone from this machine, so those devices would be paired fresh. With a generated or derived address the same applies to anyone installing without Windows.

## BLE inside the sensor DSP

The sensor configuration has two BLE entries, `qsh_ble.json` (scan modes: low power, balanced, low latency) and `8380_qsh_ble_0.json` (UART instance 6). They describe a BLE scanning service that runs on the sensor DSP, separate from the Linux Bluetooth stack. Nothing on Linux uses it; it was not investigated further.

## After sleep

On resume the log shows `Controller resume with wake event 0x0`; the controller comes back powered.
