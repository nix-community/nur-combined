#!/usr/bin/env bash
# Refresh package sources and dependency metadata using `GITHUB_TOKEN`.
set -euo pipefail

# Keep Go and Cargo caches and nix-repin's scratch trees, Pub's cache among them, on the large Nix mount.
export GOMODCACHE=/nix/var/tmp/gomodcache
export CARGO_HOME=/nix/var/tmp/cargo
export TMPDIR=/nix/var/tmp/repin
sudo mkdir -p "${GOMODCACHE}" "${CARGO_HOME}" "${TMPDIR}"
sudo chown "$(id -u):$(id -g)" "${GOMODCACHE}" "${CARGO_HOME}" "${TMPDIR}"

nix run .#update-sources

# Resolving a pub lock realises a multi-gigabyte Flutter SDK, part of which gc-store would root with its package's build closure and keep in the store cache.
# Nix keeps whatever is still live, so a partial sweep is expected and fine.
mapfile -t flutters < <(grep --only-matching --no-filename 'flutter: "[[:alnum:]_]*"' pkgs/*/source.ts | cut --delimiter '"' --fields 2 | sort --unique)
for flutter in "${flutters[@]}"; do
  sdk="$(nix eval --raw --inputs-from . "nixpkgs#${flutter}")"
  [[ -e "${sdk}" ]] || continue
  echo "Dropping the ${flutter} SDK from the store"
  nix-store --query --requisites "${sdk}" | xargs -r sudo "$(command -v nix-store)" --delete || true
done

# Flakes skip untracked files, which would hide a new package's source.nix from update-hashes.
git add --intent-to-add pkgs
nix run .#update-hashes
