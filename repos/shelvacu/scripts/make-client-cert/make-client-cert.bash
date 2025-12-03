#!/usr/bin/env bash
source shellvaculib.bash

name="$HOSTNAME"

config='
organization = "Shelvacu"
state = "Washington"
country = US
cn = "'"$name"'"

expiration_days = -1

signing_key
encryption_key
tls_www_client
'

dest_prefix="$HOME/.pki/vacu-client-cert"
dest_key="$dest_prefix.key"
dest_cert="$dest_prefix.cert"
dest_p12="$dest_prefix.p12"
# dest_combined="$dest_prefix.combined"

if [[ -f $dest_key ]]; then
  svl_die "$dest_key already exists"
fi

if [[ -f $dest_cert ]]; then
  svl_die "$dest_cert already exists"
fi

certtool --generate-privkey --outfile="$dest_key" --key-type=ed25519 --sec-param=high
certtool --generate-self-signed --load-privkey "$dest_key" --template <(echo "$config") --outfile "$dest_cert"
certtool --load-certificate "$dest_cert" --load-privkey "$dest_key" --to-p12 --p12-name vacu-client-cert-"$name" --password=password --outfile "$dest_p12"
# cat "$dest_key" "$dest_cert" > "$dest_combined"
certutil -d "sql:$HOME/.pki/nssdb" -A -n vacu-user-cert-"$name" -i "$dest_p12"
