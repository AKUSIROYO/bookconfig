display init force
textout -1 -1 \"Loading kernel...\" FFFFFF
fatload mmc 0 0 /script/uzImage.bin
textout -1 -1 \"Starting Linux...\" FFFFFF
setenv bootargs 'root=/dev/mmcblk0p2 rw rootwait mem=256M cma=16M console=ttyWMT0,115200 panic=3'
bootm 0
