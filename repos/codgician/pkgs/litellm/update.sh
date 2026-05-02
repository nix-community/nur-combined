#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts nix gnused
#
# Custom updater rationale: the LiteLLM monorepo ships three Python
# distributions (`litellm`, `litellm-proxy-extras`, `litellm-enterprise`)
# from one source tree, each with its own independently-bumped version in
# its own pyproject.toml. `nix-update-script` only knows how to update a
# single `version = "..."` line, so we drive the bump ourselves and read
# the sibling versions out of the freshly-fetched source.
#
# Usage:
#   ./pkgs/litellm/update.sh                    # bump to latest release
#   ./pkgs/litellm/update.sh 1.85.0-dev.1       # bump to a specific tag

set -euo pipefail

cd "$(git rev-parse --show-toplevel)/pkgs/litellm"
nixfile=default.nix

if [[ $# -ge 1 ]]; then
  new_tag=$1
else
  new_tag=$(curl -fsSL https://api.github.com/repos/BerriAI/litellm/releases \
    | jq -r '.[0].tag_name')
fi

old_tag=$(sed -nE 's/^\s*version = "(1\.[^"]+)";/\1/p' "$nixfile" | head -1)

if [[ "$old_tag" == "$new_tag" ]]; then
  echo "litellm is already at $old_tag, nothing to do."
  exit 0
fi

echo "Bumping litellm: $old_tag -> $new_tag"

new_hash=$(nix-prefetch-url --unpack \
  "https://github.com/BerriAI/litellm/archive/$new_tag.tar.gz" 2>/dev/null \
  | tail -1)
new_sri=$(nix hash convert --to sri --hash-algo sha256 "$new_hash")

src_path=$(nix-prefetch-url --unpack --print-path \
  "https://github.com/BerriAI/litellm/archive/$new_tag.tar.gz" 2>/dev/null \
  | tail -1)

new_extras_ver=$(sed -nE 's/^version = "([^"]+)".*$/\1/p' \
  "$src_path/litellm-proxy-extras/pyproject.toml" | head -1)
new_enterprise_ver=$(sed -nE 's/^version = "([^"]+)".*$/\1/p' \
  "$src_path/enterprise/pyproject.toml" | head -1)

if [[ -z "$new_extras_ver" || -z "$new_enterprise_ver" ]]; then
  echo "ERROR: could not extract sibling versions from $src_path" >&2
  exit 1
fi

echo "  litellm-proxy-extras: $new_extras_ver"
echo "  litellm-enterprise:   $new_enterprise_ver"

old_extras_ver=$(sed -nE 's/^\s*version = "(0\.4\.[^"]+)";/\1/p' "$nixfile" \
  | head -1)
old_enterprise_ver=$(sed -nE 's/^\s*version = "(0\.1\.[^"]+)";/\1/p' "$nixfile" \
  | head -1)

sed -i \
  -e "s|version = \"$old_tag\"|version = \"$new_tag\"|" \
  -e "s|hash = \"sha256-[^\"]\\+\"|hash = \"$new_sri\"|" \
  "$nixfile"

sed -i \
  -e "0,/version = \"$old_extras_ver\"/{s|version = \"$old_extras_ver\"|version = \"$new_extras_ver\"|}" \
  -e "0,/version = \"$old_enterprise_ver\"/{s|version = \"$old_enterprise_ver\"|version = \"$new_enterprise_ver\"|}" \
  "$nixfile"

sed -i \
  -e "s|litellm-proxy-extras==$old_extras_ver|litellm-proxy-extras==$new_extras_ver|" \
  -e "s|litellm-enterprise==$old_enterprise_ver|litellm-enterprise==$new_enterprise_ver|" \
  "$nixfile"

echo "Updated $nixfile to LiteLLM $new_tag."
echo "Run 'nix build .#litellm' to verify."
