#!/usr/bin/env bash
set -euo pipefail

out=$(git rev-parse --show-toplevel)/qemu

mkdir -p $out
diskImage=$out/nixos-test.qcow2
qemu-img create -f qcow2 $diskImage 20G
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -nic user,model=virtio \
    -drive file=$diskImage,media=disk,if=virtio \
    -cdrom ~/desktop/isos/nixos-minimal-20.03.1445.95b9c99f6d0-x86_64-linux.iso \
    -sdl
