# MTKClient
Just some mtk tool for exploitation, reading/writing flash and doing crazy stuff. 

Once the mtk script is running, boot into brom mode by powering off device, press and hold either
vol up + power or vol down + power and connect the phone. Once detected by the tool,
release the buttons.

## MT678x, MT689x, MT688x, MT698x
- These chipsets use a new protocol called V6 and the bootrom is patched, thus you need a valid da via --loader option. 
- On some devices, preloader is deactivated, but you still use it by running "adb reboot edl".
- This only works with UNFUSED devices currently.
- For all devices with DAA, SLA and Remote-Auth activated no public solution currently exists (for various reasons).

## Credits
- kamakiri [xyzz]
- linecode exploit [chimera]
- Chaosmaster
- Geert-Jan Kreileman (GUI, design & fixes)
- All contributors



## Installation

pkg install wget -y && wget https://raw.githubusercontent.com/Skorpion96/termux-mtkclient/refs/heads/main/install.sh && chmod +x install.sh && ./install.sh

## Usage

if you want life easier for most common stuff run the menu typing mtkclient, else go ahead, cd to ~/.termux-mtkclient folder first in case, then:

### Run multiple commands
```bash
python mtk.py script run.example
```
See the file "[run.example](https://github.com/RohitVerma882/termux-mtkclient/blob/main/examples/run.example)" on how to structure the script file

### Root the phone (Tested with android 9 - 12)

1. Dump boot and vbmeta (you can do this from the root menu)
```
python mtk.py r boot,vbmeta boot.img,vbmeta.img
```

2. Reboot the phone
```
python mtk.py reset
```

