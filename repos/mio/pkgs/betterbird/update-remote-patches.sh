#!/usr/bin/env bash
set -euo pipefail

script_path="$(readlink -f -- "$0")"
script_dir="$(dirname -- "$script_path")"
cd -- "$script_dir"

td="$(mktemp -d)"
trap 'exit_code=$?; rm -rf -- "$td" || true; exit $?' EXIT

nix build .#betterbird-unwrapped.betterbird-patches --out-link "$td/betterbird-patches"

full_series_text="$(cat "$td/betterbird-patches/140/"{series,series-moz})"
declare -a series_lines=()
mapfile -t series_lines <<<"$full_series_text"

trim_var() {
  declare -n var_ref="$1"
  # remove leading whitespace characters
  var_ref="${var_ref#"${var_ref%%[![:space:]]*}"}"
  # remove trailing whitespace characters
  var_ref="${var_ref%"${var_ref##*[![:space:]]}"}"
}

: > patchdata.jsonl #truncate if present

for line in "${series_lines[@]}"; do
  line="${line%%##*}" # remove everything after ##
  trim_var line
  if [[ $line != *' # '* ]]; then
    continue
  fi

  patchname="${line%%#*}"
  trim_var patchname

  url="${line##*#}"
  url="${url/\/rev\//\/raw-rev\/}"
  trim_var url

  declare the_hash
  the_hash="$(nix store prefetch-file --json --name "$patchname" -- "$url" | jq -r '.hash')"
  echo "$patchname: $the_hash";
  printf '{"url": "%q", "name": "%q", "hash": "%q"}\n' "$url" "$patchname" "$the_hash" >> patchdata.jsonl
done

jq -s '.' < patchdata.jsonl > patchdata.json
rm patchdata.jsonl
