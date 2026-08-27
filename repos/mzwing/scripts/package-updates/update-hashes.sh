# shellcheck shell=bash
# Shared helpers injected by the Nix wrapper.
# shellcheck source=/dev/null
source "$UPDATE_UTILS"

# Optional package names force-refresh only those packages.
parse_forced "$@"

# Package-to-source naming exceptions.
declare -A source_names=([typenix - vscode]=typenix)

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
# can alter FOD contents without changing an nvfetcher source. Refresh all
# hash-bearing packages when one of these shared inputs changes.
shared_hash_input=
for path in default.nix flake.nix flake.lock internal/npm-lockfile-fix.nix; do
  if path_changed "$path"; then
    shared_hash_input=$path
    break
  fi
done

# Refresh hash-bearing packages when their source, package definition, or
# shared fetcher inputs changed, or when they still use a placeholder hash.
files="$(
  grep --recursive --files-with-matches --include='*.nix' \
    --extended-regexp '[[:alnum:]_]+Hash = "sha256-' pkgs || true
)"
if [[ -n "$files" ]]; then
  while IFS= read -r file; do
    attr="$(basename "$(dirname "$file")")"

    if forcing; then
      is_forced "$attr" || continue
    fi

    # Use getAttr for non-identifier package names.
    if nix eval ".#packages.${SYSTEM}" --apply "pkgs: (builtins.getAttr \"$attr\" pkgs).pname" >/dev/null 2>&1; then
      reason=forced
      if ! is_forced "$attr"; then
        source_name="${source_names[$attr]:-$attr}"
        if [[ "$(source_entry "$source_name")" == "null" ]]; then
          reason="source is not tracked"
        elif source_changed "$source_name"; then
          reason="source changed"
        elif path_changed "pkgs/$attr"; then
          reason="package definition changed"
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
      mark_handled "$attr"

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

warn_unhandled "refreshed (no vendored hash or no matching flake package)"
