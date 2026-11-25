# ADSP swap test

Question: does the Surface accept another maker's audio and sensor DSP firmware?

**No.** Booting once with Dell's pair:

```
qcom_q6v5_pas 6800000.remoteproc: error -22 initializing firmware qcom/x1e80100/microsoft/Denali/adsp_dtb.mbn
remoteproc remoteproc0: Failed to load program segments: -22
```

- The DSP stayed offline.
- With it offline: no battery reading, no sound cards, no sensors.
- Display, GPU, Wi-Fi, keyboard and the compute DSP were unaffected, so a system can boot and install without it.

Log: `~/sp11-firmware-ms/adsp-test-result.txt`.

## How the test was made safe

- The disk and the normal initramfs kept Microsoft's files. Only a separate test initramfs held Dell's.
- A one-time GRUB entry (`grub2-reboot`) with a marker on the kernel command line; a service recorded the result and rebooted to the normal entry.
- Charger unplugged, because that DSP also runs battery charging.

The same pattern was used for the [Generic sensor configuration test](generic-sensor-configuration-test.md).
