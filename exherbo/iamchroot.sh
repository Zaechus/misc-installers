#!/usr/bin/env bash
set -e

my_hostname=zebra

cave sync

# Install kernel
cd /usr/src
curl -OL https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.17.7.tar.xz
make nconfig
make -j$(nproc)
make modules_install
cp arch/x86/boot/bzImage /boot/kernel

# init
cave resolve --execute --preserve-world --skip-phase test sys-apps/systemd

# Boot loader
bootctl install
kernel-install add 5.17.7 /boot/vmlinuz-5.17.7

# Finalize
echo $my_hostname > /etc/hostname
printf "127.0.0.1\t$my_hostname\tlocalhost\n::1\tlocalhost\n" > /etc/hosts

echo LANG="en_US.UTF-8" > /etc/env.d/99locale
ln -s /usr/share/zoneinfo/America/Denver /etc/localtime

cave resolve linux-firmware

passwd
