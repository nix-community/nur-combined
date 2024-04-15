#!/usr/bin/env bash
set -euo pipefail
set -x
ca=$1
if pass show "${ca}-pass" >/dev/null; then
  exit -1
  if pass show "$ca" >/dev/null; then
    exit -2
  fi
fi

pass generate --no-symbols ${ca}-pass 16
password=$(pass show ${ca}-pass)

d=$(mktemp -d)
trap "rm -r $d" EXIT

f=$d/ssh-ca
ssh-keygen -f $f -N "$password" -C "SSH CA for $1"

cat $f | pass insert -m -f $ca
cat $f.pub | pass insert -m -f $ca.pub

