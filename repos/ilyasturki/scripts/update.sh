#!/usr/bin/env bash
#
# Bump every package in pkgs/ to its latest upstream revision: rewrite the
# version, rev and source hash in place, then leave the result in the working
# tree. Building and verifying is CI's job, not this script's.
#
# Usage:
#   nix develop --command ./scripts/update.sh              # all packages
#   ONLY=citron-neo nix develop --command ./scripts/update.sh

set -uo pipefail

REPO_ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
cd "$REPO_ROOT" || exit 1

ONLY="${ONLY:-}"
MATCHED=0
declare -a BUMPED=() UPTODATE=() FAILED=()

# This log becomes the update PR's body, where escapes would be literal.
if [ -t 1 ]; then BOLD=$'\033[1m' RESET=$'\033[0m'; else BOLD='' RESET=''; fi

hdr() { printf '\n%s==> %s%s\n' "$BOLD" "$*" "$RESET"; }
log() { printf '    %s\n' "$*"; }
want() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }

# Metachar-safe literal in-place replace. An empty OLD would match at every
# position and splice NEW between every character, so refuse it: read_attr
# returns empty whenever upstream moves the text an anchor keys on.
replace() { # <file> <old> <new>
  [ -n "$2" ] || {
    log "refusing to replace the empty string in $1"
    return 1
  }
  OLD="$2" NEW="$3" perl -i -0777 -pe 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "$1"
}

# <anchor> starts the search. Both git-HEAD packages vendor a second derivation
# -- nx-optimizer a Python wheel, citron-neo the tzdb archive -- whose version
# and hash sit above the ones being bumped and would match first.
read_attr() { # <file> <attr> [anchor]
  ANCHOR="${3:-}" ATTR="$2" perl -0777 -ne 'print $1 if /\Q$ENV{ANCHOR}\E.*?\b\Q$ENV{ATTR}\E = "([^"]+)"/s' "$1"
}

prefetch() { # <url> <rev> [--fetch-submodules] -> SRI hash
  nix-prefetch-git --url "$1" --rev "$2" ${3:+"$3"} --quiet 2>/dev/null \
    | jq -r '.hash // empty'
}

prefetch_url() { # <url> -> SRI hash
  local base32
  base32="$(nix-prefetch-url --type sha256 "$1" 2>/dev/null)" || return 1
  [ -n "$base32" ] || return 1
  nix hash convert --hash-algo sha256 --to sri "$base32"
}

# Anonymous api.github.com allows 60 requests/hour per IP, and CI runners share
# egress IPs with every other job on the fleet.
declare -a GH_AUTH=()
[ -z "${GITHUB_TOKEN:-}" ] || GH_AUTH=(-H "Authorization: Bearer $GITHUB_TOKEN")

gh_api() { # <url> -> JSON
  curl -sS --max-time 30 "${GH_AUTH[@]}" "$1"
}

latest_release() { # <owner/repo> -> release JSON
  gh_api "https://api.github.com/repos/$1/releases/latest"
}

# --- ryujinx-canary ---------------------------------------------------------
# Canary and stable share the projects/Ryubing repo and differ by tag prefix.

update_ryujinx_canary() {
  local file=pkgs/ryujinx-canary/package.nix old new hash
  old="$(read_attr "$file" version)"
  new="$(curl -sS --max-time 30 'https://git.ryujinx.app/api/v1/repos/projects/Ryubing/tags?limit=50' \
    | jq -r '[.[] | select(.name | startswith("Canary-"))][0].name' | sed 's/^Canary-//')"
  [ -n "$new" ] && [ "$new" != null ] || { log "could not read tags"; return 1; }

  log "$old -> $new"
  [ "$old" = "$new" ] && return 2

  hash="$(prefetch https://git.ryujinx.app/projects/Ryubing "refs/tags/Canary-$new")"
  [ -n "$hash" ] || { log "prefetch failed"; return 1; }

  replace "$file" "$old" "$new" || return 1
  replace "$file" "$(read_attr "$file" hash)" "$hash" || return 1

  # The NuGet lockfile is not fetchable: it comes out of a build. Regenerating
  # it is the one step here that needs the whole .NET restore.
  log "regenerating deps.json ..."
  local script
  script="$(nix build --no-link --print-out-paths '.#ryujinx-canary.fetch-deps' 2>/dev/null)" || {
    log "fetch-deps build failed"; return 1;
  }
  "$script" "$REPO_ROOT/pkgs/ryujinx-canary/deps.json" >/dev/null 2>&1 || {
    log "fetch-deps run failed"; return 1;
  }
}

