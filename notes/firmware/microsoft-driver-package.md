# Microsoft driver package

Microsoft publishes a driver and firmware package for the Surface Pro 11 that contains everything a Windows install has, except per-unit data.

| | |
|---|---|
| Page | Download Center id 106119, "Surface Pro 11th Edition with Snapdragon" |
| File tested | `SurfacePro11_ARM_Win11_26100_26.094.41119.0.msi` |
| Size | 647,004,160 bytes |
| sha256 | `8b299016027a4a87f50cf168f69ca1fb8dedc9a0612fcd6cff89b9bc64135ec2` |
| Local copy | `~/sp11-firmware-ms/microsoft-msi/` with `file-table.tsv` |

The link changes whenever Microsoft updates the package.

## What is inside

- All six firmware files, byte-identical to the Windows copies. The two DSP config files have their Windows names, `adsp_dtbs.elf` and `cdsp_dtbs.elf`.
- The sensor driver folder (`surfacepro_snscfgcrd8380`), 79 files: the JSON configuration, `json.lst`, `sns_reg_config`, the platform identity files, and `golden_color_calibration.bin`.
- 1,129 files in 217 driver folders in total.

## What is not inside

See [Per-unit data](per-unit-data.md).

## Unpacking

```bash
7z x package.msi                 # files come out named fil<ID>
msiinfo export package.msi File  # maps fil<ID> to real names (package msitools)
```

`~/src/pr4/scripts/msi-driverstore.py PACKAGE DEST` unpacks it into the same folder layout as a Windows driver store.

## Licence

Users downloading it themselves is different from redistributing it. Read the package's terms before publishing a tool built on it.
