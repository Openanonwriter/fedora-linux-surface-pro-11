# Why the firmware cannot be shipped or rebuilt

## Shipping it

The upstream project's README says the image contains firmware and sensor files copied from the builder's own Windows installation and must not be redistributed. A downloadable ISO therefore cannot contain Microsoft's files.

Two legal routes were considered:

- **A "build your own" fork**: each owner builds from their own Windows. Works, but owners must build.
- **An ISO with no firmware plus a step on the device** that fetches it from Microsoft. Chosen. See [ISO plan](iso-plan.md).

Other laptop makers (ASUS, Dell, HP, Lenovo) have put their Snapdragon X firmware into `linux-firmware`, which distributions may ship. Microsoft has not. If it did, the fetch step would go away. Asking for that, through Surface feedback and the `linux-firmware` list, is the permanent fix.

## Reverse engineering it

Not possible as a replacement, for a technical reason:

- The DSP and GPU security images are signed. The chip's secure side checks the signature against keys belonging to Microsoft for this device, and refuses anything else. Seen twice: the X Plus GPU shader (`-22`) and Dell's audio DSP ([ADSP swap test](../firmware/adsp-swap-test.md)).
- Nobody outside Microsoft and Qualcomm can sign a new image, and the key is fused into the hardware.

Where reverse engineering does help is the interfaces: `libssc`, `hexagonrpc` and much of the Snapdragon laptop support came from working out the protocols. That gives the ability to talk to the firmware, not the right to redistribute it.

This is not legal advice. Read the terms of Microsoft's package before publishing a tool that downloads it.
