#!/usr/bin/env bash

if [ -n "$(nix-locate "$1" --top-level)" ]; then
    echo "found:   $1"
else
    echo "missing: $1"
fi
