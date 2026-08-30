#!/usr/bin/env bash
set -euo pipefail

pname="nmssaveeditor"
upstream="goatfungus/NMSSaveEditor"
pkg_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nix_file="$pkg_dir/default.nix"
original_nix_file="$(mktemp)"
trap 'rm -f "$original_nix_file"' EXIT
cp "$nix_file" "$original_nix_file"

for command in cmp cp curl jq nix perl; do
  if ! command -v "$command" >/dev/null; then
    echo "Required command not found: $command" >&2
    exit 1
  fi
done

curl_args=(--fail --location --retry 3 --silent --show-error)
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_args+=(--header "Authorization: Bearer $GITHUB_TOKEN")
fi

revision="$(
  curl "${curl_args[@]}" "https://api.github.com/repos/$upstream/commits/master" \
    | jq --raw-output --exit-status '.sha'
)"
version="$(
  curl "${curl_args[@]}" \
    "https://raw.githubusercontent.com/$upstream/$revision/VERSION.txt" \
    | tr -d '\r\n'
)"

if [[ ! "$revision" =~ ^[0-9a-f]{40}$ ]]; then
  echo "Invalid upstream revision: $revision" >&2
  exit 1
fi

if [[ ! "$version" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
  echo "Invalid upstream version: $version" >&2
  exit 1
fi

jar_url="https://github.com/$upstream/raw/$revision/NMSSaveEditor.jar"
jar_hash="$(nix store prefetch-file --json "$jar_url" | jq --raw-output --exit-status '.hash')"

for hash in "$jar_hash"; do
  if [[ ! "$hash" =~ ^sha256-[A-Za-z0-9+/=]+$ ]]; then
    echo "Invalid NAR hash: $hash" >&2
    exit 1
  fi
done

perl -0pi -e 's/(version = ")[^"]+(";)/${1}'"$version"'${2}/' "$nix_file"
perl -0pi -e 's#(NMSSaveEditor/raw/)[0-9a-f]{40}(/NMSSaveEditor\.(?:jar|exe))#${1}'"$revision"'${2}#g' "$nix_file"
perl -0pi -e 's|(NMSSaveEditor\.jar";\n    hash = ")[^"]+(";\n  };)|${1}'"$jar_hash"'${2}|' "$nix_file"

if cmp -s "$original_nix_file" "$nix_file"; then
  echo "$pname is up to date ($version, $revision)"
else
  echo "Updated $pname to $version ($revision)"
fi
