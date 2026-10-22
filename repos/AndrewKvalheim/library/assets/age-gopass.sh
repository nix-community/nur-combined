#!/usr/bin/env bash
set -Eeuo pipefail

exec {passphrase}< <(gopass show --password "$1")

AGE_PASSPHRASE_FD="$passphrase" exec age -j 'batchpass' "${@:2}"
