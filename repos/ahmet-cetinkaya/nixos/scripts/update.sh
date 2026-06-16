#!/usr/bin/env bash

set -euo pipefail

## Update custom pkgs and flake inputs

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGS_DIR="$(dirname "$SCRIPT_DIR")/pkgs"
NIXOS_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
	echo "Usage: $0"
	echo ""
	echo "Update custom pkgs and flake inputs."
	echo ""
	echo "This script:"
	echo "  1. Runs update.sh for each custom package"
	echo "  2. Runs nix flake update"
	exit 1
}

update_pkg() {
	local pkg_dir="$1"
	local pkg_name
	pkg_name="$(basename "$pkg_dir")"
	echo "⬆️  Updating ${pkg_name}..."
	if [ -f "${pkg_dir}/update.sh" ]; then
		(cd "$pkg_dir" && ./update.sh)
	else
		echo "⚠️  Warning: update.sh not found for ${pkg_name}, skipping"
	fi
}

echo -e "\n📦 Updating custom pkgs..."
for pkg_dir in "${PKGS_DIR}"/*/; do
    [ -f "${pkg_dir}/update.sh" ] && update_pkg "$pkg_dir"
done

echo -e "\n🔄 Running nix flake update..."
(cd "$NIXOS_DIR" && nix flake update)

echo -e "\n✅ Update completed successfully!"
