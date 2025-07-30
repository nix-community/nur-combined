#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

wget https://patch-diff.githubusercontent.com/raw/renovatebot/renovate/pull/37222.diff -O 37222.diff