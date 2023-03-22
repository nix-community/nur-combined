#!/bin/sh

set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

SWAP_SIZE=16GiB

parted /dev/nvme0n1 --script -- \
    mklabel gpt \
    mkpart primary 512MiB 100% \
    mkpart ESP fat32 1MiB 512MiB \
    set 2 esp on

cryptsetup luksFormat /dev/nvme0n1p1
cryptsetup open /dev/nvme0n1p1 crypt

pvcreate /dev/mapper/crypt
vgcreate lvm /dev/mapper/crypt
lvcreate -L "$SWAP_SIZE" -n swap lvm
lvcreate -l 100%FREE -n root lvm

mkfs.ext4 -L nixos /dev/lvm/root
mkswap -L swap /dev/lvm/swap
mkfs.vfat -n boot /dev/nvme0n1p2

mount /dev/disk/by-label/nixos /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p2 /mnt/boot
swapon /dev/lvm/swap

cat << EOF
# Run the following commands as setup user
nixos-generate-config --root /mnt

# Change uuids to labels
vim /mnt/etc/nixos/hardware-configuration.nix

# Install system
mkdir -p /mnt/home/ambroisie/git/nix/config
cd /mnt/home/ambroisie/git/nix/config

git clone <this-repo> .
# Assuming you set up GPG key correctly
git crypt unlock

# Setup LUKS with 'boot.initrd.luks.devices.crypt', device is /dev/nvme0n1p1, preLVM = true

# Use 'nixos-install --flake .#aramis --root /mnt --impure' because of home-manager issue
EOF
