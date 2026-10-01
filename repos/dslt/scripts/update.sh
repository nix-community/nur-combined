#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nvfetcher python3 curl jq yq-go git
# shellcheck shell=bash

# Unified dependency update entry point.
#
#   ./scripts/update.sh                       # everything
#   ./scripts/update.sh --filter '^classin-'  # refresh one record (smoke test)
#   ./scripts/update.sh --list                # print the tracked records
#   ./scripts/update.sh --help
#
# The shebang above brings nvfetcher, python3, curl, jq and git; nix itself is
# taken from the caller so it can reach the host store/daemon. Run it through
# scripts/update-shell.nix for the same toolchain with a pinned <nixpkgs>:
#
#   nix-shell scripts/update-shell.nix --run 'python3 scripts/update.py'
#
# The updater only writes _sources/, pkgs/, flake.lock and vendor/bun2nix; it
# never commits or pushes.
set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec python3 "$here/update.py" "$@"
