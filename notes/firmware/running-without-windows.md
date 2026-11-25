# Surface Pro 11 on Linux without Windows: what comes from where

Written 2026-11-24 from tests on one Surface Pro 11 LCD (X1P64100, SKU 2076), Fedora 45, kernel
7.3.5-300.sp11.1. Everything marked "tested" was run on that unit. Things checked on one unit only are
marked as such.

The question: if Windows is gone, where does each file the system needs come from?

## Summary

| What | Source without Windows | Status |
|---|---|---|
| Video codec firmware | Fedora `qcom-firmware` | tested, running |
| GPU security (zap) shader | Fedora `qcom-firmware` | tested, running |
| Compute DSP firmware (2 files) | Fedora `qcom-firmware` | tested, running |
| Audio/sensor DSP firmware (2 files) | Microsoft's public driver download only | another maker's copy is refused |
| Sensor configuration (64 of 71 files) | Microsoft's public driver download | byte-identical to the Windows copies |
| Sensor calibration (per unit) | nowhere; generic defaults exist | defaults untested as a full set |
| Bluetooth address (per unit) | derived from a UEFI variable | works out on this unit; one unit checked |
| Audio profiles, Wi-Fi calibration, touch/pen settings | community projects and Fedora | never came from Windows |
| Sensor registry (351 files) | rebuilt by the DSP from the configuration | per the SP11 project's docs |

## 1. Firmware

The rule that decides it is who signed the file. Files signed only by Qualcomm are generic and work across
Snapdragon X laptops. Files signed by the laptop maker are tied to that maker's devices.

| File (as the device tree names it) | Job | Signed by | Replacement in Fedora's `qcom-firmware` |
|---|---|---|---|
| `qcvss8380.mbn` | video encode/decode | Qualcomm | `qcom/x1e80100/LENOVO/21N1/qcvss8380.mbn.xz`, sha256 `71180840fe3c…` |
| `qcdxkmsuc8380.mbn` | GPU zap shader | Qualcomm | `qcom/x1e80100/dell/xps13-9345/qcdxkmsuc8380.mbn.xz`, sha256 `585f674954e1…` |
| `qccdsp8380.mbn` | compute DSP | Qualcomm | `qcom/x1e80100/dell/xps13-9345/qccdsp8380.mbn.xz`, sha256 `3df4de099b23…` |
| `cdsp_dtb.mbn` | compute DSP config | Qualcomm | `qcom/x1e80100/dell/xps13-9345/cdsp_dtbs.elf.xz`, sha256 `664758a227f3…` |
| `qcadsp8380.mbn` | audio/sensor DSP | Microsoft | none |
| `adsp_dtb.mbn` | audio/sensor DSP config | Microsoft | none |

All of them install under `/usr/lib/firmware/qcom/x1e80100/microsoft/Denali/`. The X1P64100 is the X1E80100
(Hamoa) die, so it takes the 8380 files, not the X Plus "purwa" ones (`qcdxkmsucpurwa.mbn`,
`qcvss8380_pa.mbn`).

Tests with the four Fedora files in place:
- GPU accelerated (Adreno X1-85), glmark2 score 2297 at 1080p offscreen.
- H.264 and H.265 hardware encode of 300 1080p frames in under a second each; hardware decode returned
  300 of 300 frames.
- 45 seconds of GPU, video encode and all 10 CPU cores together: peak 65 °C, no GPU faults.
- Accelerometer, gyroscope, magnetometer and compass read normally; audio devices, battery and Wi-Fi fine.
- The compute DSP asserts once per boot (`sleep_statsi.c:537`) and recovers. It does the same with
  Microsoft's file.
- One new log line with Dell's compute DSP config: `qcom_smd_qrtr … IPCRTR … probe failed -121`. No lost
  function found.

