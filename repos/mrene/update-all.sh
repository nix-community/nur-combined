#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update jq yarn-berry_4.yarn-berry-fetcher
# Update packages with nix-update, build them, and commit each bump with jj
# using nixpkgs-style messages ("pkg: old -> new").
#
# Usage: ./update-all.sh [attr...]
#   No arguments: update flake.lock first, then every buildable package.
#   With attrs: update only those packages, against the current flake.lock.
#
# Per-package nix-update flags come from the nixpkgs convention:
#   passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
# Set `passthru.updateScript = null;` to opt a package out.
# Vendored dependencies exposed through `passthru` are updated before the
# package using them; if that package then fails, their commits are abandoned.
# yarn-berry packages with a `missingHashes` file in the repo get it regenerated.
# See update-plan.nix for what gets skipped.

set -euo pipefail
cd "$(dirname "$0")"
# nix-update shells out to its own nix-instantiate, which needs flakes for --flake.
export NIX_CONFIG="extra-experimental-features = nix-command flakes${NIX_CONFIG:+
$NIX_CONFIG}"

if [ -n "$(jj diff --name-only)" ]; then
  echo "Working copy has uncommitted changes; commit or restore them first." >&2
  exit 1
fi

msg_file=$(mktemp)
trap 'rm -f "$msg_file"' EXIT

if [ $# -eq 0 ]; then
  echo "=== flake.lock"
  nix flake update 2>&1 | tee "$msg_file"
  if [ -n "$(jj diff --name-only)" ]; then
    jj commit -m "$(printf 'flake.lock: update\n\n'; grep -E "^(•|  +['→])" "$msg_file")"
  fi
fi

plan=$(nix-instantiate --eval --strict --json ./update-plan.nix --argstr attrs "$*")

updated=()
unchanged=()
failed=()
skipped=()
# Vendored dependency commits waiting on their parent package to build.
dep_changes=()
dep_subjects=()

# Recompute dependency hashes (cargoHash, mvnHash, offlineCache, ...) without
# touching the version or src. nix-update only does this with --version=skip,
# which must come after the package's own args to override e.g. --version=branch.
refresh_deps() {
  nix-update --flake --build --no-src "${args[@]}" --version=skip "$attr"
}

# nix-update for the current entry. yarn-berry packages get their missingHashes
# regenerated between the source bump and the dependency hash update.
update_pkg() {
  if [ -z "$missing" ]; then
    nix-update --flake --build --write-commit-message "$msg_file" "${args[@]}" "$attr" && return
    # Without a version change nix-update leaves dependency hashes alone, but
    # they can drift after a nixpkgs bump; refresh them once.
    [ -z "$(jj diff --name-only)" ] || return
    echo "--- $attr: build failed without a version change, refreshing dependency hashes"
    refresh_deps
    return
  fi
  nix-update --flake --src-only --write-commit-message "$msg_file" "${args[@]}" "$attr" || return
  local src
  src=$(nix build --no-link --print-out-paths ".#$attr.src") || return
  yarn-berry-fetcher missing-hashes "$src/yarn.lock" >"$missing" || return
  refresh_deps
}

while read -r entry; do
  attr=$(jq -r .attr <<<"$entry")
  parent=$(jq -r '.parent // empty' <<<"$entry")
  skip=$(jq -r '.skip // empty' <<<"$entry")
  if [ -n "$skip" ]; then
    echo "--- $attr: skipped ($skip)"
    skipped+=("$attr ($skip)")
    continue
  fi
  missing=$(jq -r '.missingHashes // empty' <<<"$entry")
  mapfile -t args < <(jq -r '.args[]' <<<"$entry")

  echo "=== $attr ${args[*]}"
  : >"$msg_file"
  if update_pkg; then
    ok=1
  else
    ok=0
    echo "!!! $attr: update failed, restoring working copy"
    jj restore
    failed+=("$attr")
  fi

  if [ "$ok" = 1 ]; then
    if [ -z "$(jj diff --name-only)" ]; then
      unchanged+=("$attr")
    else
      # nix-update leaves the message empty when only hashes changed.
      [ -s "$msg_file" ] || echo "$attr: refresh dependency hashes" >"$msg_file"
      jj commit -m "$(cat "$msg_file")"
      subject=$(head -n1 "$msg_file")
      if [ -n "$parent" ]; then
        dep_changes+=("$(jj log --no-graph -r @- -T change_id)")
        dep_subjects+=("$subject")
      else
        updated+=("$subject")
      fi
    fi
  fi

  if [ -z "$parent" ] && [ ${#dep_changes[@]} -gt 0 ]; then
    if [ "$ok" = 1 ]; then
      updated+=("${dep_subjects[@]}")
    else
      echo "!!! $attr: abandoning its vendored dependency updates"
      jj abandon "${dep_changes[@]}"
      for s in "${dep_subjects[@]}"; do failed+=("$s (abandoned: $attr failed)"); done
    fi
    dep_changes=()
    dep_subjects=()
  fi
done < <(jq -c '.[]' <<<"$plan")

summary() {
  local title=$1
  shift
  echo "$title ($#):"
  [ $# -eq 0 ] || printf '  %s\n' "$@"
}

echo
summary Updated "${updated[@]}"
summary Unchanged "${unchanged[@]}"
summary Skipped "${skipped[@]}"
summary Failed "${failed[@]}"

[ ${#failed[@]} -eq 0 ]
