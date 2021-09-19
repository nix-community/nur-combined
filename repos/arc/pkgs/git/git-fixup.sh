#!/usr/bin/env bash
set -eu

REV=''${1-HEAD}
REV=$(git rev-parse "$REV")

git commit --fixup "$REV"
exec git rebase -i "$REV~"
