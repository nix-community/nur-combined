#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq ouch nodejs nix-update

set -Exeuo pipefail

TMPDIR="$(mktemp -d)"
cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

ROOT="$(dirname "$(readlink -f "$0")")"

BASE_URL="$1"
NAME="$2"
VERSION="$3"

latest_version=$(curl -s "${BASE_URL}" | jq -r '."dist-tags".latest')
if [ "${VERSION}" == "${latest_version}" ]; then
  echo "WARNING: no changes"
  exit 0
fi

pushd "${TMPDIR}"
latest_pkg="${NAME}-${latest_version}.tgz"
pkg_url="${BASE_URL}/-/${latest_pkg}";
curl -o "${latest_pkg}" "${pkg_url}"
ouch d "${latest_pkg}"
pushd package
npm install --ignore-scripts --package-lock-only
cp package-lock.json "${ROOT}/package-lock.json"

pushd "${ROOT}/../.."
nix-update "$NAME" --version="${latest_version}"