The audio/sensor DSP cannot be replaced:
- Booting with Dell's pair, the secure world refused it: `qcom_q6v5_pas: error -22 initializing firmware
  …/adsp_dtb.mbn`, then `Failed to load program segments: -22`. The DSP stayed offline.
- With it offline there is no battery reading, no sound card and no sensors. Display, GPU, Wi-Fi, keyboard,
  touch and the compute DSP still work, so a system can boot and install without it.
- Microsoft's image also contains Surface-only sensor code (`sns_surface_color`, `sns_surface_sar`,
  `sns_surface_manager`) that no other maker's image has.
- Building our own is not possible: the chip only runs DSP images signed with Microsoft's key.

Two practical notes:
- The DSPs and the GPU load their firmware from the copy inside the initramfs. After changing a file, run
  `sudo dracut -f --kver $(uname -r)`, or the old one is still used.
- `fw-swap.sh fedora|microsoft` in this folder switches the four replaceable files and rebuilds the initramfs.

## 2. Microsoft's public driver download

- Download Center id 106119, "Surface Pro 11th Edition with Snapdragon".
- File tested: `SurfacePro11_ARM_Win11_26100_26.094.41119.0.msi`, 617 MB, sha256 `8b299016027a4a87…`.
  The link changes when Microsoft updates the package.
- A copy is in `microsoft-msi/`, with `file-table.tsv` mapping the internal `fil<ID>` names to real names.
- Unpack with `7z x file.msi`; get the name table with `msiinfo export file.msi File`.

It contains, byte-identical to what a Windows install has:
- all six firmware files above (the two DSP config files under their Windows names `adsp_dtbs.elf` and
  `cdsp_dtbs.elf`);
- 64 of the 71 sensor configuration files, including `golden_color_calibration.bin` and default
  accelerometer and gyroscope calibration files with zero bias.

So the only files a user must fetch from Microsoft are the audio/sensor DSP pair and the sensor
configuration. Read the package's licence terms before building a tool around it; fetching it on the user's
own machine is different from redistributing it.

## 3. What exists only on each unit

These are not in the download. On a machine that still has Windows they can be exported; otherwise they are
gone, and the system runs on defaults.

| Item | What it is | Without it |
|---|---|---|
| `factory_color_calibration.bin` | light/colour sensor factory calibration | generic golden calibration from the download |
| `sns_surface_calibration_accel.json`, `_gyro.json` | accelerometer and gyroscope bias | defaults with zero bias; this unit's accelerometer bias is about 0.12 m/s² |
| `tdm_uid.bin`, `acs_multiplier.bin`, `dev_runtime_mod.bin` | unit ID and two small sensor values | untested; this unit's multiplier is 1.0 |
| Bluetooth address | the unit's Bluetooth identity | see section 4 |

This unit's own copies are in `per-unit-backup/`. Windows is no longer installed here, so that folder is the
only copy. Keep it, and do not publish it.

## 4. Bluetooth address without Windows

- The Bluetooth controller has no usable address of its own. The SP11 setup sets one at every boot from
  `/etc/sp11/bluetooth-address`.
- The address is not stored verbatim in the UEFI variables, SMBIOS or the device tree.
- The UEFI variable `MacAddressEmulationAddress-b7f95555-4ea5-4786-b088-78ba350a1b56` holds a 6-byte address
  (after 4 attribute bytes) with the same Microsoft prefix. It is non-volatile and readable from Linux.
- On this unit, **Bluetooth address = that value minus 1**.

Read it with:

```
sudo xxd /sys/firmware/efi/efivars/MacAddressEmulationAddress-b7f95555-4ea5-4786-b088-78ba350a1b56
```

Proposed first-boot logic for an installer:
1. Read the variable; subtract 1; write the result as the Bluetooth address.
2. If the variable is missing, generate an address once and keep it. Bluetooth works; devices paired under
   Windows need pairing again.

Open point: the "minus 1" relation is confirmed on one unit. It needs checking on other units (OLED, 5G)
before an installer relies on it.

## 5. What this means for a downloadable ISO

1. Ship no proprietary firmware in the ISO. Take the video, GPU and compute DSP files from Fedora's
   `qcom-firmware`, which is redistributable.
2. The ISO boots to a working desktop without Microsoft's files: display, GPU, Wi-Fi, keyboard, touch. No
   sound, battery reading or sensors yet.
3. A first-boot tool downloads Microsoft's package on the user's machine, verifies it, and installs the
   audio/sensor DSP pair and the sensor configuration. Sound, battery, sensors and USB-C then work.
4. Sensor calibration: generic defaults, or an import if Windows is still on the disk.
5. Bluetooth address: from the UEFI variable (section 4), with a generated fallback.

Not yet done: the first-boot tool itself, a test of a system running purely on the generic calibration
files, and confirmation of the Bluetooth relation on other units.

## Files kept locally (not in this repository)

- `RUNNING-WITHOUT-WINDOWS.md`: this document.
- `fw-swap.sh`: switch the four replaceable firmware files between Fedora's and Microsoft's copies.
- `*.mbn`: this unit's six original Microsoft firmware files.
- `adsp-test-result.txt`: log of the boot where Dell's audio/sensor DSP was refused.
- `microsoft-msi/`: Microsoft's driver package and its file table.
- `per-unit-backup/`: this unit's calibration and Bluetooth address. Private.
