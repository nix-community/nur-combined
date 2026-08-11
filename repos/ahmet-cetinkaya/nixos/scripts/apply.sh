#!/usr/bin/env bash

set -euo pipefail

## Apply NixOS flake configuration for a given host

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIXOS_DIR="$(dirname "$SCRIPT_DIR")"

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

sudo nixos-rebuild switch --flake "$NIXOS_DIR#$HOST"

echo "✨ NixOS flake applied successfully!"
