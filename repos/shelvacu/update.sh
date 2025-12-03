#!/usr/bin/env bash
source shellvaculib.bash

function v() {
  declare -a cmd=("$@")
  declare -p cmd >&2
  "${cmd[@]}"
}

function nix_common() {
  v nix --show-trace -L -v "$@"
}

svl_assert_probably_in_script_dir

what="${1-}"

function assert_no_changes() {
  svl_max_args $# 1
  declare msg="${1-expected no changes in working tree}"
  if ! git diff --quiet --exit-code HEAD; then
    svl_die "$msg"
  fi
}

assert_no_changes "there must be no changes in working tree to run this"

tmpdir="$(mktemp -d)"
trap '[[ -d $tmpdir ]] && rm -rf "$tmpdir"' EXIT
commit_message_path="$tmpdir/commit_message.txt"

function remove_commit_message() {
  if [[ -f $commit_message_path ]]; then
    rm -- "$commit_message_path"
  fi
}

if [[ $what == 'flake' ]] || [[ -z $what ]]; then
  v nix flake update
  if ! git diff --quiet --exit-code HEAD -- flake.lock; then
    v git commit -m 'nix flake update' -- flake.lock
  fi
fi

if [[ $what == 'units' ]] || [[ -z $what ]]; then
  assert_no_changes
  declare units_path="$tmpdir/units_path"
  v nix build '.#stable.units' --out-link "$units_path"
  v "$units_path/bin/units_cur" --verbose units/currency.units units/cpi.units
  declare version_string
  version_string="$("$units_path/bin/units" --version | head -n 1)"
  declare cmc_api_key
  cmc_api_key="$(v nix run '.#sops' -- decrypt --extract '["key"]' secrets/misc/coinmarketcap-key.yaml)"
  CMC_API_KEY="$cmc_api_key" v nix run '.#get-crypto-rates' -- -f units/cryptocurrencies.units
  unset cmc_api_key
  if ! git diff --quiet --exit-code HEAD; then
    declare -a cmd=(
      git
      commit
      --message "units: update currency data"
      --message "Auto-update by <nix-stuff>/update.sh"
      --message "Used $version_string"
      --
      ./units
    )
    v "${cmd[@]}"
    unset cmd
  fi
  unset version_string
  rm "$units_path"
  unset units_path
  assert_no_changes
fi

function standard_package() {
  svl_min_args $# 1
  declare -a names=("$@")
  declare primary_name="${names[0]}"
  if svl_in_array "$what" "${names[@]}" || [[ -z $what ]]; then
    declare -a extra_update_args=()
    if svl_in_array "$primary_name" bandcamp-collection-downloader transferwee dufs-vacu; then
      extra_update_args+=(--version=branch)
    fi
    if [[ $primary_name == z3 ]]; then
      extra_update_args+=(--version-regex='z3-(.*)')
    fi
    nix_common run '.#stable.nix-update' -- "$primary_name" --flake --write-commit-message "$commit_message_path" "${extra_update_args[@]}"
    if ! git diff --quiet --exit-code HEAD -- packages/"$primary_name"; then
      declare flake_path
      flake_path="$(printf '.#"%q"' "$primary_name")"
      if [[ $primary_name == bandcamp-collection-downloader ]]; then
        declare mitmUpdate
        mitmUpdate="$(nix_common build '.#bandcamp-collection-downloader.mitmCache.updateScript' --no-link --print-out-paths)"
        v "$mitmUpdate"
      fi
      nix_common build "$flake_path" --no-link
      v git commit --file="$commit_message_path" -- packages/"$primary_name"
      unset flake_path
    fi

    remove_commit_message
  fi
  unset primary_name
  unset names
}

standard_package dufs-vacu dufs

standard_package genieacs genie

standard_package openterface-qt openterface

standard_package transferwee

standard_package z3
