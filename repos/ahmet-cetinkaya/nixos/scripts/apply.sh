#!/usr/bin/env bash

set -euo pipefail

## Apply NixOS flake configuration for a given host

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

# Check if host argument is provided
if [ $# -lt 1 ]; then
	echo "Error: Host argument is required."
	echo ""
	usage
fi

HOST="$1"

echo "🔧 Applying NixOS flake for ${HOST}..."

sudo nixos-rebuild switch --flake .#"${HOST}"

echo "✨ NixOS flake applied successfully!"
