mkdir -p /mnt/raspbian

# mount partition
mount -o rw ${1}2  /mnt/raspbian
mount -o rw ${1}1 /mnt/raspbian/boot

# mount binds
mount --bind /dev /mnt/raspbian/dev/
mount --bind /sys /mnt/raspbian/sys/
mount --bind /proc /mnt/raspbian/proc/
mount --bind /dev/pts /mnt/raspbian/dev/pts

# ld.so.preload fix
sed -i 's/^/#CHROOT /g' /mnt/raspbian/etc/ld.so.preload
mount --bind /etc/resolv.conf /mnt/raspbian/etc/resolv.conf

# copy qemu binary
cp /usr/bin/qemu-arm-static /mnt/raspbian/usr/bin/

echo "You will be transferred to the bash shell now."
echo "Issue 'exit' when you are done."
echo "Issue 'su pi' if you need to work as the user pi."

# chroot to raspbian
chroot /mnt/raspbian /bin/bash -c "echo HELLO WORLD; exit 1"

# ----------------------------
# Clean up
# revert ld.so.preload fix
sed -i 's/^#CHROOT //g' /mnt/raspbian/etc/ld.so.preload
rm /mnt/raspbian/usr/bin/qemu-arm-static

# unmount everything
umount /mnt/raspbian/{dev/pts,dev,etc/resolv.conf,sys,proc,boot,}
