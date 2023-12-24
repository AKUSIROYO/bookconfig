lcdinit
fatload mmc 0 0 /script/uzImage.bin
setenv mem=256M cma=32M bootargs root=/dev/mmcblk0p2 rw rootwait
bootm 0
