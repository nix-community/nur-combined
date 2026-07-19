#!/usr/bin/env bash
# this mimics the "Check evaluation" step in CI, but starts with an empty Nix store as some issues don't arise with existing paths, e.g:
# error: path '/nix/store/m84n937sbh7jf74dkmah42spgi78gjsh-channel-rust-nightly.toml.drv' is not valid

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
store_dir="$(mktemp -d)"
trap 'rm -rf "$store_dir"' EXIT

nix-env --store "local?root=$store_dir" -f "$repo_root" -qa '*' --meta --xml \
  --allowed-uris https://static.rust-lang.org \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path --show-trace \
  -I nixpkgs="$(nix-instantiate --find-file nixpkgs)" \
  -I "$repo_root" \
  >/dev/null
