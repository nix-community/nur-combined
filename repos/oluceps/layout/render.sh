#!/usr/bin/env bash
set -euo pipefail

layout_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(dirname -- "$layout_dir")"
if [[ -z "${D2_BIN:-}" ]]; then
  if command -v d2 >/dev/null 2>&1; then
    D2_BIN="$(command -v d2)"
  else
    d2_package="$(nix build "$repo_dir#nixosConfigurations.eihort.pkgs.d2" --no-link --print-out-paths --no-write-lock-file)"
    D2_BIN="$d2_package/bin/d2"
  fi
fi
font_args=()
if [[ -n "${D2_FONT:-}" ]]; then
  if [[ ! -f "$D2_FONT" || ! -r "$D2_FONT" || "$D2_FONT" != *.ttf ]]; then
    printf '%s\n' 'D2_FONT must name a readable TTF file.' >&2
    exit 1
  fi
  font_args=(--font-regular "$D2_FONT" --font-bold "$D2_FONT")
fi
for source in "$layout_dir"/*.d2; do
  "$D2_BIN" --layout dagre --theme 0 --pad 40 "${font_args[@]}" \
    "$source" "${source%.d2}.svg"
done
