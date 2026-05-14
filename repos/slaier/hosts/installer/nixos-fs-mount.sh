#!/usr/bin/env bash

export PATH=/empty:@path@

set -eux

NAME="$1"

ROOT_DEVICE=/dev/disk/by-label/"$NAME"-nixos
mount -m -o compress=zstd,subvol=root "$ROOT_DEVICE" /mnt
mount -m -o compress=zstd,noatime,subvol=nix "$ROOT_DEVICE" /mnt/nix
mount -m -o noatime,subvol=swap "$ROOT_DEVICE" /swap

mount -m -o umask=077 /dev/disk/by-label/"$NAME"-boot /mnt/boot
