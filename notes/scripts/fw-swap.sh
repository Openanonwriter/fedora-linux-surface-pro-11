#!/usr/bin/bash
# Surface Pro 11: choose where the Qualcomm-signed Denali firmware comes from. Reboot after.
#   sudo ./fw-swap.sh fedora      video, GPU zap shader and CDSP pair from Fedora's qcom-firmware
#   sudo ./fw-swap.sh microsoft   all six files back to the Microsoft copies saved in this folder
# The ADSP pair (qcadsp8380.mbn, adsp_dtb.mbn) is Microsoft-signed and always stays Microsoft's.
set -eu
D=/usr/lib/firmware/qcom/x1e80100/microsoft/Denali; Q=/usr/lib/firmware/qcom/x1e80100; B=$HOME/sp11-firmware-ms
case "${1:-}" in
  fedora)
    xzcat $Q/LENOVO/21N1/qcvss8380.mbn.xz        > $D/qcvss8380.mbn
    xzcat $Q/dell/xps13-9345/qcdxkmsuc8380.mbn.xz > $D/qcdxkmsuc8380.mbn
    xzcat $Q/dell/xps13-9345/qccdsp8380.mbn.xz    > $D/qccdsp8380.mbn
    xzcat $Q/dell/xps13-9345/cdsp_dtbs.elf.xz     > $D/cdsp_dtb.mbn
    echo "71180840fe3cd25226a638e9b42ce8c525d0fc1e0d9a7eadda07ee11048f3d64  $D/qcvss8380.mbn
585f674954e134472a7983b618e2f9a266930e3eadc61b081ddb857f6893010e  $D/qcdxkmsuc8380.mbn" | sha256sum -c - ;;
  microsoft)
    for f in qcvss8380.mbn qcdxkmsuc8380.mbn qccdsp8380.mbn cdsp_dtb.mbn qcadsp8380.mbn adsp_dtb.mbn; do install -m 0644 $B/$f $D/$f; done ;;
  *) echo "usage: $0 fedora|microsoft" >&2; exit 1 ;;
esac
chmod 0644 $D/*.mbn; restorecon $D/*.mbn 2>/dev/null || true
dracut -f --kver "$(uname -r)"      # the DSPs and the GPU load their firmware from the initramfs copy
echo "done ($1); reboot to apply"
