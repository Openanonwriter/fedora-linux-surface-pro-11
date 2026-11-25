# Thermals

Found during the first kernel build on the device, 2026-11-23.

## What happens at full load

- 10 threads at 3.4 GHz draw about 18 W.
- CPU sensors reach 94 to 95 °C within about two minutes. The fan runs at about 5,300 rpm and the controller pushes it to about 7,900 rpm.
- The device tree has **no passive trip point for the CPU sensors**. The only CPU trip is critical, at 115 °C. Cooling devices exist (`cpufreq-cpu0`, `cpufreq-cpu4`, `cpufreq-cpu7`) but nothing uses them below critical.

> [!WARNING]
> Without a cap, a long build sits in the mid 90s. This is worth a device-tree fix upstream: passive trips at about 90 to 95 °C.

## Measured with a speed cap

| CPU cap | Hottest sensor | SSD | Notes |
|---|---|---|---|
| none (3.4 GHz) | 94 to 95 °C | 58 °C | fan 5,300 to 7,900 rpm |
| 2.5 GHz | 71 to 76 °C | 51 to 56 °C | fan pinned near 7,900 rpm; hot to hold |
| 1.44 GHz | about 58 to 60 °C | 49 to 50 °C | fan drops to about 6,100 rpm |

SSD warning level is 82 °C, critical 84 °C.

## Fan

- Linux cannot set the fan speed. The `surface_fan` driver only reports `fan1_input`; the embedded controller decides.
- The one lever is the platform profile:

```bash
cat /sys/class/platform-profile/platform-profile-0/choices
echo performance | sudo tee /sys/class/platform-profile/platform-profile-0/profile
echo balanced | sudo tee /sys/class/platform-profile/platform-profile-0/profile
```

- About 7,900 rpm is the highest speed seen. Raw commands to the embedded controller were deliberately not tried.

## Other observations

- With one core loaded, each cluster reaches the full 3.42 GHz.
- In an earlier 45 second test with all cores, the GPU and the video encoder loaded, all clusters sat at 2.19 GHz. Nothing in Linux was capping them, so that was the chip's firmware.

## Tools

- [Thermal guard](../fixes/thermal-guard.md)
