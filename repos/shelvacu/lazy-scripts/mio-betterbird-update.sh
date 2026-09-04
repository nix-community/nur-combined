#!/usr/bin/env bash

# shellcheck source=../packages/shellvaculib/shellvaculib.bash
source shellvaculib.bash || exit 1

svl_no_args $#

if ! command -v cachix >/dev/null; then
  svl_die "no 'cachix' in path"
fi

declare flake_uri_unlocked="github:mio-19/nurpkgs"
declare system="x86_64-linux"

declare tempdir=
tempdir=$(mktemp -d --suffix=-vacu-mio-betterbird-update)

declare -i exit_code=-1
trap 'exit_code=$?; rm -rf -- "$tempdir" || true; exit $exit_code' EXIT

cd -- "$tempdir"

declare json_data=
json_data=$(nix flake metadata --json -- "$flake_uri_unlocked")

declare flake_uri=
flake_uri=$(jq -r .url <<<"$json_data")
declare git_revision=
git_revision=$(jq -r .revision <<<"$json_data")

declare flake_packages="$flake_uri#.packages.$system"

svl_verbose_run nix build -j1 -v -L --out-link result-sources -- "$flake_packages.betterbird-unwrapped".{src,betterbird-patches,comm-source}

svl_verbose_run into-nix-cache ./result-sources*

svl_verbose_run nix build -v -L --out-link result-bb -- "$flake_packages.betterbird"

svl_verbose_run into-nix-cache ./result-bb*

declare drv_name=""
drv_name="$(nix eval --raw -- "$flake_packages.betterbird.name")"
declare pin_name="$drv_name:nurpkgs-$git_revision"

svl_verbose_run cachix push mio ./result-bb*
svl_verbose_run cachix pin mio "$pin_name" ./result-bb*
