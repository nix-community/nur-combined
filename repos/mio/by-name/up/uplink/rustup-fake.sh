#!/bin/sh

if [ "$1" = "toolchain" ] && [ "$2" = "list" ]; then
    echo "stable-x86_64-unknown-linux-gnu (default)"
    exit 0
fi

if [ "$1" = "target" ] && [ "$2" = "list" ]; then
    echo "x86_64-unknown-linux-gnu"
    echo "aarch64-unknown-linux-gnu"
    echo "aarch64-linux-android"
    echo "armv7-linux-androideabi"
    echo "x86_64-linux-android"
    echo "i686-linux-android"
    exit 0
fi

if [ "$1" = "run" ]; then
    shift 2
    exec "$@"
fi

# For any other command (like install, target add, etc), just exit 0
exit 0
