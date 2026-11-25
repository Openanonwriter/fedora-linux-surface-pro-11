# Kernel-update hook

`/etc/kernel/install.d/21-sp11-lcd-backlight.install`

## What it does

When kernel `7.3.5-300.sp11.1.fc45.aarch64` is (re)installed, it puts back the tested files of the submitted series:

- device tree → `/boot/dtb-<version>/qcom/x1p64100-microsoft-denali.dtb` (the pristine copy is kept beside it as `.orig`);
- frequency module → `/lib/modules/<version>/updates/scmi-cpufreq.ko`, then `depmod`.

The files it installs live in `/usr/local/share/sp11-lcd-series/`.

Any other kernel version is left alone: a kernel built after the fixes are merged carries them itself.

## Why a hook

The SP11 support package rewrites `GRUB_DEVICETREE` on every kernel install, so pointing GRUB at a different file does not last. Replacing the file in place does.

## Obsolete

- `/usr/local/sbin/sp11-lcd-backlight-dtb` (my binary device-tree patcher) is no longer used by the hook.
- `~/sp11-backlight/install.sh` and `~/sp11-video/install.sh` would put the old patch back. Do not run them.

## Recovery

At the GRUB menu press `e` and add `.orig` to the end of the `devicetree` line. See Undo and recovery.
