#!/usr/bin/env bash
set -euo pipefail

# Allow unfree packages during this script
export NIXPKGS_ALLOW_UNFREE=1

attrs=(
  npupnp
  libupnpp
  upplay
  eezupnp
  betterbird-bin
  czkawka-git
  birt-designer
  beurer_bf100_parser
)

CACHIX_URL="https://thomas725.cachix.org"
CACHIX_KEY="thomas725.cachix.org-1:u/kJNXSESI2VZU+U9wt0bBXE9K/0dTmvEYi+pWKAXcc="

# Filter function: strip the '--add-root' warning from stderr
filter_add_root() {
  sed '/^warning: you did not specify.*--add-root/d'
}

# Wrapped nix-instantiate: filter stderr
ni() {
  nix-instantiate "$@" 2> >(filter_add_root >&2)
}

# Wrapped nix-store: filter stderr
ns() {
  nix-store "$@" 2> >(filter_add_root >&2)
}

for attr in "${attrs[@]}"; do
  echo "=== $attr ==="

  # Instantiate derivation (with warning stripped)
  drv=$(ni default.nix -A "$attr")

  # Expected output paths (without building), also with warning stripped
  out_paths=$(ns --query --outputs "$drv")

  cached_any=false

  for out in $out_paths; do
    if [ -d "$out" ]; then
      cached_any=true
      echo "  already present locally: $out"
    else
      echo "  trying to fetch from $CACHIX_URL only: $out"

      # Try to realise from your cache only, builders disabled.
      NIX_CONFIG="substituters = $CACHIX_URL
trusted-public-keys = $CACHIX_KEY
builders = " \
        ns --realise "$out" || true

      if [ -d "$out" ]; then
        cached_any=true
        echo "  fetched from cache: $out"
      else
        echo "  NOT CACHED: $out"
      fi
    fi
  done

  if [ "$cached_any" = false ]; then
    echo "  -> no outputs present or cached for $attr, skipping size"
    echo
    continue
  fi

  # Size reporting for outputs that exist
  for out in $out_paths; do
    if [ ! -d "$out" ]; then
      continue
    fi

    info=$(nix path-info -S "$out" | grep '^/nix/store/' || true)
    if [ -z "$info" ]; then
      echo "  (could not get size for $out)"
      continue
    fi

    bytes=$(echo "$info" | awk '{print $NF}')
    if ! [[ "$bytes" =~ ^[0-9]+$ ]]; then
      echo "  (size not numeric for $out: '$bytes')"
      continue
    fi

    mb=$(echo "scale=1; $bytes / 1024 / 1024" | bc)
    echo "  path:  $out"
    echo "  bytes: $bytes"
    echo "  size:  ${mb} MB"
  done

  echo
done