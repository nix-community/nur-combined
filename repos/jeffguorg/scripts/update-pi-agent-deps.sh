#!/usr/bin/env bash
# Refresh pi-agent's npm package-lock.json and npmDepsHash after a source bump.
#
# pi-agent is a buildNpmPackage whose lockfile derives from the official
# pi-coding-agent-install-package-lock.json attached to each GitHub release.
# That lockfile ships with integrity:null on the @earendil-works/* packages,
# which prefetch-npm-deps rejects, so the script fills integrity in from
# registry metadata before hashing.
#
# Triggered by .github/workflows/auto-update.yml when scripts/auto-update.sh
# reports pi-agent in NPM_DEPS_TARGETS. Also runnable locally from repo root.

set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

# ":name:"-delimited target list, same convention as update-kimi-code-deps.sh.
target_list="${1:-${NPM_DEPS_TARGETS:-}}"

contains_target() {
  local target="$1"
  [[ -z "$target_list" || "$target_list" == *":${target}:"* ]]
}

if ! contains_target "pi-agent"; then
  echo "pi-agent not in npm deps targets; skipping"
  exit 0
fi

GENERATED="$ROOT/_sources/generated.json"
LOCK="$ROOT/pkgs/pi-agent/package-lock.json"
NIXFILE="$ROOT/pkgs/pi-agent/default.nix"

VERSION=$(jq -r '.["pi-agent"].version' "$GENERATED")
if [[ -z "$VERSION" || "$VERSION" == "null" ]]; then
  echo "could not read pi-agent version from $GENERATED" >&2
  exit 1
fi
echo "Refreshing pi-agent npm deps for version $VERSION"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 1. Download the official install lockfile from the GitHub release.
curl -sL -o "$tmp/package-lock.json" \
  "https://github.com/earendil-works/pi/releases/download/v${VERSION}/pi-coding-agent-install-package-lock.json"

lock_root_dep=$(jq -r '.packages[""].dependencies["@earendil-works/pi-coding-agent"]' "$tmp/package-lock.json")
if [[ "$lock_root_dep" != "$VERSION" ]]; then
  echo "official lockfile root dep ($lock_root_dep) != expected ($VERSION)" >&2
  exit 1
fi

# 2. Fill integrity:null entries from registry metadata (prefetch-npm-deps
#    panics on http-resolved entries without integrity). Official registry
#    only, same reasoning as update-kimi-code-deps.sh.
while IFS=$'\t' read -r key pkg ver; do
  integrity=$(nix shell nixpkgs#nodejs --command \
    npm view "@earendil-works/${pkg}@${ver}" dist.integrity \
    --registry=https://registry.npmjs.org/)
  if [[ -z "$integrity" || "$integrity" == "null" ]]; then
    echo "could not resolve integrity for @earendil-works/${pkg}@${ver}" >&2
    exit 1
  fi
  jq --arg key "$key" --arg i "$integrity" \
    '.packages[$key].integrity = $i' \
    "$tmp/package-lock.json" > "$tmp/lock.json" && mv "$tmp/lock.json" "$tmp/package-lock.json"
done < <(jq -r '
  .packages | to_entries[]
  | select(.key != "" and (.value.integrity == null)
      and ((.value.resolved // "") | startswith("https://registry.npmjs.org/@earendil-works/")))
  | [.key, (.key | capture("(?<p>pi-[a-z-]+)$").p), .value.version]
  | @tsv
' "$tmp/package-lock.json")

remaining=$(jq -r '[.packages | to_entries[]
  | select(.key != "" and (.value.integrity == null)
      and ((.value.resolved // "") | startswith("http")))] | length' "$tmp/package-lock.json")
if [[ "$remaining" != "0" ]]; then
  echo "lockfile still has $remaining entries without integrity after patching" >&2
  exit 1
fi

# 3. Replace the lockfile and recompute npmDepsHash.
cp "$tmp/package-lock.json" "$LOCK"
NEW_HASH=$(nix run nixpkgs#prefetch-npm-deps -- "$LOCK")
sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$NEW_HASH\";|" "$NIXFILE"

echo "Lockfile refreshed; npmDepsHash = $NEW_HASH"

# 4. Verify the package still builds end-to-end with the refreshed deps.
echo "Verifying build..."
nix-build -A pi-agent
echo "pi-agent builds OK with refreshed npm deps."
