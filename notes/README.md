# Notes: Fedora on a Surface Pro 11 LCD, and building without Windows

These are working notes from one Surface Pro 11 LCD (X1P64100, SKU `Surface_Pro_11th_Edition_2076`) running
Fedora 45. They record what was found and tested, including what did not work. They are not part of the
project's documentation under `docs/`, and nothing here has been reviewed by the project's maintainer.

> [!WARNING]
> This branch is work in progress.
> - The no-Windows build (`SP11_REDISTRIBUTABLE=1`, `payload/sp11-firmware-fetch`) was built and tested on an
>   earlier base. On this base (current `main` plus the LCD support of PR #4) it has not been built or booted yet.
> - Everything was tested on one LCD unit with Secure Boot off. OLED and 5G models are untested.
> - The installer step for installs onto a USB drive (`payload/80-sp11-removable-boot.ks`) is untested.
> - The battery reading from the embedded controller (`payload/sp11-ec-battery.conf`, and a kernel commit that is
>   not in the project's kernel) is untested with the DSP offline.

Start with [the report](report-no-windows.md): it is the short version of the whole no-Windows result.

Addresses, IDs and user paths in the logs and scripts are redacted. No Microsoft firmware and no per-unit
calibration is in this repository.

## Contents

### Firmware: what comes from where

- [What works without the audio/sensor DSP firmware](firmware/without-the-audio-sensor-dsp.md)
- [ADSP swap test](firmware/adsp-swap-test.md)
- [Bluetooth address without Windows](firmware/bluetooth-address-without-windows.md)
- [Firmware fetch tool](firmware/firmware-fetch-tool.md)
- [Firmware sources](firmware/firmware-sources.md)
- [Generic sensor configuration test](firmware/generic-sensor-configuration-test.md)
- [Microsoft driver package](firmware/microsoft-driver-package.md)
- [Per-unit data](firmware/per-unit-data.md)
- [Surface Pro 11 on Linux without Windows: what comes from where](firmware/running-without-windows.md)

### The ISO and the build

- [Building without Windows](iso/building-without-windows.md)
- [Drivers without Microsoft firmware](iso/drivers-without-microsoft-firmware.md)
- [ISO plan](iso/iso-plan.md)
- [Kernel build](iso/kernel-build.md)
- [Redistributable mode](iso/redistributable-mode.md)
- [USB boot test](iso/usb-boot-test.md)
- [Why the firmware cannot be shipped or rebuilt](iso/why-the-firmware-cannot-be-shipped-or-rebuilt.md)

### Hardware findings

- [Bluetooth and BLE](hardware/bluetooth-and-ble.md)
- [Cameras](hardware/cameras.md)
- [Hardware status](hardware/hardware-status.md)
- [Light sensor investigation](hardware/light-sensor-investigation.md)
- [NPU](hardware/npu.md)
- [Pen and touch](hardware/pen-and-touch.md)
- [Sensors](hardware/sensors.md)
- [Sleep and battery](hardware/sleep-and-battery.md)
- [The device](hardware/the-device.md)
- [Thermals](hardware/thermals.md)
- [Wi-Fi](hardware/wi-fi.md)

### Fixes applied on the test unit

- [Backlight fix](fixes/backlight-fix.md)
- [Camera gain and tuning](fixes/camera-gain-and-tuning.md)
- [CPU cores and frequency fix](fixes/cpu-cores-and-frequency-fix.md)
- [Kernel-update hook](fixes/kernel-update-hook.md)
- [Sleep log hook](fixes/sleep-log-hook.md)
- [Thermal guard](fixes/thermal-guard.md)
- [Video codec fix](fixes/video-codec-fix.md)

### Test results (raw)

- [Live USB boot, before and after the firmware step](results/live-usb-test-result.txt)
- [Boot with another maker's audio/sensor DSP firmware (refused)](results/adsp-swap-test-result.txt)

### Scripts

These ran on the test unit. They are kept as they were used, with user paths replaced by `$HOME`; read them
before running them anywhere else.

| Script | What it does |
|---|---|
| [`live-usb-test.sh`](scripts/live-usb-test.sh) | The live-session test: records what works, runs the firmware fetch tool, starts the DSP, records again. Starting the DSP in a live session drops the USB stick; see the report. |
| [`run50.sh`](scripts/run50.sh) | Reruns the ISO step in redistributable mode as a background unit. |
| [`fw-swap.sh`](scripts/fw-swap.sh) | Switches the four Qualcomm-signed firmware images between Fedora's copies and the unit's own, and rebuilds the initramfs. |
| [`cdsp-swap.sh`](scripts/cdsp-swap.sh) | The same for the compute DSP pair only. |
| [`sp11-thermal-cap`](scripts/sp11-thermal-cap), [`sp11-thermal-guard`](scripts/sp11-thermal-guard) | Hold the CPU temperature under a limit during long builds by lowering the maximum CPU frequency. |
| [`sp11-sleep-log`](scripts/sp11-sleep-log) | systemd sleep hook that logs how long the machine slept, the energy used and the wake source. |
| [`sp11-camera-gain`](scripts/sp11-camera-gain), [`90-sp11-camera-gain.rules`](scripts/90-sp11-camera-gain.rules), `imx681.yaml`, `ov13858.yaml` | Camera sensor gain at device add, and libcamera tuning files for the two cameras. |

## Credits

The build system, kernel patch set and sensor stack are FadyAckad's project. LCD support is disbenovi's
(PR #4). The backlight and CPU topology commits are Dale Whinham's and the cpufreq fix is Friedrich Schrödter's.
The work in these notes was done with Claude Code.
