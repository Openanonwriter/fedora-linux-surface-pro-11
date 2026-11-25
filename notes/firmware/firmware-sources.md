# Firmware sources

Six files load from `/usr/lib/firmware/qcom/x1e80100/microsoft/Denali/`. Who signed a file decides whether another laptop's copy can replace it.

| File | Job | Signed by | Source on this unit now |
|---|---|---|---|
| `qcvss8380.mbn` | video codec | Qualcomm | Fedora `qcom-firmware`: `LENOVO/21N1/qcvss8380.mbn.xz` |
| `qcdxkmsuc8380.mbn` | GPU security shader | Qualcomm | Fedora: `dell/xps13-9345/qcdxkmsuc8380.mbn.xz` |
| `qccdsp8380.mbn` | compute DSP | Qualcomm | Fedora: `dell/xps13-9345/qccdsp8380.mbn.xz` |
| `cdsp_dtb.mbn` | compute DSP config | Qualcomm | Fedora: `dell/xps13-9345/cdsp_dtbs.elf.xz` |
| `qcadsp8380.mbn` | audio and sensor DSP | Microsoft | Microsoft only |
| `adsp_dtb.mbn` | audio and sensor DSP config | Microsoft | Microsoft only |

Checksums (sha256, first 12 characters): video `71180840fe3c`, shader `585f674954e1`, compute DSP `3df4de099b23`, its config `664758a227f3`.

## Tested with the four Fedora files

- GPU accelerated; glmark2 2297 at 1080p offscreen.
- H.264 and H.265 encode and decode, 300 of 300 frames.
- 45 seconds of GPU, encoder and all cores together: peak 65 °C, no GPU faults.
- All sensors, audio, battery and Wi-Fi fine.
- One new harmless log line: `qcom_smd_qrtr ... IPCRTR ... probe failed -121`.

## The audio and sensor DSP cannot be replaced

See [ADSP swap test](adsp-swap-test.md). It is signed by Microsoft, the chip checks that, and Microsoft's image contains Surface-only code (`sns_surface_color`, `sns_surface_sar`, `sns_surface_manager`). Nobody outside Microsoft can sign a replacement.

## Practical notes

> [!WARNING]
> The DSPs and the GPU load firmware from the copy **inside the initramfs**. After changing a file run `sudo dracut -f --kver $(uname -r)`, or the old one is still used.

- Switch the four replaceable files: `sudo ~/sp11-firmware-ms/fw-swap.sh fedora` or `microsoft` (rebuilds the initramfs; reboot after).
- This unit's six original Microsoft files are saved in `~/sp11-firmware-ms/`.
- The X Plus "purwa" files (`qcdxkmsucpurwa.mbn`, `qcvss8380_pa.mbn`) are the wrong ones for this chip.

Related: [Microsoft driver package](microsoft-driver-package.md), [Firmware fetch tool](firmware-fetch-tool.md).
