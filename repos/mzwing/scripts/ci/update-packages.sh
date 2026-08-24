#!/usr/bin/env bash
# Refresh package sources and dependency metadata using `GITHUB_TOKEN`.
set -euo pipefail
trap 'rm -f secrets.toml' EXIT

# Keep Go and Cargo caches on the large Nix mount.
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
# TEMPORARY: wsrx 0.6.1 was committed to _sources by hand without regenerating the Cargo.nix files.
# update-lockfiles only compares _sources against HEAD, so it sees no change and skips them forever.
# Remove this once a run has committed the regenerated Cargo.nix files.
nix run .#update-lockfiles -- wsrx wsrx-desktop
nix run .#update-pins
nix run .#update-hashes
