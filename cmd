lcdinit
fatload mmc 0 0 /script/uzImage.bin
setenv bootargs 'mem=249M root=/dev/mmcblk0p2 rw rootwait panic=3'
bootm 0
