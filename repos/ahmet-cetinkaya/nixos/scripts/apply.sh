#!/usr/bin/env bash

set -euo pipefail

## Apply NixOS flake configuration for a given host

# Use NIXOS_CONFIG_DIR if set (from Nix wrapper), otherwise resolve from script location
if [ -n "${NIXOS_CONFIG_DIR:-}" ]; then
    NIXOS_DIR="$NIXOS_CONFIG_DIR"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    NIXOS_DIR="$(dirname "$SCRIPT_DIR")"
fi

# Function to display usage
usage() {
	echo "Usage: $0 <host>"
	echo ""
	echo "Apply NixOS flake configuration for the specified host."
	echo ""
	echo "Examples:"
	echo "  $0 karakiz"
	echo "  $0 myhost"
	exit 1
}

# Check if exactly one non-empty host argument is provided
if [[ $# -ne 1 || -z "$1" ]]; then
	echo "Error: Exactly one host argument is required."
	echo ""
	usage
fi

HOST="$1"

echo "🔧 Applying NixOS flake for ${HOST}..."

sudo nixos-rebuild switch \
	--option extra-substituters "https://cache.nixos-cuda.org" \
	--option extra-trusted-public-keys "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" \
	--flake "$NIXOS_DIR#$HOST"

echo "✨ NixOS flake applied successfully!"
