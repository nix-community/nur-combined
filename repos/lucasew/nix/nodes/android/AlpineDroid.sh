#!/system/bin/sh

# Based on https://github.com/stnby/AlpineDroid
# Needs installed: https://f-droid.org/en/packages/com.smartpack.busyboxinstaller/
set -e

PATH=$PATH:/data/data/ru.meefik.busybox/files/bin
# PARAMETERS ---
DEST='/data/alpinedroid'
MIRR='http://dl-cdn.alpinelinux.org/alpine'
DNS1='1.1.1.1'
DNS2='1.0.0.1'
# --------------

# Prepare (start)
ARCH=armv7
mkdir -p $DEST
cd $DEST
echo "> prepare"
# Prepare (end)



# Download rootfs (start)
echo "< download rootfs"
FILE=`busybox wget -qO- "$MIRR/latest-stable/releases/$ARCH/latest-releases.yaml" | busybox grep -o -m 1 'alpine-minirootfs-.*.tar.gz'`

busybox wget "$MIRR/latest-stable/releases/$ARCH/$FILE" -O rootfs.tar.gz
echo "> download rootfs"
# Download rootfs (end)



# Extract rootfs (start)
echo "< extract rootfs"
busybox tar -xf rootfs.tar.gz
echo "> extract rootfs"
# Extract rootfs (end)



# Configure (start)
echo "> configure"
mkdir -p mnt/sdcard

echo "nameserver $DNS1
nameserver $DNS2" > etc/resolv.conf

echo "#!/system/bin/sh -e
busybox mount -t proc none $DEST/proc
busybox mount --rbind /sys $DEST/sys
busybox mount --rbind /dev $DEST/dev
busybox mount --rbind /sdcard $DEST/mnt/sdcard" > up.sh

echo "#!/system/bin/sh
busybox umount $DEST/proc
busybox umount -l $DEST/sys
busybox umount -l $DEST/dev
busybox umount -l $DEST/mnt/sdcard" > down.sh

echo "#!/system/bin/sh
busybox chroot $DEST /bin/sh --login" > chroot.sh

busybox chmod +x {up,down,chroot}.sh
echo "< configure"
# Configure (end)
