#!/usr/bin/env bash
set -Eeuo pipefail

readarray -t roots < <(
  nix-store --gc --print-roots 2> >(grep --invert-match '^removing stale' >&2) \
  | grep --only-matching --perl-regexp '(?<=^").*(?=" ->)' \
  | sort
)

unexpected=()

for root in "${roots[@]}"; do
  case "$root" in
    '/nix/var/nix/profiles/'*|\
    '/proc/'*|\
    '/run/booted-system'|\
    '/run/current-system'|\
    "$HOME/.cache/nix/flake-registry.json"*|\
    "$HOME/.local/state/home-manager/gcroots/"*|\
    "$HOME/.local/state/nix/profiles/"*|\
    "$XDG_RUNTIME_DIR/direnv/layouts/"*)
      ;;

    "$HOME/.cache/direnv/layouts/"*)
      if [[ -n "$(find "$root" ! -newermt '30 days ago')" ]]; then
        printf '\e[2mPruning direnv layout: %s\e[22m\n' "${root%/*}" >&2
        rm --recursive "${root%/*}"
      fi
      ;;

    *)
      if [[ -n "$(find "$root" ! -newermt '1 day ago')" ]]; then
        unexpected+=("$root")
      fi
      ;;
  esac
done

if (( ${#unexpected[@]} > 0 )); then
  echo 'Unexpected GC roots:'

  for root in "${unexpected[@]}"; do
    modified="$(date --date "@$(stat --format '%W' "$root")" --iso-8601=minutes)"
    printf '  - %s\e[2m → %s (%s)\e[22m\n' "$root" "$(realpath "$root")" "$modified"
  done
fi
