#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gnugrep jq
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"
package_name="nix-auth"

parse_args "$@"
setup_paths
read_source_info "jq"
check_stale "jq"

nix_build_hash \
  "((import ./pkgs {}).${package_name}.overrideAttrs { vendorHash = \"\"; }).goModules" \
  "nix-auth vendor"

jq -n \
  --arg version "$version" \
  --arg hash "$extracted_hash" \
  --arg sourceSha256 "$source_sha256" \
  '{ version: $version, hash: $hash, sourceSha256: $sourceSha256 }' >"$src_info"
