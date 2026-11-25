# Sensors

The sensors hang off the audio and sensor DSP (Qualcomm "Sensor Core"). The chain is:

`DSP firmware` → `hexagonrpcd` (serves files to the DSP) → `libssc` → `iio-sensor-proxy` → desktop

## Reading them

```bash
timeout 8 ssccli --sensor light --timeout 5      # also accelerometer gyroscope magnetometer compass
sudo /usr/libexec/sp11/sp11-sensors-check          # the project's full report
```

## Facts learned

- Light sensor chip: TCS3430. It reads 0 in a dark room; that is normal. Under a phone flashlight it reads several hundred to about 1,300 lux.
- Once it was stuck at 0 for a whole boot and fine after a reboot.
- The DSP reads its configuration and registry **once per start**. Changes need a reboot.
- Editing the registry copy under `/var/lib/sp11/hexagonrpc/sensors/persist` did not survive a boot; the DSP rewrites it.
- The framework needs its registry folder to exist. With an empty folder it rebuilds the registry from the configuration ([Generic sensor configuration test](../firmware/generic-sensor-configuration-test.md)).
- The compute DSP asserts once per boot (`sleep_statsi.c:537`) and recovers. Same with Microsoft's and Dell's firmware.
- `ssccli` cannot read the pressure sensor or the hinge angle.

## Files

- Configuration: `/usr/share/qcom/x1e80100/Microsoft/denali-lcd/sensors/config`
- Working copy served to the DSP: `/var/lib/sp11/hexagonrpc`
- This unit's factory calibration: see [Per-unit data](../firmware/per-unit-data.md)
