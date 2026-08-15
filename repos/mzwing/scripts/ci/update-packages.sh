#!/usr/bin/env bash
# Refresh sources, lockfiles, pins and dependency hashes. Expects GITHUB_TOKEN in the environment.
set -euo pipefail
trap 'rm -f secrets.toml' EXIT

# nothing-but-nix cleaves almost all disk into /nix and leaves / with ~1G, which the gomod2nix module downloads and crate2nix's cargo registry overflow unless their caches live on the big mount.
export GOMODCACHE=/nix/var/tmp/gomodcache
export CARGO_HOME=/nix/var/tmp/cargo
sudo mkdir -p "${GOMODCACHE}" "${CARGO_HOME}"
sudo chown "$(id -u):$(id -g)" "${GOMODCACHE}" "${CARGO_HOME}"

cat >secrets.toml <<EOF
[keys]
github = "${GITHUB_TOKEN}"
EOF

nix run .#update-sources
nix run .#update-lockfiles
nix run .#update-pins
nix run .#update-hashes
