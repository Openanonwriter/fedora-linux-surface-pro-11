# NPU

- On Snapdragon X the NPU is the compute DSP. It is running, and `/dev/fastrpc-cdsp` exists.
- Nothing on Linux uses it: there is no standard interface for it, only Qualcomm's QNN SDK, which is proprietary and each app must be built for.
- It has been done on this hardware under Ubuntu (llama.cpp through QNN, see the denisix/ubuntu-surface-pro-11 guide).
- Not attempted here.
