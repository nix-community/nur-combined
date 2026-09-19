#!/usr/bin/env bash
# Updates the local packages in the pkgs/ directory.
# Usage: ./pkgs/update.sh [package-name] [version]
#
# Examples:
#   ./pkgs/update.sh                     # updates ALL packages in pkgs/
#   ./pkgs/update.sh nxapi               # updates nxapi only (latest version)
#   ./pkgs/update.sh nxapi 1.7.0         # nxapi to a specific version
#   ./pkgs/update.sh --force nxapi       # same, even if nxapi is blacklisted
#
# Blacklist: a package whose directory contains a `.nix-update-ignore` file is
# never updated. The first non-empty line of that file is printed as the
# reason. Use --force (or -f) to update it anyway.
#
# Report: when REPORT_FILE is set, one tab-separated row per package is appended
# to that file (status, name, old version, new version, note), with status being
# ok, skipped or failed. Used by CI to build the run summary.
#
# Requirements: nix-update (available via `nix run nixpkgs#nix-update`)
#               jq, nix-prefetch-url, python3

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKGS_DIR="$REPO_ROOT/pkgs"

# --- Blacklist marker: presence of this file in a pkg dir disables updates ---
SKIP_MARKER=".nix-update-ignore"
FORCE=0
SKIPPED=()

