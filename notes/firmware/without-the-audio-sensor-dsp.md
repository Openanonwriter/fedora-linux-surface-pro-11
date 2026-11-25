# What works without the audio/sensor DSP firmware

The audio/sensor DSP (ADSP) is the one part that needs a file from Microsoft. This note records what depends on
it, what does not, and one function, the battery reading, that can be moved off it. Checked on one X1P64100 LCD
unit on 2026-11-24.

> [!WARNING]
> The battery change described here is **untested** where it matters: it has not been run with the DSP offline,
> and not as the only battery of a desktop session. The kernel commit is not in the project's kernel.

## No other DSP image will load

Every `qcadsp8380.mbn` carries two certificate chains: Qualcomm's, the same in all of them, and the maker's own.

| Image | Second chain |
|---|---|
| Microsoft (Surface) | Microsoft, "ECC Surface Monzino Platform Attestation" |
| Dell XPS 13 9345 | Dell, "DCPD-CBI-SRO" |
| Lenovo ThinkPad T14s (21N1) | Lenovo, "Qualcomm Secure Boot Attestation" |
| Generic `qcom/x1e80100/adsp.mbn` | Qualcomm SecTools **test** root (development boards) |

The compute DSP images that do load on the Surface (Microsoft's and Dell's) carry only a Qualcomm chain. A boot
with Dell's audio/sensor DSP pair was refused ([ADSP swap test](adsp-swap-test.md)).

## What depends on it

| Function | Without the DSP firmware |
|---|---|
| Speakers, microphones | none: they run through the DSP's audio stack, and there is no bypass driver for this chip |
| Accelerometer, gyroscope, light sensor (rotation, auto-brightness) | none: the sensors are on the DSP's own bus |
| Battery level and charging state (`qcom_battmgr`) | none, unless the embedded controller is used (below) |
| USB-C role and DisplayPort alternate mode (`pmic_glink`) | not checked in detail; a USB stick and a USB install worked |
| Bluetooth and USB audio | work |
| Charger connected (`ADP1`) | works: it already comes from the embedded controller |
| Fan speed, temperatures, power profiles | work: embedded controller |
| Keyboard, touchpad, pen stash, tablet-mode switch | work: embedded controller |
| Display, GPU, video codec, Wi-Fi, touch | work |

The embedded controller also lists a sensor device (`01:15:01:06:00`), but it returns an empty HID descriptor and
`surface_hid` fails to probe with `-71`. So it offers no way to rotation.

## The battery can come from the embedded controller

- The Surface Aggregator registry lists a battery for this model (`01:02:01:01:00`).
- The project's kernel keeps `surface_battery` from binding on `microsoft,denali` (patch 0048), because
  `qcom_battmgr` reports the battery and two batteries would show.
- Test: `surface_battery` built out of tree with that check made optional and loaded while the DSP was running.
  `BAT1` appeared next to `qcom-battmgr-bat`:

| | `BAT1` (embedded controller) | `qcom-battmgr-bat` (DSP) |
|---|---|---|
| Charge | 56 % | 57 % |
| Full / design capacity | 45.05 / 46.53 Wh | 45.05 / 46.53 Wh |
| Voltage | 8.123 V | 8.123 V |
| Status | Charging | Charging |
| Cycle count | 89 | 0 (not reported) |

One line in the kernel log at load: `surface_serial_hub: event: unhandled event (… tc: 0x02 … cid: 0x53 …)`.

## What is in git, untested

- **Kernel:** `power: supply: surface_battery: Add denali_bind to bind on the Surface Pro 11`, one commit on top
  of the project's `sp11/7.3.5`, in the branch
  [`sp11/7.3.5-ec-battery`](https://github.com/Openanonwriter/linux-sp11/tree/sp11/7.3.5-ec-battery). A module
  parameter, off by default; nothing changes for a system that does not set it. It passes `checkpatch` and
  compiles against the 7.3.5 revision 1 headers.
- **Build, redistributable mode only:** the support RPM ships `/usr/lib/modprobe.d/sp11-ec-battery.conf`
  (`options surface_battery denali_bind=1`). `sp11-firmware-fetch` masks it with an empty file of the same name
  under `/etc/modprobe.d` once the DSP firmware is installed, so that one battery shows after the restart.
- This branch still builds the project's kernel, which does not have the parameter. There the option is ignored,
  with one "unknown parameter" line in the kernel log.

## Open

- Does `BAT1` read correctly with the DSP offline?
- Without its firmware `qcom_battmgr` still registers a battery whose values cannot be read. Whether the desktop
  then shows one battery or two is not known.
- Charge thresholds and anything else that is written to the battery were not tried through the embedded
  controller.
