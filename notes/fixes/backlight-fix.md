# Backlight fix

## Symptom

The brightness slider and keys did nothing. The screen stayed at full brightness.

## Cause

- The LCD device tree had no backlight node, so the kernel registered `dp_aux_backlight`.
- Writes to it are accepted and read back, but the LG panel ignores brightness over DisplayPort AUX.
- The panel is dimmed by a PWM signal from the PMK8550 power chip.

> [!TIP] Trap
> Checking `brightness` and `actual_brightness` in sysfs passes even though the screen does not dim. Look at the screen.

## Fix

A `pwm-backlight` in the device tree. The correct, complete version is Dale Whinham's commit (see People and credits):

- PWM from `pmk8550_pwm` channel 0, period 5 ms, pin `gpio5` of the PMK8550 set to its PWM function;
- its own supply regulator, enabled by `pmc8380_3` gpio 10;
- backlight enable on `pmc8380_3` gpio 4, moved from the panel to the backlight (on the OLED that pin is the panel enable).

The panel then waits for the PWM drivers, so the initramfs needs them:

```
add_drivers+=" leds-qcom-lpg pwm_bl panel-edp "
```

That line is in `/etc/dracut.conf.d/sp11-lcd-backlight.conf`.

## Result

`/sys/class/backlight/backlight`, range 0 to 4095. Slider, keys and auto-brightness all work.

## History

My first version only added the PWM node and relied on the firmware leaving the regulator and pin set up. It worked here but could give a black screen on other firmware. Dale's version sets both up explicitly and is what runs now. Do not combine the two: two drivers would fight over gpio 4.

Installed through the [Kernel-update hook](kernel-update-hook.md).
