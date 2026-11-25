# Kernel build

> [!NOTE]
> Written before the kernel fixes were merged. They are now in `FadyAckad/linux-sp11` (`sp11/7.3.5`, revision 4), and this branch uses that pin, not the fork branch named below.

## What is being built

Fedora's kernel 7.3.5-300 source package, plus 121 SP11 patches, as revision 4 (`7.3.5-300.sp11.4.fc45.aarch64`).

- Patches 1 to 117: the upstream project's set.
- Patches 118 to 121: the LCD fixes from the kernel pull request (Pull requests): PWM backlight, fused-off CPUs, SCMI frequency fix, video codec.

In `~/src/pr4` the submodule `linux-sp11` points at `Openanonwriter/linux-sp11`, branch `sp11/7.3.5-lcd`, commit `85da3589`. `KERNEL_SP11_REV=4` and its content checksum are set in `sp11.conf`.

## Running it

It runs as a user service so it survives the terminal closing:

```bash
systemd-run --user --unit=sp11-kernel-build --collect --working-directory=$HOME/src/pr4 \
  /bin/bash -c 'scripts/20-build-kernel.sh > build/step20.log 2>&1; echo "exit=$? finished $(date +%T)" >> build/step20.log'

systemctl --user is-active sp11-kernel-build
tail -f ~/src/pr4/build/step20.log
tail -f ~/src/pr4/build/work/mock-sp11-kernel/build.log
```

Success ends the first log with `exit=0`. The kernel compiles quietly, so there is no percentage.

## Heat

Uncapped it reaches 94 to 95 °C. Run it with the [Thermal guard](../fixes/thermal-guard.md). At a 1.44 GHz cap expect a few hours.

## If it is interrupted

Nothing is lost. Make sure no `mock` process is left, then start it again.
