#!/usr/bin/env bash

set -euo pipefail

sources_file="$PWD/pkgs/ab-download-manager/sources.json"
repository="amir1376/ab-download-manager"
requested_version="${1:-}"

if [[ ! -f "$sources_file" ]]; then
  echo "error: run this command from the NUR repository root" >&2
  exit 1
fi

if [[ -n "$requested_version" ]]; then
  requested_version="${requested_version#v}"
  api_url="https://api.github.com/repos/$repository/releases/tags/v$requested_version"
else
  api_url="https://api.github.com/repos/$repository/releases/latest"
fi

release_json="$(
  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --header "Accept: application/vnd.github+json" \
    "$api_url"
)"

tag="$(jq --exit-status --raw-output ".tag_name" <<<"$release_json")"
version="${tag#v}"

source_hash() {
  local arch="$1"
  local asset="ABDownloadManager_${version}_linux_${arch}.tar.gz"
  local digest
  local download_url

  digest="$(
    jq \
      --exit-status \
      --raw-output \
      --arg asset "$asset" \
      '.assets[] | select(.name == $asset) | .digest // empty' \
      <<<"$release_json" || true
  )"

  if [[ "$digest" == sha256:* ]]; then
    nix hash convert \
      --hash-algo sha256 \
      --to sri \
      "${digest#sha256:}"
    return
  fi

  download_url="$(
    jq \
      --exit-status \
      --raw-output \
      --arg asset "$asset" \
      '.assets[] | select(.name == $asset) | .browser_download_url' \
      <<<"$release_json"
  )"

  nix store prefetch-file --json "$download_url" | jq --raw-output ".hash"
}

x64_hash="$(source_hash "x64")"
arm64_hash="$(source_hash "arm64")"
temporary_file="$(mktemp "$PWD/.sources.json.XXXXXX")"
trap 'rm -f "$temporary_file"' EXIT

jq \
  --null-input \
  --arg version "$version" \
  --arg x64_hash "$x64_hash" \
  --arg arm64_hash "$arm64_hash" \
  '{
    version: $version,
    sources: {
      "x86_64-linux": {
        arch: "x64",
        hash: $x64_hash
      },
      "aarch64-linux": {
        arch: "arm64",
        hash: $arm64_hash
      }
    }
  }' >"$temporary_file"

mv "$temporary_file" "$sources_file"
trap - EXIT

echo "Updated AB Download Manager to v$version"
