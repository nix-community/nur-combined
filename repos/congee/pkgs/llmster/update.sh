#!/usr/bin/env bash
# Bump llmster to the latest upstream version. nix-update cannot handle
# llmster.lmstudio.ai, so the update workflow calls this script instead.
# Usage: ./update.sh [--commit]
set -euo pipefail

cd "$(dirname "$0")"

# upstream versions look like "0.0.15-2" (version-build); the nix version
# uses "+" to match the output of `llmster --version`
# NB: fetch fully before parsing — piping curl into `awk ... exit` closes the
# pipe early, so curl fails writing the rest of the body (error 23) under pipefail.
install_sh="$(curl -fsSL https://lmstudio.ai/install.sh)"
upstream="$(awk -F'"' '/^APP_VERSION=/ {print $2; exit}' <<<"$install_sh")"
new_version="${upstream%-*}+${upstream##*-}"

old_version="$(sed -n 's/^  version = "\(.*\)";$/\1/p' default.nix)"
if [ "$new_version" = "$old_version" ]; then
  echo "llmster is up to date: $old_version"
  exit 0
fi

checksum="$(curl -fsSL "https://llmster.lmstudio.ai/download/${upstream}-darwin-arm64.full.sha512")"
sri="$(nix --extra-experimental-features nix-command hash convert --hash-algo sha512 --to sri "$checksum")"

sed -i.bak \
  -e "s|^  version = \"$old_version\";|  version = \"$new_version\";|" \
  -e "s|hash = \"sha512-[^\"]*\"|hash = \"$sri\"|" \
  default.nix
rm -f default.nix.bak

echo "llmster: $old_version -> $new_version"
if [ "${1:-}" = "--commit" ]; then
  git commit -m "llmster: $old_version -> $new_version" -- default.nix
fi
