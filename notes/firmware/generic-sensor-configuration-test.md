# Generic sensor configuration test

Question: do the sensors work with only what the [Firmware fetch tool](firmware-fetch-tool.md) supplies, and nothing from this unit's Windows?

## Test 1: empty folder, no registry directory

No sensors at all. The framework reported `Could not open /persist/sensors/registry/registry/`.

## Test 2: the same, with an empty registry directory

**Works.**

- The DSP rebuilt 303 registry entries itself, plus `parsed_file_list.csv` and `sns_reg_version`.
- It looked for the factory colour calibration, the unit ID and the two small values, did not find them, and carried on with the golden calibration. No crash.
- Accelerometer, gyroscope, magnetometer, compass and light sensor all read. The desktop showed orientation and light level.

## Caveats

- The compass heading differed (74° against about 210° normally): its learned calibration starts from scratch.
- This shows the sensors work on generic values, not how accurate they are.

## Conclusion for the ISO

A user without Windows needs the configuration from Microsoft's package plus an empty registry folder owned by the `fastrpc` user.

A copy of the rebuilt registry is in `~/sp11-firmware-ms/generic-registry-as-rebuilt/`.
