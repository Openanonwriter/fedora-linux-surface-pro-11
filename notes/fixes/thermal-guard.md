# Thermal guard

`/usr/local/sbin/sp11-thermal-guard` (source `~/sp11-backlight/sp11-thermal-guard`). Background in [Thermals](../hardware/thermals.md).

## What it does

Every 15 seconds:

- logs the hottest sensor, SSD temperature, CPU cap, fan speed, battery power and state, and load;
- lowers the CPU frequency cap one step if the hottest sensor is at 90 °C or more, or the SSD at 70 °C or more;
- raises it one step once the hottest sensor is at 80 °C or less and the SSD at 62 °C or less;
- restores the full range when stopped.

Steps in MHz: 710, 806, 998, 1190, 1440, 1670, 1920, 2188, 2515. `SP11_GUARD_MAX` (kHz) sets the highest step it may use.

## Use

```bash
# normal ceiling 2.5 GHz
sudo systemd-run --unit=sp11-thermal-guard --collect /usr/local/sbin/sp11-thermal-guard ~/src/pr4/build/thermal.log

# cool and quiet, for overnight runs
sudo systemd-run --unit=sp11-thermal-guard --collect --setenv=SP11_GUARD_MAX=1440000 /usr/local/sbin/sp11-thermal-guard ~/src/pr4/build/thermal.log

tail -f ~/src/pr4/build/thermal.log
sudo systemctl stop sp11-thermal-guard
```

## Notes

- It must live outside `/home`: systemd will not start a root service from a home folder under SELinux.
- In the log, a positive wattage is power going into the battery.
