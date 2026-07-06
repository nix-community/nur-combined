#!/usr/bin/env bash
# Refresh kimi-code's npm package-lock.json and npmDepsHash after a source bump.
#
# kimi-code is a buildNpmPackage whose package-lock.json is hand-maintained in
# pkgs/kimi-code/. When nvfetcher bumps @moonshot-ai/kimi-code the dependency
# tree can change (e.g. 0.22.3 dropped koffi), so the lockfile and npmDepsHash
# must be regenerated together — nvfetcher does neither.
#
# Triggered by .github/workflows/auto-update.yml when scripts/auto-update.sh
# reports kimi-code in NPM_DEPS_TARGETS. Also runnable locally from repo root.

set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

# ":name:"-delimited target list, same convention as update-go-vendorHash.sh.
# Empty list = run for every known npm package (currently just kimi-code).
target_list="${1:-${NPM_DEPS_TARGETS:-}}"

contains_target() {
  local target="$1"
  [[ -z "$target_list" || "$target_list" == *":${target}:"* ]]
}

if ! contains_target "kimi-code"; then
  echo "kimi-code not in npm deps targets; skipping"
  exit 0
fi

GENERATED="$ROOT/_sources/generated.json"
LOCK="$ROOT/pkgs/kimi-code/package-lock.json"
NIXFILE="$ROOT/pkgs/kimi-code/default.nix"

VERSION=$(jq -r '.["kimi-code"].version' "$GENERATED")
if [[ -z "$VERSION" || "$VERSION" == "null" ]]; then
  echo "could not read kimi-code version from $GENERATED" >&2
  exit 1
fi
echo "Refreshing kimi-code npm deps for version $VERSION"

# 1. Regenerate package-lock.json for the wrapper install-root that
#    pkgs/kimi-code/default.nix builds (single dep: @moonshot-ai/kimi-code).
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/package.json" <<EOF
{
  "name": "kimi-full",
  "version": "0.0.0",
  "dependencies": {
    "@moonshot-ai/kimi-code": "$VERSION"
  }
}
EOF

# Official registry only: buildNpmPackage rejects resolved URLs that point at
# mirrors, so pin it explicitly so a local npm config cannot leak in.
( cd "$tmp" && nix shell nixpkgs#nodejs --command npm install \
    --package-lock-only \
    --registry=https://registry.npmjs.org/ )

lock_root_dep=$(jq -r '.packages[""].dependencies["@moonshot-ai/kimi-code"]' "$tmp/package-lock.json")
if [[ "$lock_root_dep" != "$VERSION" ]]; then
  echo "generated lockfile root dep ($lock_root_dep) != expected ($VERSION)" >&2
  exit 1
fi

# 2. Replace the hand-maintained lockfile.
cp "$tmp/package-lock.json" "$LOCK"

# 3. Recompute npmDepsHash from the new lockfile.
NEW_HASH=$(nix run nixpkgs#prefetch-npm-deps -- "$LOCK")

# 4. Write the hash back into default.nix.
sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$NEW_HASH\";|" "$NIXFILE"

echo "Lockfile refreshed; npmDepsHash = $NEW_HASH"

# 5. Verify the package still builds end-to-end with the refreshed deps.
echo "Verifying build..."
nix-build -A kimi-code
echo "kimi-code builds OK with refreshed npm deps."
