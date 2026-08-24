#!/usr/bin/env bash
# Refresh package sources and dependency metadata using `GITHUB_TOKEN`.
set -euo pipefail
trap 'rm -f secrets.toml' EXIT

# Keep Go, Cargo and Pub caches on the large Nix mount.
export GOMODCACHE=/nix/var/tmp/gomodcache
export CARGO_HOME=/nix/var/tmp/cargo
export PUB_CACHE=/nix/var/tmp/pub-cache
sudo mkdir -p "${GOMODCACHE}" "${CARGO_HOME}" "${PUB_CACHE}"
sudo chown "$(id -u):$(id -g)" "${GOMODCACHE}" "${CARGO_HOME}" "${PUB_CACHE}"

cat >secrets.toml <<EOF
[keys]
github = "${GITHUB_TOKEN}"
EOF

nix run .#update-sources
nix run .#update-lockfiles
nix run .#update-pins
nix run .#update-hashes
