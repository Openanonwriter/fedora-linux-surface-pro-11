# ISO plan

Goal: one downloadable Fedora ISO for every Surface Pro 11, with no proprietary Microsoft files inside.

## Design

| Where | What happens |
|---|---|
| Built once, by us | Kernel, packages and ISO containing only open-source parts and the four firmware files from Fedora's package |
| On each user's Surface, first boot | The [Firmware fetch tool](../firmware/firmware-fetch-tool.md) downloads Microsoft's package, installs the audio and sensor DSP firmware and the sensor configuration, sets the Bluetooth address, then one reboot |

Nobody builds anything on their own device.

## Why not put the firmware in the ISO

The audio and sensor DSP firmware is Microsoft's and may not be redistributed. Reverse engineering cannot replace it: the images are signed and the chip checks the signature ([ADSP swap test](../firmware/adsp-swap-test.md)).

## Gaps and status

| # | Gap | Approach | Status |
|---|---|---|---|
| 1 | Build needed Windows | Native detection, downloads from Fedora and Microsoft | done ([Building without Windows](building-without-windows.md)) |
| 2 | Proprietary firmware in the ISO | Four files from Fedora, two fetched on the device | done ([Redistributable mode](redistributable-mode.md)) |
| 3 | First-boot fetch tool | [Firmware fetch tool](../firmware/firmware-fetch-tool.md) | done, live install untested |
| 4 | Usable before the fetch | Display, GPU, Wi-Fi, keyboard, touch without the audio DSP | seen in a test boot |
| 5 | One device tree per ISO | All device trees on the ISO; GRUB picks by chip and SKU | not written |
| 6 | Sensor calibration per unit | Generic files, import if Windows is present | generic set proven |
| 7 | Bluetooth address per unit | Firmware variable minus 1, generated fallback | one unit confirmed |
| 8 | Secure Boot | Require it off | decided |
| 9 | Kernel with the LCD fixes | Fork branch, pull request upstream | building ([Kernel build](kernel-build.md)) |
| 10 | Models we do not own | OLED and 5G owners must boot it | needs volunteers |
| 11 | Hosting and updates | ISO is about 3 GB; GitHub releases cap files at 2 GB | undecided |

## Notes for gap 5

- GRUB can read the SKU (SMBIOS type 1) and the processor version (type 4) with its `smbios` command.
- `smbios` is a loadable module, not built into Fedora's GRUB, so the ISO must carry `smbios.mod`. GRUB only loads extra modules with Secure Boot off, which matches gap 8.
- The installed system gets its device tree from `SP11_DTB` in `/etc/sp11/sp11.env`; that has to be decided on the device too.
- Use one sensor payload folder for all models instead of `denali-lcd` and `denali-oled`.

## Order of work

1. LCD-only test image from the current build, booted from USB.
2. Model selection and the first-boot prompt.
3. Outside testers, then a release.
