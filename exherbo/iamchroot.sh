#!/bin/sh -e

my_hostname=zebra
kver="5.18.11"

# Configure package manager
sed "s/jobs=.*/jobs=$(($(nproc)+1))/" /etc/paludis/options.conf

cave sync

# Install kernel
cd /usr/src
curl -OL https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$kver.tar.xz
tar xJf linux*
cd linux*
make MENUCONFIG_COLOR=blackbg menuconfig
make -j$(($(nproc)+1))
make modules_install
cp arch/x86_64/boot/bzImage /boot/vmlinuz-$kver

# init
printf '*/* systemd\nsys-apps/systemd efi\n' >> /etc/paludis/options.conf
cave resolve -x sys-apps/systemd
printf 'dev-lang/python sqlite\ndev-libs/gnutls pkcs11\n' >> /etc/paludis/options.conf
cave resolve repository/net -1x
cave resolve repository/gnome -1x
cave resolve repository/python -1x
cave resolve world -cx
cave resolve --execute --preserve-world --skip-phase test sys-apps/systemd
eclectic init set systemd

# Boot loader
bootctl install
kernel-install add $kver /boot/vmlinuz-$kver

# Finalize
echo $my_hostname > /etc/hostname
printf "127.0.0.1\t$my_hostname\tlocalhost\n::1\tlocalhost\n" > /etc/hosts

echo LANG="en_US.UTF-8" > /etc/env.d/99locale
ln -s /usr/share/zoneinfo/America/Denver /etc/localtime

cave resolve repository/hardware -1x
cave resolve linux-firmware

passwd
