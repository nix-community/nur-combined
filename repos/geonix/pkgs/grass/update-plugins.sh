#!/usr/bin/env nix-shell
#! nix-shell -i bash -p python3Packages.lxml

# Update GRASS plugins.
# Usage: update-plugins.sh

set -Eeuo pipefail

version=$(nix eval --raw .#grass.version)
major_version=$(echo "$version" | awk -F "." '{print $1}')

PLUGINS_XML_URL="https://grass.osgeo.org/addons/grass${major_version}/modules.xml"

echo -e "\nUpdating GRASS plugins revision ..."
python ./update-plugins-rev.py > plugins-rev.nix

echo -e "\nUpdating GRASS plugins ..."
curl "$PLUGINS_XML_URL" -o plugins.xml

python ./update-plugins.py plugins.xml > plugins-list.nix.new
cp plugins-list.nix.new plugins-list.nix
rm plugins-list.nix.new
