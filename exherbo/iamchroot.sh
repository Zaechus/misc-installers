#!/bin/sh -e

my_hostname=zebra
kver="5.18.11"

# Configure package manager
sed -i "s/jobs=.*/jobs=$(nproc)/" /etc/paludis/options.conf

cave sync

# Install kernel
cd /usr/src
curl -OL https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$kver.tar.xz
tar xJf linux*
cd linux*
make MENUCONFIG_COLOR=blackbg menuconfig
make -j$(($(nproc) + 1))
make modules_install
make install

# init
printf 'sys-apps/systemd efi\n' >>/etc/paludis/options.conf
# cave resolve world -c
cave sync
cave resolve -1x --skip-phase test sys-apps/systemd
eclectic init set systemd

# Boot loader
bootctl install
kernel-install add $kver /boot/vmlinuz-$kver
sed -i "s~^options.*~options    root=/dev/disk/by-uuid/$(blkid "$part2" -o value -s UUID)~" /boot/loader/entries/*-$kver.conf

# Finalize
echo $my_hostname >/etc/hostname
printf "127.0.0.1\t%s\tlocalhost\n::1\tlocalhost\n" "$my_hostname" >/etc/hosts

echo LANG="en_US.UTF-8" >/etc/env.d/99locale
ln -s /usr/share/zoneinfo/America/Denver /etc/localtime

systemctl enable getty@tty1
systemctl enable systemd-resolved
systemctl enable systemd-networkd

passwd