# --- pcsx2 ------------------------------------------------------------------
# nixpkgs tracks the same tags but has sat on 2.6.3 since 2026; the game patch
# database moves on its own schedule and is bumped whether or not it has.

update_pcsx2() {
  local file=pkgs/pcsx2/package.nix old new hash moved=2
  local old_patches new_patches patches_hash

  new="$(latest_release PCSX2/pcsx2 | jq -r '.tag_name // empty' | sed 's/^v//')"
  [ -n "$new" ] || { log "could not read release"; return 1; }
  old="$(read_attr "$file" version 'pname = "pcsx2"')"

  log "pcsx2      $old -> $new"
  if [ "$old" != "$new" ]; then
    hash="$(prefetch https://github.com/PCSX2/pcsx2 "refs/tags/v$new")"
    [ -n "$hash" ] || { log "prefetch failed"; return 1; }
    replace "$file" "$(read_attr "$file" hash 'repo = "pcsx2"')" "$hash" || return 1
    replace "$file" "$old" "$new" || return 1
    moved=0
  fi

  new_patches="$(gh_api https://api.github.com/repos/PCSX2/pcsx2_patches/commits/main | jq -r '.sha // empty')"
  [ -n "$new_patches" ] || { log "could not read pcsx2_patches HEAD"; return 1; }
  old_patches="$(read_attr "$file" rev 'repo = "pcsx2_patches"')"

  log "patches    ${old_patches:0:9} -> ${new_patches:0:9}"
  if [ "$old_patches" != "$new_patches" ]; then
    patches_hash="$(prefetch https://github.com/PCSX2/pcsx2_patches "$new_patches")"
    [ -n "$patches_hash" ] || { log "prefetch failed"; return 1; }
    replace "$file" "$(read_attr "$file" hash "rev = \"$old_patches\"")" "$patches_hash" || return 1
    replace "$file" "$old_patches" "$new_patches" || return 1
    moved=0
  fi

  return $moved
}

# --- SD card payloads -------------------------------------------------------
# Release assets, not git tags. The filename carries versions of bundled pieces
# -- hbl, hbmenu, Nyx -- that do not follow from the tag, so it is stored as its
# own attribute and read back from the release rather than derived.

update_release_asset() { # <file> <owner/repo> <asset-jq-filter> [extra-asset]
  local file="$1" repo="$2" filter="$3" extra="${4:-}"
  local json tag ver old_ver asset old_asset hash extra_hash

  json="$(latest_release "$repo")"
  tag="$(jq -r '.tag_name // empty' <<<"$json")"
  asset="$(jq -r "$filter" <<<"$json")"
  [ -n "$tag" ] && [ -n "$asset" ] || { log "could not read release"; return 1; }

  ver="${tag#v}"
  old_ver="$(read_attr "$file" version)"
  log "$old_ver -> $ver ($asset)"
  [ "$old_ver" = "$ver" ] && return 2

  local base="https://github.com/$repo/releases/download/$tag"
  hash="$(prefetch_url "$base/$asset")" || { log "prefetch failed"; return 1; }
  [ -z "$extra" ] || extra_hash="$(prefetch_url "$base/$extra")" || { log "prefetch failed"; return 1; }

  old_asset="$(read_attr "$file" asset)"
  replace "$file" "$old_asset" "$asset" || return 1
  replace "$file" "$old_ver" "$ver" || return 1
  replace "$file" "$(read_attr "$file" hash 'src = fetchurl')" "$hash" || return 1
  [ -z "$extra" ] || replace "$file" "$(read_attr "$file" hash "${extra%%.*} = fetchurl")" "$extra_hash" || return 1
}

