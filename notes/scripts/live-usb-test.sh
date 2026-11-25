#!/usr/bin/bash
# Run INSIDE the live session booted from the SP11 test USB stick:
#   sudo mount -o subvol=home /dev/nvme0n1p3 /mnt && sudo bash /mnt/<user>/sp11-iso-test/run-test.sh
# Records what works before the firmware step, runs sp11-firmware-fetch from the saved Microsoft package,
# starts the audio/sensor DSP, records again. Results go to the internal drive (this folder). Changes nothing
# on the internal drive except writing result files here.
H=$(cd "$(dirname "$0")" && pwd); OUT="$H/result-$(date +%Y%m%d-%H%M%S).txt"; MSI=$(ls "$H"/../sp11-firmware-ms/microsoft-msi/*.msi 2>/dev/null | head -1)
[ "$(id -u)" = 0 ] || { echo "run with sudo"; exit 1; }
snap() {
  echo "######## $1  $(date +%T)"
  echo "cmdline: $(cat /proc/cmdline)"
  echo "kernel: $(uname -r)   model: $(tr -d '\0' </proc/device-tree/model)"
  echo "live root: $(findmnt -n -o SOURCE,FSTYPE / | tr '\n' ' ')"
  echo "cpus online: $(cat /sys/devices/system/cpu/online)  cpufreq: $(ls /sys/devices/system/cpu/cpufreq | tr '\n' ' ')"
  echo "backlight: $(ls /sys/class/backlight | tr '\n' ' ') max=$(cat /sys/class/backlight/*/max_brightness 2>/dev/null | tr '\n' ' ')"
  for r in /sys/class/remoteproc/*; do echo "remoteproc $(cat $r/name): $(cat $r/state)"; done
  echo "firmware dir: $(ls /usr/lib/firmware/qcom/x1e80100/microsoft/Denali | tr '\n' ' ')"
  echo "gpu: $(journalctl -k -b --no-pager -o cat | grep -ciE 'zap|hw init failed') zap/hw-init lines; render node: $(ls /dev/dri | tr '\n' ' ')"
  echo "video: $(cat /sys/class/video4linux/*/name 2>/dev/null | grep -i iris | tr '\n' ' ')"
  echo "wifi: $(nmcli -t -f DEVICE,STATE dev 2>/dev/null | head -2 | tr '\n' ' ')"
  echo "bluetooth: $(bluetoothctl show 2>/dev/null | grep -E 'Controller|Powered' | sed -E 's/([0-9A-F]{2}:){3}/xx:xx:xx:/' | tr '\n' ' ')  file: $(ls /etc/sp11/)"
  echo "battery: $(cat /sys/class/power_supply/qcom-battmgr-bat/capacity 2>&1)"
  echo "sound cards: $(grep -c '^ *[0-9]' /proc/asound/cards)"
  echo "sensor payload files: $(find /usr/share/qcom -type f 2>/dev/null | wc -l)  registry entries: $(ls /var/lib/sp11/hexagonrpc/sensors/persist/registry 2>/dev/null | wc -l)"
  echo "sensors:"; for s in accelerometer light; do echo "  $s: $(timeout 9 ssccli --sensor $s --timeout 5 2>&1 | grep -E 'measurement|Unable' | tail -1)"; done
  echo "input: $(grep -E '^N: Name' /proc/bus/input/devices | grep -ciE 'touch|pen|keyboard') touch/pen/keyboard devices"
  echo "failed units: $(systemctl --failed --no-legend | awk '{print $2}' | tr '\n' ' ')"
  echo "kernel errors:"; journalctl -k -b -p err --no-pager -o cat | sort | uniq -c | sort -rn | head -12
}
{
  snap "BEFORE firmware step"
  echo "######## running sp11-firmware-fetch (package: ${MSI:-download})"
  if [ -n "$MSI" ]; then /usr/libexec/sp11/sp11-firmware-fetch --msi "$MSI" --no-initramfs; else /usr/libexec/sp11/sp11-firmware-fetch --no-initramfs; fi
  echo "fetch exit: $?"
  A=$(grep -l '^adsp$' /sys/class/remoteproc/*/name | head -1); A=${A%/name}
  if [ "$(cat $A/state)" = offline ]; then echo "starting the audio/sensor DSP"; echo start > $A/state; fi
  sleep 25
  systemctl restart hexagonrpcd-adsp-sensorspd.service 2>&1; sleep 20
  snap "AFTER firmware step"
  echo "######## hexagonrpcd"; journalctl -b -u hexagonrpcd-adsp-sensorspd -o cat --no-pager | grep -E 'Could not|Refus' | sort | uniq -c | head
  echo "######## dmesg remoteproc"; journalctl -k -b --no-pager -o cat | grep -E 'remoteproc|q6v5|pas' | tail -15
} 2>&1 | tee "$OUT"
sync; echo; echo "Saved to $OUT"
