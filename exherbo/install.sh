#!/bin/sh -e

while :; do
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
    printf '\nDisk (e.g. /dev/sda): ' && read -r my_disk
    [ -b "$my_disk" ] && break
done

case $my_disk in
*"nvme"*)
    part1="$my_disk"p1
    part2="$my_disk"p2
    ;;
*)
    part1="$my_disk"1
    part2="$my_disk"2
    ;;
esac

# Partition
printf "label: gpt\n,550M,U\n,,\n" | sfdisk "$my_disk"

# Format
mkfs.vfat -F 32 "$part1"
mkfs.ext4 "$part2"

# Mount root
mkdir /mnt/exherbo
mount "$part2" /mnt/exherbo
cp iamchroot.sh /mnt/exherbo
cd /mnt/exherbo

# Stage 3
curl -OL https://dev.exherbo.org/stages/exherbo-x86_64-pc-linux-gnu-current.tar.xz
curl -OL https://dev.exherbo.org/stages/exherbo-x86_64-pc-linux-gnu-current.tar.xz.sha256sum
sha256sum -c exherbo-x86_64-pc-linux-gnu-current.tar.xz.sha256sum

tar xJpf exherbo*xz

# fstab
uuid1=$(blkid "$part1" -o value -s UUID)
uuid2=$(blkid "$part2" -o value -s UUID)
printf "/dev/disk/by-uuid/%s\t/\text4\tdefaults\t0 1\n/dev/disk/by-uuid/%s\t/boot\tvfat\tdefault\t0 2\n" "$uuid2" "$uuid1" >/mnt/exherbo/etc/fstab

# Chroot
mount -o rbind /dev /mnt/exherbo/dev/
mount -o rbind /sys /mnt/exherbo/sys/
mount -t proc none /mnt/exherbo/proc/
mount "$part1" /mnt/exherbo/boot/
cp /etc/resolv.conf /mnt/exherbo/etc/
env -i TERM="$TERM" SHELL=/bin/bash HOME="$HOME" part2="$part2" \
    "$(which chroot)" /mnt/exherbo /bin/bash -c \
    'source /etc/profile; ./iamchroot.sh; rm iamchroot.sh;'
