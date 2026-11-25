# Sleep and battery

## Sleep

- Deep sleep (`mem`, "deep") works and resumes cleanly. Wake with the power button.
- Drain asleep: about **0.25 W**. Best measurement: 5.2 hours, 86 % to 83 % (1.38 Wh). A full battery lasts about 7 days asleep.
- Log noise at suspend: `qcom-pcie 1c08000.pcie: Timeout waiting for L2 entry`. Harmless so far.

## Unexplained wake-ups

- Overnight the Surface woke by itself at 02:36 and 07:38, each about 4 h 48 min after going to sleep, and stayed awake about 15 minutes until GNOME's idle timer suspended it again.
- Not an RTC alarm, not a systemd timer with `WakeSystem`.
- The kernel only remembers the latest wake source, so the cause is unknown. The [Sleep log hook](../fixes/sleep-log-hook.md) records it for every sleep from now on.
- First night with the hook (2026-11-24): slept 4.90 hours, woke at 04:48, and **no wake interrupt was recorded** (the kernel's `pm_wakeup_irq` was empty). The same pattern of about 4 h 50 min. The later wake by the power button was recorded correctly as `gpio_keys`. So the wake does not come through a normal interrupt; cause still unknown.

```bash
journalctl -t sp11-sleep
```

## Charging

- A USB-C charger shows as `qcom-battmgr-usb` `online=1` and battery status `Charging`. `qcom-battmgr-ac` stays 0, so do not use it to decide whether the charger is in.
- `power_now` positive means power going into the battery.
- During the kernel build it charged at about +9 W at a 1.44 GHz cap and about +4.8 W at 2.5 GHz. Battery temperature was 32 °C.

## Charging stops and will not restart above 50 %

Seen 2026-11-24: charger connected, battery at 77 %, status `Not charging`, 0 W.

- Cause: `charge_control_start_threshold` was 50 and `charge_control_end_threshold` 100. With those values charging only starts, or restarts, when the battery is below 50 %.
- The night before it charged from 18 % to about 80 %, was interrupted at a suspend and resume, and never restarted because 80 % is above 50 %. Two days earlier it had reached 100 % only because it had first dropped to 49 %.
- Changing the end threshold did nothing. Raising the **start** threshold above the current level restarted charging within 20 seconds:

```bash
echo 95 | sudo tee /sys/class/power_supply/qcom-battmgr-bat/charge_control_start_threshold
```

- Not persistent across reboots yet.
- GNOME's "preserve battery health" switch (UPower, limits 80 and 75) was off and is a separate thing.

## Suspend blocked by a USB device, battery ran flat

Seen 2026-11-24. The battery went from 25.5 Wh at 12:34 to empty; the machine died at 17:13.

- From 13:07 every suspend attempt was aborted, 72 in all. The [Sleep log hook](../fixes/sleep-log-hook.md) shows each as `slept 0.00 h`.
- Kernel message each time: `xhci-hcd xhci-hcd.1.auto: PM: dpm_run_callback(): platform_pm_suspend returns -22`, then `Some devices failed to suspend`.
- So the Surface stayed awake with the lid closed until the battery was empty.
- USB devices were attached at the time: a hub with two devices, and the USB stick went in around then.
- Suspected: one of those devices on that USB-C port. Not verified which.
- To find out: suspend with only the stick, with only the hub, and with nothing attached.
- Until then: unplug USB devices before closing the lid, or shut down.
- After the flat battery both charge thresholds read 0, and it charged normally at 36 W.

## Battery reading depends on the audio and sensor DSP

Without that DSP's firmware there is no battery reading at all ([ADSP swap test](../firmware/adsp-swap-test.md)).
