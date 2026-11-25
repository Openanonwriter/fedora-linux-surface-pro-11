# Redistributable mode

`SP11_REDISTRIBUTABLE=1` builds packages that carry nothing from Microsoft.

```bash
cd ~/src/pr4
SP11_REDISTRIBUTABLE=1 scripts/10-fetch-sources.sh
SP11_REDISTRIBUTABLE=1 scripts/30-build-support-rpm.sh
SP11_REDISTRIBUTABLE=1 scripts/45-build-sensors-rpms.sh
```

## Support package (`sp11-surface-support`, 2.2 MB)

- The four Qualcomm-signed firmware files, taken from Fedora's `qcom-firmware` and pinned by checksum in `sp11.conf`.
- No audio and sensor DSP firmware.
- No Bluetooth address file (declared as a ghost file); `sp11-bt-apply` falls back to the firmware variable.
- Ships `/usr/libexec/sp11/sp11-firmware-fetch`; requires `msitools` and `7zip`.

Checked: no file in it matches any of the six Microsoft originals.

## Sensor package (`sp11-sensors`, 26 KB)

- Services, scripts and empty payload folders only.
- The tmpfiles config has no lines for `sns_reg_version` and `parsed_file_list.csv`; the DSP writes both itself.

Checked: zero files under the Microsoft payload path.

## Also built

`hexagonrpc`, `libssc`, `iio-sensor-proxy`, compiled in a clean Fedora 45 build root (mock).

## Still open

- The project's verification steps have not run against these packages.
- The packages are still built for one variant (device tree and payload folder). See gap 5 in [ISO plan](iso-plan.md).
- No first-boot prompt yet.
