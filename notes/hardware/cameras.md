# Cameras

| Camera | Sensor | Device tree node | Notes |
|---|---|---|---|
| Front | imx681 | `camera@1a` | works; dim and noisy indoors |
| Rear | ov13858 | `camera@10` | works after digital gain |
| IR | vd55g0 | `camera@60` | monochrome, works with an explicit format |

All three go through libcamera's software image processing and are offered to apps by PipeWire.

## Why they were dark

libcamera's software processing only drives exposure time and analogue gain. Indoors both reach their limits and the picture is still dark. It never uses the sensors' digital gain. Fix: [Camera gain and tuning](../fixes/camera-gain-and-tuning.md).

## IR camera

- Ask for `GRAY8` at 640x600 explicitly. Without that the negotiated frame is a useless strip.
- The IR illuminator is the LED `ir:flash`. It can be switched without root:

```bash
busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto   org.freedesktop.login1.Session SetBrightness ssu leds ir:flash 255
```

- Face login (Howdy) was discussed and not set up. It changes login and sudo authentication and is weaker than Windows Hello.

## Capturing with GStreamer

Use the PipeWire node **name**, not its number:

```bash
gst-launch-1.0 pipewiresrc target-object=libcamera_input._base_soc_0_cci_ac15000_i2c-bus_1_camera_10 ! videoconvert ! autovideosink
```

Front camera name ends `cci_ac16000_i2c-bus_1_camera_1a`; IR ends `cci_ac15000_i2c-bus_0_camera_60`.
