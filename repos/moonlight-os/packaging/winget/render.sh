#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "usage: $0 vVERSION INSTALLER_SHA256 RELEASE_DATE OUTPUT_DIR" >&2
  exit 2
fi

tag="$1"
installer_sha256="$2"
release_date="$3"
output="$4"
version="${tag#v}"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+([+-][0-9A-Za-z.-]+)?$ ]]; then
  echo "invalid release tag: $tag" >&2
  exit 2
fi
if [[ ! "$installer_sha256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "invalid installer SHA-256: $installer_sha256" >&2
  exit 2
fi
if [[ ! "$release_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "invalid release date: $release_date" >&2
  exit 2
fi

mkdir -p "$output"
for template in "$here"/*.yaml.in; do
  destination="$output/$(basename "${template%.in}")"
  sed \
    -e "s/@VERSION@/$version/g" \
    -e "s/@INSTALLER_SHA256@/$installer_sha256/g" \
    -e "s/@RELEASE_DATE@/$release_date/g" \
    "$template" > "$destination"
done
