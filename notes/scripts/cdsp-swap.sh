#!/usr/bin/bash
# Test the compute DSP (CDSP) with Dell XPS 13 9345 firmware from Fedora's qcom-firmware instead of Microsoft's.
# Both are signed by Qualcomm only (generic Hamoa CDSP). Reboot after each action.
#   sudo ./cdsp-swap.sh dell     back up Microsoft's pair, install Dell's pair
#   sudo ./cdsp-swap.sh revert   restore Microsoft's pair
set -eu
D=/usr/lib/firmware/qcom/x1e80100/microsoft/Denali
V=/usr/lib/firmware/qcom/x1e80100/dell/xps13-9345
B=$HOME/sp11-firmware-ms
case "${1:-}" in
  dell)
    [ -f "$B/qccdsp8380.mbn" ] || cp -p "$D/qccdsp8380.mbn" "$B/"
    [ -f "$B/cdsp_dtb.mbn" ]   || cp -p "$D/cdsp_dtb.mbn" "$B/"
    xzcat "$V/qccdsp8380.mbn.xz" > "$D/qccdsp8380.mbn"
    xzcat "$V/cdsp_dtbs.elf.xz"  > "$D/cdsp_dtb.mbn"
    restorecon "$D/qccdsp8380.mbn" "$D/cdsp_dtb.mbn" 2>/dev/null || true
    echo "Dell CDSP pair installed; reboot to test" ;;
  revert)
    install -m 0644 "$B/qccdsp8380.mbn" "$D/qccdsp8380.mbn"
    install -m 0644 "$B/cdsp_dtb.mbn"   "$D/cdsp_dtb.mbn"
    restorecon "$D/qccdsp8380.mbn" "$D/cdsp_dtb.mbn" 2>/dev/null || true
    echo "Microsoft CDSP pair restored; reboot" ;;
  *) echo "usage: $0 dell|revert" >&2; exit 1 ;;
esac
sha256sum "$D/qccdsp8380.mbn" "$D/cdsp_dtb.mbn"
# The DSPs boot from the initramfs copy of the firmware, so it must be rebuilt too.
dracut -f --kver "$(uname -r)"
lsinitrd "/boot/initramfs-$(uname -r).img" | grep -E 'Denali/(qccdsp8380|cdsp_dtb)' | awk '{print "initramfs:", $5, $NF}'
