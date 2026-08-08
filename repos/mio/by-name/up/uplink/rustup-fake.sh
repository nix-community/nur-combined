#!/bin/sh

if [ "$1" = "toolchain" ] && [ "$2" = "list" ]; then
    echo "stable-x86_64-unknown-linux-gnu (default)"
    exit 0
fi

if [ "$1" = "target" ] && [ "$2" = "list" ]; then
    echo "x86_64-unknown-linux-gnu"
    exit 0
fi

if [ "$1" = "run" ]; then
    shift 2
    exec "$@"
fi

# For any other command (like install, target add, etc), just exit 0
exit 0
