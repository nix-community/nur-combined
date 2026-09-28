#!/usr/bin/env bash
# Refresh dsh and dsh-tui npm package-lock.json and npmDepsHash after a source bump.
#
# Both are buildNpmPackage wrappers around registry-published packages whose
# lockfiles are hand-maintained under pkgs/<name>/. When nvfetcher bumps the
# source version the dependency tree can change, so the lockfile and
# npmDepsHash must be regenerated together — nvfetcher does neither.
#
# The lockfile root must match the install-root package.json that
# pkgs/<name>/default.nix constructs, otherwise npm ci in npmConfigHook
# reports the lockfile out of sync:
# - dsh: single dep on @deepseek-ai/dsh itself.
# - dsh-tui: the tarball's own production dependencies, extracted with jq
#   (the wrapper cannot depend on the published package itself because its
#   bundledDependencies carry workspace:* specs npm cannot parse).
# dsh relies on npm's default peer auto-install (dsh-app-boot imports
# peer-only cordis plugins at runtime); dsh-tui generates with
# --legacy-peer-deps because its transitive dsh-working-activity peers are
# provided by the dsh harness at runtime, not installed.
#
# Triggered by .github/workflows/auto-update.yml when scripts/auto-update.sh
# reports dsh or dsh-tui in NPM_DEPS_TARGETS. Also runnable locally from repo root.

set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

# ":name:"-delimited target list, same convention as update-kimi-code-deps.sh.
# Empty list = run for every known target (dsh, dsh-tui).
target_list="${1:-${NPM_DEPS_TARGETS:-}}"

contains_target() {
  local target="$1"
  [[ -z "$target_list" || "$target_list" == *":${target}:"* ]]
}

source_version() {
  local name="$1"
  local version
  version=$(jq -r ".[\"${name}\"].version" "$ROOT/_sources/generated.json")
  if [[ -z "$version" || "$version" == "null" ]]; then
    echo "could not read ${name} version from _sources/generated.json" >&2
    exit 1
  fi
  echo "$version"
}

# Write the install-root package.json for $1 (dsh|dsh-tui) at version $2 into $3.
write_install_root_manifest() {
  local name="$1" version="$2" out="$3"
  case "$name" in
    dsh)
      cat > "$out" <<EOF
{
  "name": "dsh-install-root",
  "version": "1.0.0",
  "dependencies": {
    "@deepseek-ai/dsh": "${version}"
  }
}
EOF
      ;;
    dsh-tui)
      # Same extraction as pkgs/dsh-tui/default.nix: production dependencies
      # from the pinned tarball, under the wrapper's install-root name.
      local tarball
      tarball=$(nix-build -A dsh-tui.src.src --no-out-link)
      tar -xzOf "$tarball" package/package.json \
        | jq '{name: "dsh-tui-install-root", version: "1.0.0", dependencies: .dependencies}' \
        > "$out"
      ;;
    *)
      echo "unknown npm deps target: $name" >&2
      exit 1
      ;;
  esac
}

refresh_target() {
  local name="$1"
  local lock="pkgs/${name}/package-lock.json"
  local nixfile="pkgs/${name}/default.nix"

  local version
  version=$(source_version "$name")
  echo "Refreshing ${name} npm deps for version $version"

  local tmp
  tmp=$(mktemp -d)

  write_install_root_manifest "$name" "$version" "$tmp/package.json"

  # Peer resolution must match the derivation's npmFlags, otherwise npm ci
  # in npmConfigHook re-resolves and the sandboxed build fails.
  local -a peer_flags=()
  case "$name" in
    dsh-tui) peer_flags=(--legacy-peer-deps) ;;
  esac

  # Official registry only: buildNpmPackage rejects resolved URLs that point at
  # mirrors, so pin it explicitly so a local npm config cannot leak in.
  ( cd "$tmp" && nix shell nixpkgs#nodejs --command npm install \
      --package-lock-only \
      "${peer_flags[@]}" \
      --registry=https://registry.npmjs.org/ )
  local lock_root_name
  lock_root_name=$(jq -r '.packages[""].name' "$tmp/package-lock.json")
  if [[ "$lock_root_name" != "${name}-install-root" ]]; then
    echo "generated lockfile root name ($lock_root_name) != expected (${name}-install-root)" >&2
    exit 1
  fi

  cp "$tmp/package-lock.json" "$lock"
  rm -rf "$tmp"

  local new_hash
  new_hash=$(nix run nixpkgs#prefetch-npm-deps -- "$lock")

  sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$new_hash\";|" "$nixfile"

  echo "${name} lockfile refreshed; npmDepsHash = $new_hash"
}

refreshed=()
if contains_target "dsh"; then
  refresh_target "dsh"
  refreshed+=("dsh")
else
  echo "dsh not in npm deps targets; skipping"
fi

if contains_target "dsh-tui"; then
  refresh_target "dsh-tui"
  refreshed+=("dsh-tui")
else
  echo "dsh-tui not in npm deps targets; skipping"
fi

# Verify the refreshed packages still build end-to-end.
for name in "${refreshed[@]}"; do
  echo "Verifying build..."
  nix-build -A "$name"
  echo "$name builds OK with refreshed npm deps."
done
