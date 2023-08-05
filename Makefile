KERNEL_OPTS = \
	CROSS_COMPILE=arm-linux-gnueabi- \
	CFLAGS="-march=armv5te -mtune=arm926ej-s" \
	-j4
MIRROR = http://deb.debian.org/debian
DEBOOTSTRAP_OPTS = \
	--arch armel \
	--include systemd-sysv,sudo,gpiod,firmware-misc-nonfree,network-manager,wpasupplicant,libpam-systemd,udev \
	--components main,contrib,non-free \
	--variant minbase
SUITE = bullseye

all: boot.zip rootfs.tar.gz

boot.zip: script/uzImage.bin script/scriptcmd
	rm -f $@
	zip -0 $@ $^

script/uzImage.bin: zImage_w_dtb | script
	mkimage -A arm -O linux -T kernel -C none -a 0x8000 -e 0x8000 -n linux-vtwm -d $< $@

zImage_w_dtb: config | kernel
	$(MAKE) -C kernel ARCH=arm KCONFIG_CONFIG=../$< $(KERNEL_OPTS) zImage wm8505-ref.dtb
	cat kernel/arch/arm/boot/zImage kernel/arch/arm/boot/dts/wm8505-ref.dtb >$@

config: seed | kernel
	cp $< $@.tmp
	$(MAKE) -C kernel ARCH=arm KCONFIG_CONFIG=../$@.tmp olddefconfig
	rm -f $@.tmp.old
	mv $@.tmp $@

menuconfig: config | kernel
	cp $< config.next.tmp
	$(MAKE) -C kernel ARCH=arm KCONFIG_CONFIG=../config.next.tmp menuconfig
	rm -f config.next.tmp.old
	mv config.next.tmp config.next

kernel:
	git rev-parse --verify kernel || git fetch $(FETCH_KERNEL_OPTS) origin kernel:kernel
	git worktree add $@ kernel

script/scriptcmd: cmd | script
	mkimage -A arm -O linux -T script -C none -a 1 -e 0 -n "script image" -d $< $@

script:
	mkdir -p $@

rootfs.tar.gz: buildrootfs multistrap.conf ship
	fakeroot ./$< $@

.PHONY: all menuconfig
