#!/usr/bin/env bash
set -euo pipefail
#set -x
#echo $0 $@ >&2

private_key="$1"
pubkey=$(echo "$private_key" | @wireguardtools@/bin/wg pubkey)
echo "$0 -> $pubkey" >&2
echo "\"$pubkey\""
