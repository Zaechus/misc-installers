#!/bin/sh

# Choose disk
while :; do
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
    printf "\nDisk (e.g. /dev/sda): " && read -r my_disk
    [ -b "$my_disk" ] && break
done

case "$my_disk" in
*"nvme"*)
    part1="$my_disk"p1
    part3="$my_disk"p3
    ;;
*)
    part1="$my_disk"1
    part3="$my_disk"3
    ;;
esac

mkdir -p /mnt/gentoo

cryptsetup open "$part3" root
mount -o compress=zstd,subvol=root /dev/mapper/root /mnt/gentoo
mount -o compress=zstd,subvol=home /dev/mapper/root /mnt/gentoo/home
mount "$part1" /mnt/gentoo/boot

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

chroot /mnt/gentoo /bin/bash
