# USB boot test

The first test of the ISO on real hardware. Status: **booted on 2026-11-24; mostly passed, two problems. See Result.**

## What is on the stick

- Image: `~/src/pr4/build/out/Fedora-Workstation-Live-45-1.4-SP11-7.3.5-300.sp11.4.fc45.aarch64.iso`, 2.6 GB, sha256 `d0d3aca6de9b…` (full value in the `.sha256` file next to it).
- Built on this Surface under Fedora on 2026-11-24 at 12:32, in [Redistributable mode](redistributable-mode.md).
- Checked before writing: no Microsoft files in the image; four firmware images from Fedora's package; the LCD device tree with backlight, video codec and 10 CPUs; kernel revision 4 with the frequency fix ([Kernel build](kernel-build.md)).
- Stick: 57.8 GB "USB DISK 3.0". Written with `dd` and verified by reading it back. Writing erased the stick.

## How to boot it

1. Plug in the charger.
2. Shut the Surface down completely.
3. Hold **volume down**, press and release **power**, keep holding volume down until the Surface logo appears.
4. Choose the first menu entry. It boots with text messages, not a logo.

Secure Boot must be off (it is on this unit).

## Expected before the firmware step

- Works: display, brightness slider, touch, keyboard cover, Wi-Fi, GPU.
- Does not work yet: sound, battery reading, auto-rotate. The audio and sensor DSP firmware is absent by design ([Why the firmware cannot be shipped or rebuilt](why-the-firmware-cannot-be-shipped-or-rebuilt.md)).

## The test

Connect to Wi-Fi first; the [Firmware fetch tool](../firmware/firmware-fetch-tool.md) installs two small helper programs. Then, in a terminal:

```bash
sudo mount -o subvol=home /dev/nvme0n1p3 /mnt && sudo bash /mnt/<user>/sp11-iso-test/run-test.sh
```

The script (`~/sp11-iso-test/run-test.sh`):

1. Records what works before the firmware step.
2. Runs the fetch tool with the Microsoft package already saved on the internal drive, so there is no 617 MB download.
3. Starts the audio and sensor DSP and records again.
4. Saves `result-<date>.txt` into `~/sp11-iso-test/` on the internal drive.

It writes nothing else to the internal drive.

> [!WARNING]
> Do not click "Install to Hard Drive" in the live session. This is a test only.

## What a pass looks like

| When | Expected |
|---|---|
| Before | 10 CPUs with frequency scaling, a backlight device, GPU render node with no zap shader errors, the video codec device, Wi-Fi connected |
| After | DSP running, battery percentage, at least one sound card, sensor files installed, accelerometer and light readings, Bluetooth address taken from the firmware variable ([Bluetooth address without Windows](../firmware/bluetooth-address-without-windows.md)) |

## Result (2026-11-24)

File: `~/sp11-iso-test/result-20261125-020408.txt` (the live session's clock was in UTC).

| Check | Before the firmware step | After |
|---|---|---|
| Boots, model detected as LCD, kernel revision 4 | yes | |
| 10 CPUs, frequency scaling | yes | yes |
| Backlight device | yes | yes |
| GPU, no zap shader errors | yes | yes |
| Video encoder and decoder | yes | yes |
| Wi-Fi | connected | connected |
| Bluetooth address from the firmware variable | set at boot | file written |
| Audio and sensor DSP | offline, as designed | running |
| Battery reading | none, as designed | 27 % |
| Sensors | none, as designed | accelerometer and light read; registry rebuilt (303 entries) |
| Sound card | none, as designed | **still none** |

The fetch tool finished without error. It installed its helper program itself, took the two DSP files from Microsoft's package and installed 74 sensor files.

Problems:

- **No sound card after the step.**
- **The live image threw read errors** (`erofs … read error -5`, `I/O error, dev loop0`) after the DSP was started.
- Cause: starting the DSP brings up the USB-C port handling, which reset the port the stick was in, so the running system lost its disk. Confirmed by what was seen: the desktop behaved as if the stick had been pulled out, and Firefox would not start. The stick was plugged straight into the Surface.
- The missing sound card may follow from that, or may need the reboot the tool asks for. Not yet known.
- Starting the DSP by hand is something only the test script does, not the fetch tool.

What it means for the design: do not start that DSP inside a live session. The firmware step belongs after installing, when the DSP loads its firmware at boot.

Change made: the [Firmware fetch tool](../firmware/firmware-fetch-tool.md) now refuses to run in a live session unless given `--allow-live`. The image on the stick still has the old tool.

Still to prove: sound after install, firmware step and restart, using the ISO's own packages. That needs a real install, onto a second USB drive or the internal disk.

## Coming back

Restart without holding volume down; the normal Fedora boots. If the stick does not boot, hold power for 10 seconds, start normally, and note how far it got.

## After a good result

See the remaining work in [ISO plan](iso-plan.md) and Status and next steps.

## Install test onto a USB drive (2026-11-24, evening)

The ISO was installed onto a second USB drive (28.7 GB SanDisk), leaving the internal drive untouched.

- **First attempt failed.** The drive got warm and the Surface restarted into the internal system. Cause: the firmware starts a USB drive through the generic `EFI/BOOT` folder, where Fedora puts only its first-stage loader and a fallback helper. The helper restarts the machine, and the firmware then boots the internal drive.
- **Fix by hand:** copied GRUB and its config from `EFI/fedora` into `EFI/BOOT` on the SanDisk. It then booted.
- **Firmware step:** ran the [Firmware fetch tool](../firmware/firmware-fetch-tool.md) with the saved Microsoft package, then restarted.
- **Result, confirmed from that system's own log:** audio and sensor DSP running, speakers playing, sensors handed to the desktop (rotation works), Bluetooth address set, sensor registry rebuilt. Bluetooth itself was not tried.
- The errors in its log are the same ones the internal system shows.

This proves the whole chain on the LCD model: ISO, install, firmware step, restart, working system, with no Windows.

Change made to the build (local branch, not yet rebuilt or tested): the support package now gives the installer a post-install step that does the `EFI/BOOT` copy when the target is a USB drive. Internal installs are left as Fedora makes them.