# --- Lists the available packages (one per subdirectory with a default.nix) ---
list_packages() {
  for d in "$PKGS_DIR"/*/; do
    [ -f "$d/default.nix" ] && basename "$d"
  done
}

# --- Tells whether a package is blacklisted (marker file present) ---
is_blacklisted() {
  [ -f "$1/$SKIP_MARKER" ]
}

# --- Reason stored in a blacklist marker: first non-empty line (may be empty) ---
skip_reason() {
  grep -m1 -v '^[[:space:]]*$' "$1/$SKIP_MARKER" 2>/dev/null || true
}

# --- Appends one row to the machine-readable report (no-op without REPORT_FILE) ---
# Tabs and newlines are flattened so the row always stays a single TSV record.
report_row() {
  if [ -n "${REPORT_FILE:-}" ]; then
    printf '%s\t%s\t%s\t%s\t%s\n' \
      "$1" "$2" "${3:-}" "${4:-}" \
      "$(printf '%s' "${5:-}" | tr '\t\r\n' ' ')" >> "$REPORT_FILE"
  fi
  return 0
}

# --- Reads the current version of a package (empty if unavailable) ---
package_version() {
  local pkg_name="$1"
  local ver
  if ver="$(NIXPKGS_ALLOW_INSECURE=1 nix eval --raw --impure ".#${pkg_name}.version" 2>/dev/null)" && [ -n "$ver" ]; then
    printf '%s\n' "$ver"
    return 0
  fi
  # Fallback: parse the version from the .nix source (never fail under `set -e`).
  grep -m1 -hoE 'version = "[^"]+"' "$PKGS_DIR/$pkg_name"/*.nix 2>/dev/null \
    | head -n1 \
    | sed -E 's/^version = "(.*)"$/\1/' \
    || true
}

# --- Commits the changes of a single package (only when AUTO_COMMIT=1) ---
commit_package() {
  local pkg_name="$1"
  local old_version="$2"
  local new_version="$3"
  local rel_dir="pkgs/$pkg_name"

  if [ "${AUTO_COMMIT:-0}" != "1" ]; then
    return 0
  fi

  if [ -z "$(git -C "$REPO_ROOT" status --porcelain -- "$rel_dir")" ]; then
    echo "No changes to commit for $pkg_name"
    return 0
  fi

  local message
  if [ -n "$old_version" ] && [ "$old_version" = "$new_version" ]; then
    message="$pkg_name: update source hashes"
  else
    message="$pkg_name: ${old_version:-unknown} -> ${new_version:-unknown}"
  fi

  git -C "$REPO_ROOT" add -- "$rel_dir"
  git -C "$REPO_ROOT" commit -m "$message"
  echo "Committed: $message"
}

# --- Updates a given package ---
update_package() {
  local pkg_name="$1"
  local version_arg=""

  if [ $# -eq 2 ]; then
    version_arg="--version $2"
    echo "Target version: $2"
  else
    echo "Target version: latest available"
  fi

  local pkg_dir="$PKGS_DIR/$pkg_name"
  if [ ! -d "$pkg_dir" ]; then
    echo "Error: directory $pkg_dir does not exist"
    report_row failed "$pkg_name" "" "" "directory not found"
    return 1
  fi

  # Blacklisted packages are left untouched unless --force was given.
  if [ "$FORCE" != "1" ] && is_blacklisted "$pkg_dir"; then
    local reason
    reason="$(skip_reason "$pkg_dir")"
    echo "=== Skipped: $pkg_name (blacklisted via $SKIP_MARKER) ==="
    if [ -n "$reason" ]; then
      echo "  reason: $reason"
    fi
    echo ""
    SKIPPED+=("$pkg_name")
    report_row skipped "$pkg_name" "" "" "$reason"
    return 0
  fi

  echo "=== Updating: $pkg_name ==="

  local old_version
  old_version="$(package_version "$pkg_name")"

  # Detects package-specific quirks
  local needs_insecure=false
  for f in "$pkg_dir"/*.nix; do
    if grep -qE "electron_[0-9]+|nodejs_[0-9]+" "$f"; then
      needs_insecure=true
      break
    fi
  done

  local nix_update_args="--flake $version_arg"
  local build_cmd="nix build .#$pkg_name --no-link --print-out-paths"

  if [ "$needs_insecure" = true ]; then
    echo "  (insecure dependencies -> NIXPKGS_ALLOW_INSECURE=1)"
    # nix-update does not accept --impure (it uses nix-instantiate, which
    # already reads NIXPKGS_ALLOW_INSECURE from the environment).
    build_cmd="NIXPKGS_ALLOW_INSECURE=1 $build_cmd --impure"
    export NIXPKGS_ALLOW_INSECURE=1
  fi

  # nix-update updates version + hashes automatically
  echo "--- nix-update ---"
  nix run nixpkgs#nix-update -- $nix_update_args "$pkg_name" || {
    echo "nix-update failed for $pkg_name"
    report_row failed "$pkg_name" "$old_version" "" "nix-update"
    return 1
  }

  # Verifies the build
  echo "--- Build check ---"
  eval "$build_cmd" 2>&1 | tail -5 || {
    echo "Build failed for $pkg_name"
    report_row failed "$pkg_name" "$old_version" "" "build"
    return 1
  }

  local new_version
  new_version="$(package_version "$pkg_name")"
  echo "Version: ${old_version:-unknown} -> ${new_version:-unknown}"

  commit_package "$pkg_name" "$old_version" "$new_version"

  local note=""
  if [ -n "$old_version" ] && [ "$old_version" = "$new_version" ]; then
    note="up to date"
  fi
  report_row ok "$pkg_name" "$old_version" "$new_version" "$note"

  echo "OK: $pkg_name"
  echo ""
}

# --- Argument parsing ---
if [ "${1:-}" = "--force" ] || [ "${1:-}" = "-f" ]; then
  FORCE=1
  shift
fi

if [ $# -eq 0 ]; then
  # No argument: update all packages
  packages=$(list_packages)
  if [ -z "$packages" ]; then
    echo "No package found in $PKGS_DIR"
    exit 1
  fi

  echo "Updating all packages:"
  echo "$packages" | sed 's/^/  /'
  echo ""

  failed=()
  for pkg in $packages; do
    if ! update_package "$pkg"; then
      failed+=("$pkg")
    fi
  done

  echo "=== Summary ==="
  if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo "Skipped (blacklisted): ${SKIPPED[*]}"
  fi
  if [ ${#failed[@]} -eq 0 ]; then
    echo "All packages updated successfully."
  else
    echo "Failed for: ${failed[*]}"
    exit 1
  fi
elif [ $# -eq 1 ]; then
  update_package "$1"
elif [ $# -eq 2 ]; then
  update_package "$1" "$2"
else
  echo "Usage: $0 [--force] [package-name] [version]"
  echo ""
  echo "Packages available in pkgs/:"
  list_packages | sed 's/^/  /'
  exit 1
fi