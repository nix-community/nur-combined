#!/usr/bin/env nix-shell
#!nix-shell -i sh -p nodejs nodePackages.node2nix

# Switch to scripts directory
cd $(dirname $0)

# Update chalet dependency
npm update

# Drop the node modules folder
rm -rf node_modules/

# Generate new nix files
node2nix -l
