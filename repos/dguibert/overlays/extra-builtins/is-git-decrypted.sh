#!/usr/bin/env bash
set -x
decrypted=false
case $(file --mime-type $1) in
  *text/plain)
  decrypted=true;;
esac
nix-instantiate --eval --strict -E "{ success=true; value=$decrypted; }"

