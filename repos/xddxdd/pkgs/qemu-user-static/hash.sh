#!/bin/sh
VERSION=6.2+dfsg-2
for ARCH in amd64 arm64; do
    echo $ARCH
    nix-prefetch-url "http://ftp.us.debian.org/debian/pool/main/q/qemu/qemu-user-static_${VERSION}_${ARCH}.deb"
done
