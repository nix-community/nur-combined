#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash -p git -p gnused
# shellcheck shell=bash

set -eu

dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

seed="radicle.liw.fi"
repo="z2kxCtBwDQMPcaf9vGTNH5nYkp9qk"
node="z6MkgEMYod7Hxfy9qCvDv5hYHkZ4ciWmLFgfvm3Wn1b2w2FV"
url="https://$seed/$repo.git"

current="$(sed -n 's:.*version = "\([0-9.]\+\)";.*:\1:p' "$dir/package.nix")"

latest="$(git ls-remote "$url" "refs/namespaces/$node/refs/tags/vmdb2-*" \
    | sed -n 's:.*\trefs/namespaces/[A-Za-z0-9]\+/refs/tags/vmdb2-\([0-9.]\+\).*:\1:p' \
    | sort -uV \
    | tail -n 1)"

if [ "$current" = "$latest" ]; then
    echo "version $current is the latest, skipping"
    exit
fi

echo "vmdb2: $current -> $latest"
echo "TODO: manually update"
exit 3