3. Download patched magisk for mtk:
Download latest Magisk [here]([https://raw.githubusercontent.com/vvb2060/magisk_files/44ca9ed38c29e22fa276698f6c03bc1168df2c10/app-release.ap](https://github.com/topjohnwu/Magisk/releases)k)

4. Install on target phone
- you need to enable usb-debugging via Settings/About phone/Version, Tap 7x on build number
- Go to Settings/Additional settings/Developer options, enable "OEM unlock" and "USB Debugging"
- Install magisk apk
```
adb install app-release.apk
```
- accept auth rsa request on mobile screen of course to allow adb connection

5. Upload boot to /sdcard/Download
```
adb push boot.img /sdcard/Download
```

6. Start magisk, tap on Install, select boot.img from /sdcard/Download, then:
```
adb pull /sdcard/Download/[displayed magisk patched boot filename here]
mv [displayed magisk patched boot filename here] boot.patched
```

7. Do the steps needed in section "Unlock bootloader below"

8. Flash magisk-patched boot and empty vbmeta (you can do this from the root menu)
```
python mtk.py w boot,vbmeta boot.patched,vbmeta.img.empty
```

9. Reboot the phone
```
python mtk.py reset
```

10. Disconnect usb cable and enjoy your rooted phone :)


### Boot to meta mode via payload

Example:

```
python mtk.py payload --metamode FASTBOOT
```

### Read efuses

Example:

```
python mtk.py da efuse
```

### Unlock bootloader

1. Erase metadata and userdata (and md_udc if existing):
```
python mtk.py e metadata,userdata,md_udc
```

2. Unlock bootloader:
```
python mtk.py da seccfg unlock (you can do this from the root menu)
```
for relocking use:
```
python mtk.py da seccfg lock (you can do this from the root menu), etcetera, no more need to add this
```

3. Reboot the phone:
```
python mtk.py reset
```

and disconnect usb cable to let the phone reboot.

If you are getting a dm-verity error on Android 11, just press the power button,
then the device should boot and show a yellow warning about unlocked bootloader and
then the device should boot within 5 seconds.


### Read flash

Dump boot partition to filename boot.bin via preloader

```
python mtk.py r boot boot.bin
```

Dump boot partition to filename boot.bin via bootrom

```
python mtk.py r boot boot.bin [--preloader=Loader/Preloader/your_device_preloader.bin]
```


Dump preloader partition to filename preloader.bin via bootrom

```
python mtk.py r preloader preloader.bin --parttype=boot1 [--preloader=Loader/Preloader/your_device_preloader.bin]
```

Read full flash to filename flash.bin (use --preloader for brom)

```
python mtk.py rf flash.bin
```

Read full flash to filename flash.bin (use --preloader for brom) for IoT devices (MT6261/MT2301):

```
python mtk.py rf flash.bin --iot
```

Read flash offset 0x128000 with length 0x200000 to filename flash.bin (use --preloader for brom)

```
python mtk.py ro 0x128000 0x200000 flash.bin
```

Dump all partitions to directory "out". (use --preloader for brom)

```
python mtk.py rl out
```

Show gpt (use --preloader for brom)

```
python mtk.py printgpt
```

### Write flash
(use --preloader for brom)

Write filename boot.bin to boot partition

```
python mtk.py w boot boot.bin
```

Write filename flash.bin as full flash (currently only works in da mode)

```
python mtk.py wf flash.bin
```

Write all files in directory "out" to the flash partitions

```
python mtk.py wl out
```

write file flash.bin to flash offset 0x128000 with length 0x200000 (use --preloader for brom)

```
python mtk.py wo 0x128000 0x200000 flash.bin
```

### Erase flash

Erase boot partition
```
python mtk.py e boot
```

Erase boot sectors
```
python mtk.py es boot [sector count]
```

### DA commands:

Peek memory
```
python mtk.py da peek [addr in hex] [length in hex] [optional: -filename filename.bin for reading to file]
```

Poke memory
```
python mtk.py da poke [addr in hex] [data as hexstring or -filename for reading from file]
```

Read rpmb (Only xflash for now)
```
python mtk.py da rpmb r [will read to rpmb.bin]
```

Write rpmb [Currently broken, xflash only]
```
python mtk.py da rpmb w filename
```

Generate and display rpmb1-3 key
```
python mtk.py da generatekeys
```

Unlock / Lock bootloader
```
python mtk.py da seccfg [lock or unlock]
```

---------------------------------------------------------------------------------------------------------------

### Bypass SLA, DAA and SBC (using generic_patcher_payload)
`` 
python mtk.py payload
`` 
If you want to use SP Flash tool afterwards, make sure you select "UART" in the settings, not "USB".

### Dump preloader
- Device has to be in bootrom mode and preloader has to be intact on the device
```
python mtk.py dumppreloader [--ptype=["amonet","kamakiri","kamakiri2","hashimoto"]] [--filename=preloader.bin]
```

### Dump brom
- Device has to be in bootrom mode, or da mode has to be crashed to enter damode
- if no option is given, either kamakiri or da will be used (da for insecure targets)
- if "kamakiri" is used as an option, kamakiri is enforced
- Valid options are : "kamakiri" (via usb_ctrl_handler attack), "amonet" (via gcpu)
  and "hashimoto" (via cqdma)

```
python mtk.py dumpbrom --ptype=["amonet","kamakiri","hashimoto"] [--filename=brom.bin]
```

For to dump unknown bootroms, use brute option :
```
python mtk.py brute
```
If it's successful, please add an issue over here and append the bootrom in order to add full support.

---------------------------------------------------------------------------------------------------------------

### Crash da in order to enter brom

```
python mtk.py crash [--vid=vid] [--pid=pid] [--interface=interface]
```

### Read memory using patched preloader
- Boot in Brom or crash to Brom
```
python mtk.py peek [addr] [length] --preloader=patched_preloader.bin
```

### Run custom payload

```
python mtk.py payload --payload=payload.bin [--var1=var1] [--wdt=wdt] [--uartaddr=addr] [--da_addr=addr] [--brom_addr=addr]
```

---------------------------------------------------------------------------------------------------------------
## Stage2 usage
### Run python mtk stage (brom) or mtk plstage (preloader)

#### Run stage2 in bootrom
`` 
python mtk.py stage
`` 

#### Run stage2 in preloader
`` 
python mtk.py plstage
`` 

#### Run stage2 plstage in bootrom
- Boot in Brom or crash to Brom
```
python mtk.py plstage --preloader=preloader.bin
```

### Use stage2 tool


### Leave stage2 and reboot
`` 
python stage2 reboot
`` 

### Read rpmb in stage2 mode
`` 
python stage2 rpmb
`` 

### Read preloader in stage2 mode
`` 
python stage2 preloader
`` 

### Read memory as hex data in stage2 mode
`` 
python stage2 memread [start addr] [length]
`` 

### Read memory to file in stage2 mode
`` 
python stage2 memread [start addr] [length] --filename filename.bin
`` 

### Write hex data to memory in stage2 mode
`` 
python stage2 memwrite [start addr] --data [data as hexstring]
`` 

### Write memory from file in stage2 mode
`` 
python stage2 memwrite [start addr] --filename filename.bin
`` 

### Extract keys
`` 
python stage2 keys --mode [sej, dxcc]
`` 
For dxcc, you need to use plstage instead of stage

---------------------------------------------------------------------

### I have issues ....... please send logs and full console details !

- Run the mtk tool with --debugmode. Log will be written to log.txt (hopefully)

## Rules / Infos

### Chip details / configs
- Go to config/brom_config.py
- Unknown usb vid/pids for autodetection go to config/usb_ids.py

## Learning Resources 
[MTK Preloader](https://o0xmuhe.github.io/2022/03/05/MTK-Preloader-踩坑/)

[MOSEC-2022](https://o0xmuhe.github.io/2022/11/23/议题解读-MOSEC2022-MediAttack-break-the-boot-chain-of-MediaTek-SoC/)

[Dissecting MTK BROM Exploit](https://tinyhack.com/2021/01/31/dissecting-a-mediatek-bootrom-exploit/)

[Dumping Exynos BROM](https://fredericb.info/2020/06/exynos8890-bootrom-dump-dump-exynos-8890-bootrom-from-samsung-galaxy-s7.html)

[Rev Exynos BROM USB STACK ](https://fredericb.info/2020/06/reverse-engineer-usb-stack-of-exynos-bootrom.html#reverse-engineer-usb-stack-of-exynos-bootrom)

[Buffer Overflow In Huawei BROM USB STACK](https://labs.taszk.io/blog/post/bootrom_usb/)
