# raspbian stretch lite on ubuntu

### You can write the raspbian image onto the sd card,
# boot the pi so it expands the fs, then plug back to your laptop/desktop
# and chroot to it with my script
# https://gist.github.com/htruong/7df502fb60268eeee5bca21ef3e436eb
# sudo ./chroot-to-pi.sh /dev/sdb
# I found it to be much less of a pain in the ass and more reliable
# than doing the kpartx thing
RASPBIAN=$(ls *.img)

echo $RASPBIAN
# extend raspbian image by 1gb

dd if=/dev/zero bs=1M count=1024 >> $RASPBIAN

# set up image as loop device
kpartx -v -a ${RASPBIAN}

#do the parted stuff, unmount kpartx, then mount again
cat parted-script | parted /dev/loop0
kpartx -d /dev/loop0
kpartx -v -a ${RASPBIAN}

# check file system
e2fsck -f /dev/mapper/loop0p2

#expand partition
resize2fs /dev/mapper/loop0p2

# mount partition
mount -o rw /dev/mapper/loop0p2  /mnt/raspbian
mount -o rw /dev/mapper/loop0p1 /mnt/raspbian/boot

# mount binds
mount --bind /dev /mnt/raspbian/dev/
mount --bind /sys /mnt/raspbian/sys/
mount --bind /proc /mnt/raspbian/proc/
mount --bind /dev/pts /mnt/raspbian/dev/pts

# ld.so.preload fix
sed -i 's/^/#/g' /mnt/raspbian/etc/ld.so.preload

# copy qemu binary
cp /usr/bin/qemu-arm-static /mnt/raspbian/usr/bin/

# chroot to raspbian
chroot /mnt/raspbian /bin/bash
	# do stuff...
	exit

# revert ld.so.preload fix
sed -i 's/^#//g' /mnt/raspbian/etc/ld.so.preload

# unmount everything
umount /mnt/raspbian/{dev/pts,dev,sys,proc,boot,}

# unmount loop device
kpartx -d /dev/loop0
