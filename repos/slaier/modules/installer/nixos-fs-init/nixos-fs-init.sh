#!/usr/bin/env bash

export PATH=/empty:@path@

set -eux

NAME="$1"
DEVICE="$2"

parted "$DEVICE" -- mklabel gpt
parted "$DEVICE" -- mkpart root btrfs 512MB 100%
parted "$DEVICE" -- mkpart ESP fat32 1MB 512MB
parted "$DEVICE" -- set 2 esp on

mkfs.btrfs -f -L "$NAME-nixos" "$DEVICE"*1
mkfs.fat -F 32 -n "$NAME-boot" "$DEVICE"*2

mount -m "$DEVICE"*1 /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/swap
umount /mnt

mount -m -o subvol=swap "$DEVICE"*1 /swap
btrfs filesystem mkswapfile --size 16g --uuid clear /swap/swapfile
umount /swap
