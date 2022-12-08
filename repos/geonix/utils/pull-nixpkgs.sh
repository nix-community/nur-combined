#! /usr/bin/env bash

# Update package from nixpkgs master branch and show diff if any.
# Usage: pull-nixpkgs.sh <PACKAGE>

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
repo="https://github.com/NixOS/nixpkgs.git"
nixpkgs_dir="../nixpkgs"

declare -A nixpkgs_paths
nixpkgs_paths['gdal']='pkgs/development/libraries/gdal'
nixpkgs_paths['geos']='pkgs/development/libraries/geos'
nixpkgs_paths['libgeotiff']='pkgs/development/libraries/libgeotiff'
nixpkgs_paths['libspatialindex']='pkgs/development/libraries/libspatialindex'
nixpkgs_paths['libspatialite']='pkgs/development/libraries/libspatialite'
nixpkgs_paths['pdal']='pkgs/development/libraries/pdal'
nixpkgs_paths['proj']='pkgs/development/libraries/proj'
nixpkgs_paths['pyproj']='pkgs/development/python-modules/pyproj'


if [ ! -d "$nixpkgs_dir" ]; then
    echo "Cloning nixpkgs to $nixpkgs_dir ..."

    mkdir -pv $nixpkgs_dir
    git clone --depth 1 $repo $nixpkgs_dir
else
    echo "Updating nixpkgs in $nixpkgs_dir ..."
    git -C "$nixpkgs_dir" checkout master
    git -C "$nixpkgs_dir" pull
fi

echo -e "\nPulling $1 ..."
cp -v $nixpkgs_dir/${nixpkgs_paths[$1]}/* pkgs/$1/

echo
git diff -- pkgs/$1
