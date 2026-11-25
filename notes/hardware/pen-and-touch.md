# Pen and touch

- Touch and pen data are decoded by `iptsd`, which creates virtual input devices.
- The pen works with pressure in apps that use Wayland tablet events.
- GNOME shows it as a generic pointer, with no Wacom settings page.

## Why

`iptsd` creates the pen on `BUS_VIRTUAL`. libwacom 2.19 can only match USB, I2C, Bluetooth or serial devices, so no `.tablet` definition can match it. The bus type is fixed in the `iptsd` binary.

## Fix, not done

Rebuild `sp11-iptsd` to report the pen as USB and add a libwacom `.tablet` file, or report it to the project.
