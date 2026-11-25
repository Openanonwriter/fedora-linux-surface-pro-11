# Video codec fix

## Symptom

No hardware video encode or decode. No `qcom-iris` devices.

## Cause

- The LCD device tree left the video engine (`&iris`) disabled. The OLED tree enables it.
- The firmware `qcvss8380.mbn` was not installed.

## Fix

- Device tree: `&iris` with `status = "okay"` and `firmware-name = "qcom/x1e80100/microsoft/Denali/qcvss8380.mbn"`. Same node as the OLED, because [the chip is the X Elite die](../hardware/the-device.md). This commit is mine (Pull requests).
- Firmware: the 8380 image, not the X Plus `qcvss8380_pa.mbn`. The copy from Fedora's package works ([Firmware sources](../firmware/firmware-sources.md)).

## Result

- `/dev/video0` `qcom-iris-decoder`, `/dev/video1` `qcom-iris-encoder`.
- GStreamer: `v4l2h264enc`, `v4l2h265enc`, and decoders for H.264, H.265, VP9, AV1.
- 1080p30 encodes at about 185 frames per second; about 0.06 s of CPU per 300 frames, against 1.24 s for software.

## Rate control needs a frame rate

A live source such as the camera has no frame rate in its caps, and the encoder then ignores the bitrate: a 720p clip came out at 70 to 94 Mbit/s. Set the rate first:

```bash
... ! videorate ! video/x-raw,framerate=30/1 ! v4l2h264enc extra-controls="controls,video_bitrate=4000000" ! video/x-h264,profile=high ! h264parse ! ...
```

Encoder defaults: 20 Mbit/s variable, GOP 59.

Test clip: `~/Videos/sp11-hw-encode-test.mkv`.

Browsers and OBS mostly do not use this path on Linux yet.
