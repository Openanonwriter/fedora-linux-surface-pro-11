# Light sensor investigation

What was learned chasing a light sensor that read 0 lux. Summary in [Sensors](sensors.md).

## What happened

1. With auto-brightness on, the sensor reported exactly 0.0 lux, also under a flashlight. Auto-brightness was switched off so it would not fight the slider.
2. `ssccli -v --sensor light` showed the chain was healthy: sensor discovered as `tcs3430` by `amsAG`, continuous stream, 1 Hz.
3. A second flashlight test did give readings, 113 to 1,294 lux, following the beam.
4. I blamed two settings copied from Qualcomm's reference board (`a_auto_gain` off, `raw_dark_threshold` 10) and wrote `~/sp11-als/als-tune.sh` to change them.
5. After a reboot the sensor read about 317 lux in room light and auto-brightness worked. The two values were back at their originals: the DSP had re-parsed its configuration and overwritten the edit.

## Conclusions

- The zero reading was a stuck state in that boot. **A reboot fixed it.** The calibration change did nothing.
- `als-tune.sh` is ineffective; do not use it.
- In a dark room the sensor does read 0 to 4 lux. That is correct.
- If it is stuck at 0 in good light, reboot.

## Details worth keeping

- The registry entries for the sensor are JSON files named like `8380_crd_tcs3430_0.json.tcs3430_0_platform.als.fac_cal`.
- The colour calibration files hold four per-channel scale factors. The generic "golden" file has about 1.7, 2.6, 5.9 and 3.9; this unit's factory file about 15.8, 19.1, 10.4 and 32.2.
- Microsoft's DSP firmware has its own auto-gain code for this chip (`tcs3430_als_auto_gain_surface_version`), which is one reason another maker's firmware cannot replace it ([Firmware sources](../firmware/firmware-sources.md)).
- GNOME setting: `gsettings get org.gnome.settings-daemon.plugins.power ambient-enabled`.
