#!/usr/bin/env bash
# Root update apps before post-run garbage collection.
set -euo pipefail

gcroots=/nix/var/nix/gcroots/nur-ci-update
sudo install -d "${gcroots}"
for app in update-sources update-lockfiles update-pins update-hashes; do
  program="$(nix eval --raw ".#apps.x86_64-linux.${app}.program")"
  [[ -e "${program}" ]] || continue
  sudo ln -sfn "${program}" "${gcroots}/${app}"
done
