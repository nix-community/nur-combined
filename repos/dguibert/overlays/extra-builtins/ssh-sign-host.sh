#!/usr/bin/env bash
set -euo pipefail
set -x
echo $0 $@ >&2
ca=$1
hostname=$2
realms=$3
type=$4

options=""
test $type == "rsa" && options+=" -b 4096"

if ! pass show "$ca" >/dev/null; then
  echo "run $ @ssh_generate_ca@ $ca" >&2
  exit -1
  if ! pass show "${ca}-pass" >/dev/null; then
    echo "run $ @ssh_generate_ca@ $ca" >&2
    exit -2
  fi
fi

key_name="$hostname/ssh_host_${type}_key"
pub_name="$hostname/ssh_host_${type}_key.pub"
cert_name="$hostname/ssh_host_${type}_key-cert.pub"

d=$(mktemp -d)
f=$d/host_key
pubfile=$d/host_key-cert.pub
trap "rm -r $d" EXIT
if ! pass show "$cert_name" > $pubfile; then
  rm $pubfile
  if ! pass show "$key_name" > $f; then
    rm $f
    # ssh-key does not exist; create it
    ssh-keygen -t $type $options -f $f -N "" >&2
    cat $f | pass insert -m -f $key_name >&2
    cat $f.pub | pass insert -m -f $key_name.pub >&2
  fi
  pass show ${key_name}.pub > $f.pub
  pass show ${ca} > $d/ssh-ca
  chmod 600 $d/ssh-ca

  ssh-keygen -s $d/ssh-ca \
    -P "$(pass show ${ca}-pass)" \
    -I "$hostname host key" \
    -n "$realms" \
    -V -5m:+$(( 365 * 1))d \
    -h \
    $f.pub
  cat $pubfile | pass insert -m -f $cert_name >&2
else
  pass show ${key_name}     > $f
  pass show ${key_name}.pub > $f.pub
fi
cat $pubfile >&2
nix-instantiate --strict --eval -E "{ success=true; value={ host_key = builtins.readFile $f; host_key_pub = builtins.readFile $f.pub; host_key_cert_pub = builtins.readFile $pubfile; }; }"

