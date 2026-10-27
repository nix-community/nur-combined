#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnugrep jq yq-go
# shellcheck shell=bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../../_scripts/update-lib.sh"
package_name="dorion-git"

parse_args "$@"
setup_paths
read_source_info "jq"
check_stale "jq"

# The CEF runtime is pinned by `src-tauri/Cargo.lock` (`cef-dll-sys`), so the
# `cef-binary` override and the `archive.json` it is handed have to follow the
# source. Derive both from the fetched tree instead of duplicating them here.
src_dir=$(nix build --no-link --print-out-paths --impure --expr "(import ./pkgs {}).${package_name}.src")

upstream_version=$(yq -p toml -o json -r '.package.version' "$src_dir/src-tauri/Cargo.toml")
cef_crate_version=$(yq -p toml -o json -r '.package[] | select(.name == "cef-dll-sys") | .version' "$src_dir/src-tauri/Cargo.lock")
if [[ $cef_crate_version != *+* ]]; then
  echo "Failed to read the CEF version from cef-dll-sys ($cef_crate_version)." >&2
  exit 1
fi
cef_version=${cef_crate_version#*+}

# Reuse the pinned archive metadata unless the CEF version changed; otherwise
# resolve it from the cef-builds index and prefetch the ~320 MB tarball.
cef_json=$(jq -c '.cef // {}' "$src_info")
if ! jq -e --arg version "$cef_version" '
    .version == $version
    and has("gitRevision") and has("chromiumVersion")
    and has("sha256") and has("archiveName") and has("archiveSha1")
  ' <<<"$cef_json" >/dev/null; then
  cef_index=$(curl -fsSL https://cef-builds.spotifycdn.com/index.json)
  IFS=$'\t' read -r cef_full cef_name cef_sha1 < <(
    jq -r --arg version "$cef_version" '
      .linux64.versions
      | map(select(.cef_version | startswith($version + "+")))
      | first
      | .cef_version as $full
      | .files[] | select(.type == "minimal")
      | [$full, .name, .sha1] | @tsv
    ' <<<"$cef_index"
  )
  if [[ -z $cef_name || -z $cef_sha1 ]]; then
    echo "Failed to find CEF $cef_version in the cef-builds index." >&2
    exit 1
  fi
  cef_git=${cef_full#*+g}
  cef_git=${cef_git%%+chromium-*}
  cef_chromium=${cef_full##*+chromium-}
  cef_sha256=$(nix store prefetch-file --hash-type sha256 --json \
    "https://cef-builds.spotifycdn.com/$cef_name" | jq -r '.hash')
  cef_json=$(jq -cn \
    --arg version "$cef_version" \
    --arg gitRevision "$cef_git" \
    --arg chromiumVersion "$cef_chromium" \
    --arg sha256 "$cef_sha256" \
    --arg archiveName "$cef_name" \
    --arg archiveSha1 "$cef_sha1" \
    '{
      version: $version,
      gitRevision: $gitRevision,
      chromiumVersion: $chromiumVersion,
      sha256: $sha256,
      archiveName: $archiveName,
      archiveSha1: $archiveSha1
    }')
fi

nix_build_hash \
  "(import ./pkgs {}).${package_name}.pnpmDeps.overrideAttrs (_: { outputHash = \"\"; outputHashAlgo = \"sha256\"; })" \
  "Dorion git deps"

jq -n \
  --arg version "$version" \
  --arg hash "$extracted_hash" \
  --arg sourceSha256 "$source_sha256" \
  --arg upstreamVersion "$upstream_version" \
  --argjson cef "$cef_json" \
  '{
    version: $version,
    hash: $hash,
    sourceSha256: $sourceSha256,
    upstreamVersion: $upstreamVersion,
    cef: $cef
  }' >"$src_info"