# --- git-HEAD packages ------------------------------------------------------
# Both track a branch rather than releases, so the version is a date stamp in
# nixpkgs' `<last release>-unstable-<date>` form.

update_github_head() { # <pname> <file> <owner/repo> <branch> <version-prefix> [--fetch-submodules]
  local pname="$1" file="$2" repo="$3" branch="$4" prefix="$5" submodules="${6:-}"
  local json rev date old_rev old_ver new_ver hash

  json="$(gh_api "https://api.github.com/repos/$repo/commits/$branch")"
  rev="$(jq -r '.sha // empty' <<<"$json")"
  date="$(jq -r '.commit.committer.date // empty' <<<"$json" | cut -dT -f1)"
  [ -n "$rev" ] && [ -n "$date" ] || { log "could not read HEAD"; return 1; }

  old_rev="$(read_attr "$file" rev)"
  log "${old_rev:0:9} -> ${rev:0:9} ($date)"
  [ "$old_rev" = "$rev" ] && return 2

  hash="$(prefetch "https://github.com/$repo" "$rev" ${submodules:+"$submodules"})"
  [ -n "$hash" ] || { log "prefetch failed"; return 1; }

  old_ver="$(read_attr "$file" version "pname = \"$pname\"")"
  new_ver="$prefix-unstable-$date"
  [ -n "$old_ver" ] || { log "could not read version"; return 1; }

  replace "$file" "$old_rev" "$rev" || return 1
  replace "$file" "$old_ver" "$new_ver" || return 1
  replace "$file" "$(read_attr "$file" hash "rev = \"$rev\"")" "$hash" || return 1
}

# --- driver -----------------------------------------------------------------

run() { # <name> <function...>
  want "$1" || return 0
  MATCHED=1
  hdr "$1"
  local name="$1"
  shift
  "$@"
  case $? in
    0) BUMPED+=("$name") ;;
    2) UPTODATE+=("$name"); log "already up to date" ;;
    *) FAILED+=("$name"); git checkout -- "pkgs/$name" 2>/dev/null ;;
  esac
}

run atmosphere update_release_asset pkgs/atmosphere/package.nix \
  Atmosphere-NX/Atmosphere '[.assets[].name | select(endswith(".zip"))][0] // empty' fusee.bin
run citron-neo update_github_head citron-neo pkgs/citron-neo/package.nix \
  citron-neo/emulator main 0 --fetch-submodules
run hekate update_release_asset pkgs/hekate/package.nix \
  CTCaer/hekate '[.assets[].name | select(test("_Nyx_.*\\.zip$"))][0] // empty'
run nx-optimizer update_github_head nx-optimizer pkgs/nx-optimizer/package.nix \
  MaxLastBreath/nx-optimizer main 3.3.0
run panda3ds update_github_head panda3ds pkgs/panda3ds/package.nix \
  wheremyfoodat/Panda3DS master 0.9 --fetch-submodules
run pcsx2 update_pcsx2
run ryujinx-canary update_ryujinx_canary

# Without this a typo in ONLY skips every package and still summarises success.
[ -z "$ONLY" ] || [ "$MATCHED" = 1 ] || {
  hdr "error"
  log "unknown package: $ONLY"
  exit 1
}

hdr "summary"
log "bumped:    ${BUMPED[*]:-none}"
log "unchanged: ${UPTODATE[*]:-none}"
log "failed:    ${FAILED[*]:-none}"
[ ${#FAILED[@]} -eq 0 ]
