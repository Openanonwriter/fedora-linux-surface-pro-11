# Hardware status

State on this LCD unit with all fixes applied.

| Feature | Status | Notes |
|---|---|---|
| Display, GPU acceleration | works | Adreno X1-85, glmark2 2297 at 1080p offscreen |
| Backlight, brightness keys | works | needs the [Backlight fix](../fixes/backlight-fix.md) |
| Auto-brightness | works | reads 0 in a dark room, which is normal |
| CPU, all 10 cores scaling | works | needs the [CPU cores and frequency fix](../fixes/cpu-cores-and-frequency-fix.md) |
| Hardware video encode and decode | works | needs the [Video codec fix](../fixes/video-codec-fix.md) |
| Speakers, microphone | works | |
| Keyboard cover, touchpad, volume keys | works | |
| Touchscreen | present | not hand-tested in detail |
| Pen | works with pressure | appears as a generic pointer, see [Pen and touch](pen-and-touch.md) |
| Rear camera | works | after gain, see [Cameras](cameras.md) |
| Front camera | works, dim and noisy indoors | see [Cameras](cameras.md) |
| IR camera | works | needs an explicit format, see [Cameras](cameras.md) |
| Accelerometer, gyroscope, magnetometer, compass, light | works | see [Sensors](sensors.md) |
| Proximity sensor | not fitted | |
| Wi-Fi | works | 6 GHz, 160 MHz, about 2.2 Gbit/s; slow reconnect after resume, see [Wi-Fi](wi-fi.md) |
| Bluetooth and BLE | controller works | not tested with a device; see [Bluetooth and BLE](bluetooth-and-ble.md) |
| Battery, charging | works | USB-C charging shows on the USB line, see [Sleep and battery](sleep-and-battery.md) |
| Deep sleep and resume | works | about 0.25 W asleep; unexplained wake-ups |
| NPU | not usable yet | see [NPU](npu.md) |
| USB-C display output | not tested | |
| Tablet mode behaviour | switch present, not tested | |
