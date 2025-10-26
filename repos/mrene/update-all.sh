#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update jq
# Update all packages using nix-update

set -euo pipefail

# Get list of all buildable package attributes
packages=$(nix-instantiate --eval --strict --json --expr 'import ./list-packages.nix {}' | jq -r '.[]')

echo "Found packages to update:"
echo "$packages"
echo

# Update each package
for pkg in $packages; do
  echo "========================================="
  echo "Updating: $pkg"
  echo "========================================="

  if nix-update --flake "$pkg"; then
    echo "✓ Successfully updated $pkg"
  else
    echo "✗ Failed to update $pkg (exit code: $?)"
  fi

  echo
done

echo "Update process complete!"
