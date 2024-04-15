#!/usr/bin/env bash
set -euo pipefail
set -x
echo $0 $@ >&2

d=$(mktemp -d)
f=$d/private_key
pubfile=$d/public_key
trap "rm -r $d" EXIT
key_name="$1"
if ! pass show "$key_name" > $f; then
  rm $f
  @wireguardtools@/bin/wg genkey | head -c -1 | pass insert -m -f $key_name >&2
fi

pass show $key_name > $f
cat "$f" | @wireguardtools@/bin/wg pubkey | head -c -1 > $pubfile
nix-instantiate --strict --eval -E "{ success=true; value={ privateKey = builtins.readFile $f; publicKey = builtins.readFile $pubfile; }; }"
