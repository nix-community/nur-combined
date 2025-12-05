#!/usr/bin/env bash
:

# shellcheck source=packages/shellvaculib/shellvaculib.bash
source shellvaculib.bash || exit 1

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
trap '
if [[ -d $tmpdir ]]; then
  rm -rf "$tmpdir"
fi
' EXIT
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
  declare update_by_default=true
  declare -a extra_update_args=()
  declare -a names=()
  while (( $# > 0 )); do
    declare arg="$1"
    shift 1
    case "$arg" in
      --no-default)
        update_by_default=false
        ;;
      --branch)
        extra_update_args+=(--version=branch)
        ;;
      --version-regex=*)
        extra_update_args+=("$arg")
        ;;
      --)
        names+=("$@")
        shift $#
        ;;
      -*)
        svl_die "Unrecognized arg $arg"
        ;;
      *)
        names+=("$arg")
        ;;
    esac
  done
  if [[ $# != 0 ]]; then
    svl_throw "this shouldnt happen"
  fi
  if [[ ${#names[@]} == 0 ]]; then
    svl_throw "must provide at least one non-dashed arg"
  fi
  declare primary_name="${names[0]}"
  if svl_in_array "$what" "${names[@]}" || [[ -z $what && $update_by_default == true ]]; then
    nix_common run '.#stable.nix-update' -- "$primary_name" --flake --write-commit-message "$commit_message_path" "${extra_update_args[@]}"
    if ! git diff --quiet --exit-code HEAD -- packages/"$primary_name"; then
      declare flake_path
      flake_path="$(printf '.#"%q"' "$primary_name")"
      nix_common build "$flake_path" --no-link
      v git commit --file="$commit_message_path" -- packages/"$primary_name"
      unset flake_path
    fi

    remove_commit_message
  fi
  unset primary_name
  unset names
}

standard_package --branch dufs-vacu dufs

standard_package genieacs genie

standard_package --no-default openterface-qt openterface

standard_package --branch transferwee

standard_package --version-regex='z3-(.*)' z3
