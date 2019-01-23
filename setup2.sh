# raspbian stretch lite on ubuntu

### You can write the raspbian image onto the sd card,
# boot the pi so it expands the fs, then plug back to your laptop/desktop
# and chroot to it with my script
# https://gist.github.com/htruong/7df502fb60268eeee5bca21ef3e436eb
# sudo ./chroot-to-pi.sh /dev/sdb
# I found it to be much less of a pain in the ass and more reliable
# than doing the kpartx thing
RASPBIAN=$(ls *.img)
MAP_PATH=/dev
MOUNT_PATH=/mnt/raspbian

# extend raspbian image by 1gb
dd if=/dev/zero bs=1M count=1024 >> $RASPBIAN

# set up image as loop device
kpartx -v -a ${RASPBIAN}

#do the parted stuff, unmount kpartx, then mount again
cat parted-script | parted /dev/loop0
kpartx -d /dev/loop0
kpartx -v -a ${RASPBIAN}

# check file system
e2fsck -f ${MAP_PATH}/loop0p2

#expand partition
resize2fs ${MAP_PATH}/loop0p2

# mount partition
mount -o rw ${MAP_PATH}/loop0p2  ${MOUNT_PATH}
mount -o rw ${MAP_PATH}/loop0p1 ${MOUNT_PATH}/boot

# mount binds
mount --bind /dev ${MOUNT_PATH}/dev/
mount --bind /sys ${MOUNT_PATH}/sys/
mount --bind /proc ${MOUNT_PATH}/proc/
mount --bind /dev/pts ${MOUNT_PATH}/dev/pts

# ld.so.preload fix
sed -i 's/^/#/g' ${MOUNT_PATH}/etc/ld.so.preload

# copy qemu binary
cp /usr/bin/qemu-arm-static ${MOUNT_PATH}/usr/bin/

# chroot to raspbian
chroot ${MOUNT_PATH} /bin/bash -c "HELLO WORLD"

# revert ld.so.preload fix
sed -i 's/^#//g' ${MOUNT_PATH}/etc/ld.so.preload

# unmount everything
umount ${MOUNT_PATH}/{dev/pts,dev,sys,proc,boot,}

# unmount loop device
kpartx -d /dev/loop0
