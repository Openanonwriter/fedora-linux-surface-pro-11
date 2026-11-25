# Drivers without Microsoft firmware

Question raised: could Linux drivers be built so the Microsoft-signed audio and sensor DSP firmware is not needed?

A replacement firmware cannot be built ([Why the firmware cannot be shipped or rebuilt](why-the-firmware-cannot-be-shipped-or-rebuilt.md)). What could be done is move some jobs off that DSP.

| Function | Without the DSP firmware? |
|---|---|
| Battery level, charger status | Plausible. The Surface's embedded controller also reports them, and the drivers `surface_battery` and `surface_charger` are on the system; the SP11 kernel deliberately stops them binding in favour of the DSP path. |
| Sensors | Uncertain. They are wired to the DSP; Linux could drive them directly only if those lines also reach the main processor. Not checked. |
| Sound | Not realistic. The whole audio path runs through that DSP. |
| USB-C features | Not realistic. Same DSP. |

Decision: not pursued. It would be weeks of kernel work for a partly working system, to avoid a free download.

One piece worth a test later: the embedded-controller battery driver, so a fresh install shows battery status before the firmware is fetched. It needs one boot with one kernel setting changed.
