#!/usr/bin/env nix-shell
#!nix-shell -p sedutil jq -i bash

# shellcheck shell=bash

# This script fetches the latest versions for dtn7-go, both the master's HEAD as
# well as the last tagged release and automatically updates the dtn7-go package.
#
# When updating this script, please verify it via shellcheck.

set -euE

GITHUB_REPO="dtn7/dtn7-go"
PACKAGE="dtn7-go"


# calculatePackageSha REV
function calculatePackageSha {
  nix-prefetch-url --unpack \
    "https://github.com/${GITHUB_REPO}/archive/${1}.zip" 2>&1 | tail -n 1
}

# updatePackage FILE VERSION REV SHA256 MODSHA256
function updatePackageFile {
  cat > "$1" <<EOF
{ callPackage }:

callPackage ./. {
  version = "${2}";
  rev = "${3}";
  sha256 = "${4}";
  vendorSha256 = "${5}";
}
EOF
}

# calculateGoSha PACKAGE
function calculateGoSha {
  nix-build -A "$1" 2>&1 | sed -n 's/ *got: *\(sha256-.*\)/\1/p'
}

# updatePkg BRANCH (stable|unstable)
function updatePkg {
  local -r package_file="./pkgs/${PACKAGE}/${1}.nix"

  local -r local_rev="$(sed -n 's/ *rev = "\(.*\)\";/\1/p' "$package_file")"

  local remote_rev
  if [[ "$1" == "unstable" ]]; then
    remote_rev="$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/commits/HEAD" | jq -r '.sha?')"
  else
    remote_rev="$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/tags" | jq -r '.[0].name')"
  fi

  echo "[${1}] updating from ${local_rev} to ${remote_rev}"

  if [[ "${local_rev}" == "${remote_rev}" ]]; then
    echo "[${1}] there is nothing to do here"
    return
  fi

  local version
  if [[ "$1" == "unstable" ]]; then
    version="unstable-$(date +%Y-%m-%d)"
  else
    version="${remote_rev//v/}"
  fi
  local -r sha256="$(calculatePackageSha "${remote_rev}")"

  echo "[${1}] setting version to ${version} with checksum ${sha256}"

  updatePackageFile "$package_file" "$version" "$remote_rev" "$sha256" \
    "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

  local -r pkg_name="${PACKAGE}$([[ "$1" == "unstable" ]] && echo "-${1}")"
  local -r vendor_sha256="$(calculateGoSha "$pkg_name")"
  echo "[${1}] updating vendorSha256 to ${vendor_sha256}"

  updatePackageFile "$package_file" "$version" "$remote_rev" "$sha256" "$vendor_sha256"

  nix-build -A "$pkg_name"
}


updatePkg "unstable"
updatePkg "stable"
