#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

wget https://patch-diff.githubusercontent.com/raw/Mic92/nix-update/pull/433.diff -O 433.diff