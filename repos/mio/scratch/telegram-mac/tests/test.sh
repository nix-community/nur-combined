#!/bin/sh
LIBOPUS_PATH="opus"
LIBVPX_PATH="vpx"
LIBDAV1D_PATH="dav1d"
while true; do
    case "$1" in
        --libopus_path) LIBOPUS_PATH="$2"; shift 2 ;;
        --libvpx_path) LIBVPX_PATH="$2"; shift 2 ;;
        --libdav1d_path) LIBDAV1D_PATH="$2"; shift 2 ;;
        *) break ;;
    esac
done

if [ "$1" == "--cflags" ]; then
    NAME="$2"
    case "$NAME" in
        zlib*) echo "zlib" ;;
        opus*) echo "-I$LIBOPUS_PATH/include/opus" ;;
        vpx*) echo "-I$LIBVPX_PATH/include" ;;
        dav1d*) echo "-I$LIBDAV1D_PATH/include" ;;
        *) exit 1 ;;
    esac
fi
