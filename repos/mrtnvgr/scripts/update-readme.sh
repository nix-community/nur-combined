#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readme="$root/README.md"

begin='<!-- packages:begin -->'
end='<!-- packages:end -->'

if ! grep -qF "$begin" "$readme" || ! grep -qF "$end" "$readme"; then
  echo "README.md is missing the '$begin'/'$end' markers" >&2
  exit 1
fi

list="$(nix eval --impure --raw -f "$root/flake/readme.nix")"

awk -v begin="$begin" -v end="$end" -v list="$list" '
  $0 == begin { print; print list; skip = 1; next }
  $0 == end { skip = 0 }
  !skip { print }
' "$readme" > "$readme.tmp"

mv "$readme.tmp" "$readme"
