#!/usr/bin/env bash

set -eux

DEVICE="/dev/disk/by-id/nvme-SAMSUNG_MZVL2256HCHQ-00BH1_S63XNX0RC21761"

F2FS_ARGS="-O encrypt,extra_attr,inode_checksum,lost_found,sb_checksum,compression"

sgdisk \
  --align-end \
  --new=0:0:-0 \
  --change-name="0:nix" \
  --typecode=0:8300 \
  "$DEVICE"

mkfs.f2fs $F2FS_ARGS "/dev/disk/by-partlabel/nix"
