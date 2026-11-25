# Surface Pro 11: make an installation onto a USB drive bootable.
#
# The firmware starts a USB drive through \EFI\BOOT\BOOTAA64.EFI (shim). Fedora puts only shim and its
# fallback loader there; GRUB is in \EFI\fedora. The fallback loader registers a boot entry and resets the
# machine, and the firmware then starts the internal drive, which is first in its boot order, so the USB
# installation never starts. With GRUB beside shim, shim starts it directly.
#
# Only for an EFI system partition on a USB drive: an internal installation is started through its own boot
# entry and is left exactly as Fedora installs it.
%post
esp=/boot/efi/EFI
src=$(findmnt -n -o SOURCE /boot/efi 2>/dev/null) || exit 0
disk=$(lsblk -n -d -o PKNAME "$src" 2>/dev/null | head -n1)
[ -n "$disk" ] || exit 0
[ "$(lsblk -n -d -o TRAN "/dev/$disk" 2>/dev/null | tr -d ' ')" = usb ] || exit 0
[ -f "$esp/BOOT/BOOTAA64.EFI" ] && [ -f "$esp/fedora/grubaa64.efi" ] && [ -f "$esp/fedora/grub.cfg" ] || exit 0
for f in grubaa64.efi grub.cfg mmaa64.efi; do
  [ -e "$esp/BOOT/$f" ] || [ ! -f "$esp/fedora/$f" ] || cp "$esp/fedora/$f" "$esp/BOOT/$f"
done
%end
