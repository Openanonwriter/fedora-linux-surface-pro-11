# CPU cores and frequency fix

## Symptom

CPUs 8 to 10 (and 4 to 6) showed 0 MHz. Only `policy0` existed, so only CPUs 0 to 3 had frequency scaling.

## Two separate problems

### 1. Two cores that do not exist

The device tree listed 12 cores; the chip has 10. Boot log:

```
psci: failed to boot CPU7 (-22)
psci: failed to boot CPU11 (-22)
```

Fix: remove `cpu7`, `cpu11`, their idle power domains and their `cpu-map` entries (Dale Whinham's `x1p64100.dtsi`). Cores then number 0 to 9. The firmware's own CPU table marks the same two as disabled, and four other reported units match.

This alone did **not** bring back frequency scaling.

### 2. A firmware quirk in the frequency tables (the real cause)

- For performance domains 1 and 2 the firmware reports a "sustained" frequency of 0.
- The SCMI code marks every frequency above the sustained one as turbo, so all 13 steps (710.4 MHz to 3417.6 MHz) became boost frequencies.
- With boost off, the cpufreq core finds no usable frequency, returns `-EINVAL`, and drops the policy **without logging anything**.

Found with kernel return probes on `cpufreq_frequency_table_cpuinfo`.

Fix: in `scmi-cpufreq`, if a table consists only of boost entries, clear the boost flag (Friedrich Schrödter's commit). Log line when it applies:

```
cpu cpu4: all OPPs flagged as turbo by firmware, using them as regular OPPs
```

## Result

`policy0` (CPUs 0 to 3), `policy4` (4 to 6), `policy7` (7 to 9), each 710 MHz to 3.42 GHz, governor `schedutil`.

## Limits on this machine

- The fix runs as an out-of-tree module in `/lib/modules/<version>/updates/scmi-cpufreq.ko`, also inside the initramfs.
- It only fits kernel `7.3.5-300.sp11.1`. A new kernel loads the stock driver.
- With Secure Boot on, an unsigned module will not load. The lasting fix is the kernel pull request (Pull requests).

Root cause as described by Dale Whinham: the chip's power firmware picks as "sustained" the first table entry rated for the cluster's core count, and reports 0 when none matches a 3-core cluster. Windows is unaffected because it uses a different interface.
