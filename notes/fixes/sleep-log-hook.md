# Sleep log hook

`/usr/lib/systemd/system-sleep/sp11-sleep-log` (source `~/sp11-backlight/sp11-sleep-log`).

After every sleep it writes one line to the journal: how long it slept, energy used, average power, whether the charger was in, and which interrupt woke the machine.

```bash
journalctl -t sp11-sleep
```

Purpose: find what wakes the Surface every few hours ([Sleep and battery](../hardware/sleep-and-battery.md)).

Remove with `sudo rm /usr/lib/systemd/system-sleep/sp11-sleep-log`.
