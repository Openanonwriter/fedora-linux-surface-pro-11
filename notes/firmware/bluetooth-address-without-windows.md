# Bluetooth address without Windows

- The Bluetooth controller has no usable address of its own. The SP11 setup sets one at every boot from `/etc/sp11/bluetooth-address`.
- The address is not stored verbatim in the UEFI variables, SMBIOS or the device tree, and it cannot be worked out from the Wi-Fi address.
- The UEFI variable `MacAddressEmulationAddress-b7f95555-4ea5-4786-b088-78ba350a1b56` holds six address bytes (after four attribute bytes) with the same Microsoft prefix.

**On this unit: Bluetooth address = that value minus 1.**

```bash
sudo xxd /sys/firmware/efi/efivars/MacAddressEmulationAddress-b7f95555-4ea5-4786-b088-78ba350a1b56
```

## Where it is used

- [Firmware fetch tool](firmware-fetch-tool.md) writes the address file from it.
- `sp11-bt-apply` (in the build) falls back to it when there is no address file, so Bluetooth can work on a first boot.
- Hardware detection in the build uses it ([Building without Windows](../iso/building-without-windows.md)).

> [!WARNING]
> Confirmed on one unit only. See Open questions for other owners.
