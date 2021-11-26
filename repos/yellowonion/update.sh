#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

pkgs/bcachefs-tools/update.sh
pkgs/bcachefs-kernel/update.sh
