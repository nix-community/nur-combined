#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

#./update-tools.sh
pkgs/bcachefs-kernel/update.sh
#git -C ../linux/bcachefs format-patch --stdout -p kent/master..master > ./pkgs/bcachefs-kernel/woob.patch
