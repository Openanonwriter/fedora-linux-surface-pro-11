# The device

| | |
|---|---|
| Model | Microsoft Surface Pro, 11th Edition, LCD |
| SKU | `Surface_Pro_11th_Edition_2076` (the non-5G OLED shares this SKU) |
| Chip | Snapdragon X Plus X1P64100 |
| Panel | LG, EDID vendor `LGD`, product `0x077b`, 2880x1920 |
| Firmware | UEFI 175.449.235 |
| Battery | 45.96 Wh full, 46.53 Wh design |
| System | Fedora 45, kernel `7.3.5-300.sp11.1.fc45.aarch64`, Secure Boot off |
| Device tree | `qcom/x1p64100-microsoft-denali.dtb`, compatible `microsoft,denali-lcd` |

## The chip is an X Elite with two cores switched off

The X1P64100 is the X1E80100 ("Hamoa") die. It is not the smaller X1P42100 ("Purwa"). That one fact explains several things:

- It has 10 cores in three clusters, 4 + 3 + 3. The fourth core of clusters 1 and 2 does not exist ([CPU cores and frequency fix](../fixes/cpu-cores-and-frequency-fix.md)).
- It takes the X Elite "8380" firmware. The X Plus "purwa" GPU shader is refused by the chip.
- Its video engine uses the OLED model's setup ([Video codec fix](../fixes/video-codec-fix.md)).

## How to tell the models apart

| Model | Chip string | Panel vendor | SKU |
|---|---|---|---|
| LCD | contains `X1P64100` | `LGD` | `..._2076` |
| OLED | contains `X1E80100` | `SDC` | `..._2076` or `..._For_Business_2085` |
| OLED 5G | contains `X1E80100` | `SDC` | `Surface_Pro_with_5G_11th_Edition_2077` |

An LCD 5G model also exists (the Arch project has hardware IDs for it). This kernel has no device tree for it.

On Linux the values come from `/sys/class/dmi/id/`, `dmidecode -s processor-version`, and bytes 8 and 9 of the eDP connector's EDID. See [Building without Windows](../iso/building-without-windows.md).
