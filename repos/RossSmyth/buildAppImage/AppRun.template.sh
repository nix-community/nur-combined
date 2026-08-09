#!/usr/bin/env bash
# Note that this cannot be rewritten to
# a Nix store path, as this program executes in the context
# of the unnamespaced mount, where a Nix store may not exist.

# The purpose of the bwrap is to mount a Nix store overlayfs,
# not for sandboxing.

readonly cwd="$(pwd)"
readonly appimage-location="$(dirname "$0")"

bwrapArgs=()
if [[ -d "@NIX_STORE@" ]]; then
  # If there is a store, then use it as the
  # overlay lowerdir
  bwrapArgs+=( "--overlay-src" "@NIX_STORE@" )
else
  # Else, just mount an empty tmpfs for the lowerdir
  bwrapArgs+=("--tmp-overlay" "@NIX_STORE@")
fi

# Should add "--not-a-security-boundary" once released
bwrapArgs+=("--" "$cwd/@EXECUTABLE_PATH@" "$@")

if command -v bwrap &> /dev/null; then
  # Since we have not mounted the nix-store yet, and we cannot
  # use anything from the store until it is, we must use the host's
  # bwrap
  echo "bwrap is not avaliable, please install and ensure it is on PATH"
  exit 1
fi

exec bwrap "${bwrapArgs[@]}"

