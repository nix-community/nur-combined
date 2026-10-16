# shellcheck shell=bash
# Optional package names force-refresh only those packages.
declare -A forced=()
declare -A handled=()
for arg in "$@"; do
  forced[$arg]=1
done

# A push starts from an already-committed worktree, so HEAD alone cannot
# reveal package definition changes. The workflow supplies the pre-push
# revision and checks out enough history to compare it. Scheduled and
# manual runs leave this empty and still detect changes made in-worktree.
update_base_rev="${UPDATE_BASE_REV:-}"
if [[ -n "$update_base_rev" ]] && ! git cat-file -e "$update_base_rev^{commit}" 2>/dev/null; then
  echo "WARNING: update base revision $update_base_rev is unavailable; only working-tree changes will be detected" >&2
  update_base_rev=
fi

path_changed() {
  local path=$1
  if ! git diff --quiet HEAD -- "$path"; then
    return 0
  fi
  if [[ -n "$update_base_rev" ]] && ! git diff --quiet "$update_base_rev" HEAD -- "$path"; then
    return 0
  fi
  return 1
}

# Changes to package assembly, the shared npm lockfile repair, or nixpkgs
# can alter FOD contents without changing a package's source. Refresh all
# hash-bearing packages when one of these shared inputs changes.
shared_hash_input=
for path in default.nix flake.nix flake.lock internal/npm-lockfile-fix.nix; do
  if path_changed "$path"; then
    shared_hash_input=$path
    break
  fi
done

# Refresh hash-bearing packages when their directory, generated source included, or a shared fetcher input changed, or when they still use a placeholder hash.
files="$(
  grep --recursive --files-with-matches --include='*.nix' \
    --extended-regexp '[[:alnum:]_]+Hash = "sha256-' pkgs || true
)"
if [[ -n "$files" ]]; then
  while IFS= read -r file; do
    attr="$(basename "$(dirname "$file")")"

    if [[ ${#forced[@]} -gt 0 && -z "${forced[$attr]:-}" ]]; then
      continue
    fi

    # Use getAttr for non-identifier package names.
    if nix eval ".#packages.${SYSTEM}" --apply "pkgs: (builtins.getAttr \"$attr\" pkgs).pname" >/dev/null 2>&1; then
      reason=forced
      if [[ -z "${forced[$attr]:-}" ]]; then
        if path_changed "pkgs/$attr"; then
          reason="package changed"
        elif [[ -n "$shared_hash_input" ]]; then
          reason="$shared_hash_input changed"
        elif grep --quiet 'sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=' "$file"; then
          reason="placeholder hash"
        else
          echo "Skipping $attr: hash inputs unchanged"
          continue
        fi
      fi
      echo "Updating hashes for $attr ($reason)"
      handled[$attr]=1

      # nix-update only refreshes hash attributes it knows; updateCustomDeps names the rest.
      custom_dep_args=()
      mapfile -t custom_deps < <(
        nix eval --json ".#packages.${SYSTEM}" \
          --apply "pkgs: (builtins.getAttr \"$attr\" pkgs).updateCustomDeps or []" 2>/dev/null |
          jq --raw-output '.[]' || true
      )
      for dep in "${custom_deps[@]}"; do
        custom_dep_args+=(--custom-dep "$dep")
      done

      nix-update --flake "$attr" --version skip --override-filename "$file" "${custom_dep_args[@]}"
    else
      echo "Skipping $attr: no matching flake package" >&2
    fi
  done <<<"$files"
fi

for arg in "${!forced[@]}"; do
  if [[ -z "${handled[$arg]:-}" ]]; then
    echo "WARNING: forced package $arg was not refreshed (no vendored hash or no matching flake package)" >&2
  fi
done
