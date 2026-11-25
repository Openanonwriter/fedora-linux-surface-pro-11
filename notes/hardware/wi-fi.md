# Wi-Fi

- Chip WCN7850 (ath12k). Works on 6 GHz at 160 MHz, about 2.2 Gbit/s.
- **Slow reconnect after resume or radio toggle: about 14.6 seconds.**

## Cause

After the chip wakes, `wpa_supplicant` runs one full scan of every 2.4, 5 and 6 GHz channel, and nothing can connect until it ends. With 6 GHz that takes about 14 seconds.

Tried and reverted, none helped: pinning the band to 6 GHz, pinning channel 69, marking the network hidden, connecting manually at once.

## Likely fix, not done

Switch NetworkManager's backend to `iwd`, which scans known channels first. One package plus a two-line config; undo by deleting the config.
