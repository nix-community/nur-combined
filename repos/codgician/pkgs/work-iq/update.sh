#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix nix-prefetch-github
set -euo pipefail

# Neither nix-update-script nor gitUpdater can keep this package current alone:
# - the workiq CLI is published only to npm (@microsoft/workiq) and has no
#   GitHub Releases/tags to drive a generic updater from the marketplace repo
# - the related plugins/skills live on microsoft/work-iq main with no version
#   tags, so gitUpdater has nothing to track
# This script refreshes both the npm CLI version/hash and the plugins commit.

nur="$(git rev-parse --show-toplevel)"
path="$nur/pkgs/work-iq/default.nix"
npm_pkg="@microsoft/workiq"

old_version="$(sed -nE 's/^[[:space:]]*version = "([^"]+)";$/\1/p' "$path" | head -n1)"
old_src_hash="$(sed -nE '/src = fetchurl/,/};/s/^[[:space:]]*hash = "(sha256-[^"]+)";$/\1/p' "$path" | head -n1)"
old_plugins_rev="$(sed -nE '/plugins = fetchFromGitHub/,/};/s/^[[:space:]]*rev = "([^"]+)";$/\1/p' "$path" | head -n1)"
old_plugins_hash="$(sed -nE '/plugins = fetchFromGitHub/,/};/s/^[[:space:]]*hash = "(sha256-[^"]+)";$/\1/p' "$path" | head -n1)"

# Latest stable npm version (dist-tag "latest"; reject prerelease-looking tags).
new_version="$(
  curl --fail --silent --show-error "https://registry.npmjs.org/${npm_pkg}" \
    | jq -r '
        .["dist-tags"].latest as $latest
        | if ($latest | test("(?i)(alpha|beta|rc|preview|next|canary|dev)")) then
            empty
          else
            $latest
          end
      '
)"

if [[ -z "$new_version" || "$new_version" == "null" ]]; then
  echo "work-iq: could not resolve a stable @microsoft/workiq version" >&2
  exit 1
fi

# Latest marketplace commit on main (plugins/skills).
plugins_json="$(nix-prefetch-github microsoft work-iq --rev main)"
new_plugins_rev="$(jq -r '.rev' <<<"$plugins_json")"
new_plugins_hash="$(jq -r '.hash' <<<"$plugins_json")"

if [[ -z "$new_plugins_rev" || "$new_plugins_rev" == "null" || -z "$new_plugins_hash" ]]; then
  echo "work-iq: could not resolve microsoft/work-iq main revision" >&2
  exit 1
fi

src_url="https://registry.npmjs.org/${npm_pkg}/-/workiq-${new_version}.tgz"
new_src_hash="$(nix store prefetch-file --json "$src_url" | jq -r .hash)"

if [[
  "$old_version" == "$new_version"
  && "$old_src_hash" == "$new_src_hash"
  && "$old_plugins_rev" == "$new_plugins_rev"
  && "$old_plugins_hash" == "$new_plugins_hash"
]]; then
  echo "work-iq is up to date (CLI $new_version, plugins $new_plugins_rev)"
  exit 0
fi

sed -i -E \
  -e "s|version = \"${old_version}\";|version = \"${new_version}\";|" \
  -e "/src = fetchurl/,/};/s|hash = \"sha256-[^\"]+\";|hash = \"${new_src_hash}\";|" \
  -e "/plugins = fetchFromGitHub/,/};/s|rev = \"[^\"]+\";|rev = \"${new_plugins_rev}\";|" \
  -e "/plugins = fetchFromGitHub/,/};/s|hash = \"sha256-[^\"]+\";|hash = \"${new_plugins_hash}\";|" \
  "$path"

echo "Updated work-iq: CLI ${old_version} -> ${new_version}; plugins ${old_plugins_rev} -> ${new_plugins_rev}"
