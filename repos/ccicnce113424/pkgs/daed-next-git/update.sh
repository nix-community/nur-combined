#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnugrep jq
# shellcheck shell=bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"
# The pnpm lock lives in the product shell repository, which is the
# `daed-next-web` nvfetcher source this unit owns (and the one whose hash
# src-info.json carries); the Rust workspace source is updated on its own.
package_name="daed-next-web"

parse_args "$@"
setup_paths
read_source_info "jq"
check_stale "jq"

nix_build_hash \
  '(import ./pkgs {}).daed-next-git.pnpmDeps.overrideAttrs (_: { outputHash = ""; outputHashAlgo = "sha256"; })' \
  "DaedNext web deps"

jq -n \
  --arg version "$version" \
  --arg hash "$extracted_hash" \
  --arg sourceSha256 "$source_sha256" \
  '{ version: $version, hash: $hash, sourceSha256: $sourceSha256 }' >"$src_info"
