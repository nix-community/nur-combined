#!/usr/bin/env nix-shell
#!nix-shell -p sedutil jq -i bash

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
  cat > $1 <<EOF
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
  nix-build -A $1 2>&1 | sed -n 's/ *got: *sha256:\(.*\)/\1/p'
}

function updateLastCommit {
  local package_file="./pkgs/${PACKAGE}/unstable.nix"

  local local_commit=`sed -n 's/ *rev = "\(.*\)\";/\1/p' $package_file`
  local remote_commit=`curl -s "https://api.github.com/repos/${GITHUB_REPO}/commits/HEAD" | jq -r '.sha?'`

  echo "[commit] updating from ${local_commit} to ${remote_commit}"

  if [[ "${local_commit}" == "${remote_commit}" ]]; then
    echo "[commit] there are no new commits, abort"
    return
  fi

  local version="unstable-`date +%Y-%m-%d`"
  local sha256=`calculatePackageSha "${remote_commit}"`

  echo "[commit] setting version to ${version} with checksum ${sha256}"

  updatePackageFile $package_file $version $remote_commit $sha256 \
    "0000000000000000000000000000000000000000000000000000"

  local vendor_sha256=`calculateGoSha "${PACKAGE}-unstable"`
  echo "[commit] updating vendorSha256 to ${vendor_sha256}"

  updatePackageFile $package_file $version $remote_commit $sha256 $vendor_sha256

  nix-build -A "${PACKAGE}-unstable"
}

function updateLastTag {
  local package_file="./pkgs/${PACKAGE}/stable.nix"

  local local_rev=`sed -n 's/ *rev = "\(.*\)\";/\1/p' $package_file`
  local remote_rev=`curl -s "https://api.github.com/repos/${GITHUB_REPO}/tags" | jq -r '.[0].name'`

  echo "[tag] updating from ${local_rev} to ${remote_rev}"

  if [[ "${local_rev}" == "${remote_rev}" ]]; then
    echo "[tag] there is no new release, abort"
    return
  fi

  local version=`echo "$remote_rev" | sed 's/^v//'`
  local sha256=`calculatePackageSha "${remote_rev}"`

  echo "[tag] setting version to ${version} with checksum ${sha256}"

  updatePackageFile $package_file $version $remote_rev $sha256 \
    "0000000000000000000000000000000000000000000000000000"

  local vendor_sha256=`calculateGoSha "$PACKAGE"`
  echo "[tag] updating vendorSha256 to ${vendor_sha256}"

  updatePackageFile $package_file $version $remote_rev $sha256 $vendor_sha256

  nix-build -A "$PACKAGE"
}


updateLastCommit
updateLastTag
