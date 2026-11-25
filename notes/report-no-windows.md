# Surface Pro 11 (LCD): building, installing and running Fedora with no Windows at any step

**Short version:** I built an ISO on the Surface itself under Fedora, with no Microsoft files in it. It boots, installs, and after one firmware step on the installed system everything I tested works: sound, sensors, battery reading, GPU, video codec, backlight, Wi-Fi. Windows is not installed on this machine and was not used for the build, the install or the firmware.

Tested on one unit: Surface Pro 11 LCD, X1P64100, SKU `Surface_Pro_11th_Edition_2076`, Fedora 45, kernel `7.3.5-300.sp11.4` (the project's patch set plus the four LCD commits in FadyAckad/linux-sp11#1). Secure Boot off. OLED and 5G models are untested.

## Where each file comes from

The only things the build ever needed from Windows were firmware, sensor configuration, per-unit calibration and the Bluetooth address.

| What                                              | Source without Windows                                                                         | Result                                             |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| Video codec `qcvss8380.mbn`                       | Fedora `qcom-firmware`, `LENOVO/21N1`, sha256 `71180840fe3c…`                                  | works                                              |
| GPU zap shader `qcdxkmsuc8380.mbn`                | Fedora `qcom-firmware`, `dell/xps13-9345`, sha256 `585f674954e1…`                              | works                                              |
| Compute DSP `qccdsp8380.mbn`, `cdsp_dtb.mbn`      | Fedora `qcom-firmware`, `dell/xps13-9345`, sha256 `3df4de099b23…`, `664758a227f3…`             | works                                              |
| Audio/sensor DSP `qcadsp8380.mbn`, `adsp_dtb.mbn` | Microsoft's public driver package, fetched on the device                                       | works                                              |
| Sensor configuration (74 files)                   | the same Microsoft package                                                                     | works                                              |
| Sensor registry                                   | rebuilt by the DSP from an empty directory (303 entries)                                       | works                                              |
| Per-unit sensor calibration                       | not available anywhere; the package's generic defaults are used                                | sensors read plausibly; accuracy not measured      |
| Bluetooth address                                 | UEFI variable `MacAddressEmulationAddress-b7f95555-4ea5-4786-b088-78ba350a1b56`, value minus 1 | matches this unit's real address; one unit checked |

Why the split: the first four images are signed by Qualcomm only and are interchangeable between Snapdragon X machines. The audio/sensor DSP pair is signed by Microsoft. I booted with Dell's pair to check, and the secure world refused it (`qcom_q6v5_pas: error -22 initializing firmware …/adsp_dtb.mbn`). So that pair has to be Microsoft's, but it does not have to come from a Windows install.

Microsoft's package: Download Center id 106119, `SurfacePro11_ARM_Win11_26100_26.094.41119.0.msi`, sha256 `8b299016027a4a87f50cf168f69ca1fb8dedc9a0612fcd6cff89b9bc64135ec2`. It unpacks on Linux with `msiinfo` (msitools) and `7z`. The firmware in it is byte-identical to what a Windows install has. The ISO does not contain it; the user's own machine fetches it.

## What I built

- Changes to the build so it runs on Fedora: hardware detection from DMI, the device tree and the panel's EDID instead of a Windows export, and the MSI as an alternative to a mounted Windows DriveStore.
- A "redistributable" mode: the support and sensor packages carry no Microsoft content and no per-unit data.
- `sp11-firmware-fetch`: verifies the package's checksum, installs the two DSP files and the sensor configuration, sets the Bluetooth address from the UEFI variable and rebuilds the initramfs.
- The ISO: 2.6 GB, built on the Surface under Fedora. I checked the image for all six firmware names, the sensor files and per-unit files; none of Microsoft's are in it.

## Test 1: live boot from USB

| Check | Result |
|---|---|
| Boots, model detected as LCD | yes |
| 10 CPUs, three cpufreq policies | yes |
| Backlight device (`max_brightness` 4095) | yes |
| GPU render node, no zap shader errors | yes |
| Video encoder and decoder devices | yes |
| Wi-Fi | connected |
| Bluetooth address | set at boot from the UEFI variable |
| Touch, pen, keyboard cover | present |
| Failed systemd units | none |
| Sound, battery reading, sensors | absent, as intended: no audio/sensor DSP firmware yet |

## Test 2: install, firmware step, restart

1. Installed from the live session onto a second USB drive, so the internal drive stayed untouched.
2. Booted the installed system and ran `sp11-firmware-fetch --msi <package>`, using a copy of the package downloaded earlier from Microsoft.
3. Restarted.

After the restart, from that system's own journal:

- audio/sensor DSP and compute DSP both up;
- speakers playing (the WSA884x playback streams start);
- sensors handed to `iio-sensor-proxy`; auto-rotation works;
- Bluetooth address service finished;
- battery reading present;
- all six firmware files in place, registry rebuilt.

The errors logged are the same ones my everyday install logs with firmware exported from Windows (`qcom-apm` command errors, one compute DSP `sleep_statsi.c:537` assert with recovery, `IPCRTR … -121`, `surface_hid … -71`).

## Two problems found on the way

1. **Do not start the audio/sensor DSP in a live session.** My test script started it by hand; the USB port handling came up, the port reset, and the live system lost the stick it was running from. The firmware step belongs on the installed system. The fetch tool now refuses to run in a live session.
2. **An install onto a USB drive did not boot.** The firmware starts a USB drive through `EFI/BOOT/BOOTAA64.EFI` (shim). Fedora puts no GRUB there, so shim ran the fallback loader, which reset the machine, and the firmware then booted the internal drive. Copying `grubaa64.efi` and `grub.cfg` from `EFI/fedora` to `EFI/BOOT` fixed it. I added an installer post-script that does this for USB targets only; that script is not yet tested in a rebuilt ISO.

## Limits of this result

- One unit, LCD model only.
- Bluetooth: the address is set, but I have not paired a device on the installed test system.
- The "minus 1" relation for the Bluetooth address is confirmed on this unit only.
- Sensor calibration is generic. A machine that still has Windows could import its own.
- Test 2 used a saved copy of Microsoft's package; the download itself was not part of that run.
- Secure Boot was off and the signing step was skipped.
- The ISO has only the LCD device tree; choosing between LCD, OLED and 5G at boot is not written yet.
- Whether Microsoft's licence allows more than fetching the package on the user's own machine is not something I have checked.

## What would help

- Someone with an OLED or 5G unit reading the UEFI variable (`sudo xxd /sys/firmware/efi/efivars/MacAddressEmulationAddress-b7f95555-4ea5-4786-b088-78ba350a1b56`) and comparing the last byte with their Bluetooth address.
- A view on whether this should become a build mode in this project. The branch is on my machine and I can push it for review.

## Credits

The build system, kernel patch set and sensor stack are FadyAckad's project. LCD support is disbenovi's (PR #4). The backlight and CPU topology commits are Dale Whinham's and the cpufreq fix is Friedrich Schrödter's. The work described here was done with Claude Code.
