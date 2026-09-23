#!/usr/bin/env bash
# Refresh pi-agent and pi-agent-git npm deps after a source bump.
#
# pi-agent is a buildNpmPackage whose lockfile derives from the official
# pi-coding-agent-install-package-lock.json attached to each GitHub release.
# That lockfile is the single upstream-sourced artifact: pkgs/pi-agent/default.nix
# derives its wrapper manifest from the lockfile root entry, so dependency
# versions are never hand-written. The lockfile ships with integrity:null on
# the @earendil-works/* packages, which prefetch-npm-deps rejects, so the
# script fills integrity in from registry metadata before hashing.
#
# Triggered by .github/workflows/auto-update.yml when scripts/auto-update.sh
# reports pi-agent in NPM_DEPS_TARGETS. Also runnable locally from repo root.
# The pi-agent-git section refreshes pkgs/pi-agent/git.nix in the same pass.

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
  | [.key, (.key | capture("@earendil-works/(?<n>[^/]+)$").n), .value.version]
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

# 4. Refresh pi-agent-git's npmDepsHash from the same release's source archive.
# pi-agent-git builds the monorepo from pi-<version>-source.tar.gz; its root
# package-lock.json is hashed with the default fetcher v1 format — fetcher v2
# fetches live registry packuments, which makes the hash drift over time.
GIT_NIX="$ROOT/pkgs/pi-agent/git.nix"
if [[ -f "$GIT_NIX" ]]; then
  echo "Refreshing pi-agent-git npm deps"
  GIT_VERSION=$(jq -r '.["pi-agent-git"].version' "$GENERATED")
  if [[ -z "$GIT_VERSION" || "$GIT_VERSION" == "null" ]]; then
    echo "could not read pi-agent-git version from $GENERATED" >&2
    exit 1
  fi
  curl -sL -o "$tmp/source.tar.gz" \
    "https://github.com/earendil-works/pi/releases/download/v${GIT_VERSION}/pi-${GIT_VERSION}-source.tar.gz"
  tar -xzf "$tmp/source.tar.gz" -C "$tmp" "pi-${GIT_VERSION}/package-lock.json"
  GIT_HASH=$(nix run nixpkgs#prefetch-npm-deps -- "$tmp/pi-${GIT_VERSION}/package-lock.json")
  sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$GIT_HASH\";|" "$GIT_NIX"
  echo "pi-agent-git npmDepsHash = $GIT_HASH"
fi

# 5. Verify the packages still build end-to-end with the refreshed deps.
echo "Verifying build..."
nix-build -A pi-agent
if [[ -f "$GIT_NIX" ]]; then
  nix-build -A pi-agent-git
fi
echo "pi-agent/pi-agent-git build OK with refreshed npm deps."
