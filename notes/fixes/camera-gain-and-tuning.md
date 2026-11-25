# Camera gain and tuning

Background in [Cameras](../hardware/cameras.md).

## 1. Sensor digital gain (system-wide)

A udev rule sets a fixed 4x digital gain on both cameras at boot.

- Rule: `/etc/udev/rules.d/90-sp11-camera-gain.rules`
- Helper: `/usr/local/sbin/sp11-camera-gain`
- Values: ov13858 `4096` (1024 is 1x), imx681 `1024` (256 is 1x)
- Source and installer: `~/sp11-camera/` (`install.sh`, `install.sh uninstall`)

Effect on the rear camera: average brightness from 11 to 78 out of 255.

## 2. libcamera tuning files (per user)

- `~/.config/libcamera/ipa/simple/imx681.yaml` and `ov13858.yaml`: a colour matrix used as a brightness boost (1.5 front, about 1.25 rear).
- Loaded through `~/.config/systemd/user/wireplumber.service.d/libcamera-tuning.conf`, which sets `LIBCAMERA_IPA_CONFIG_PATH`.
- Tuning is only read when wireplumber starts: `systemctl --user restart wireplumber`.

> [!WARNING]
> Do not set a fixed `blackLevel: 4096` for the imx681. It crushed the shadows.

## Still weak

The front camera stays dim and noisy indoors. libcamera has no sensor helper for the imx681; a proper fix needs a change in libcamera.
