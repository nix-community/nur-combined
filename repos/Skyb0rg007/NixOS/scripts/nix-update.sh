#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash -p nix -p jq
# shellcheck shell=bash
#
# Unlike ./update.sh (which calls nix-update by hand, duplicating each
# package's flags), this runs whatever each package's own
# `passthru.updateScript` says to run. That script is normally produced by
# `nix-update-script { extraArgs = [ ... ]; }`, so package-specific flags
# (--version-regex, --version=unstable, etc.) stay defined next to the
# package instead of here.

set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit

system=$(nix eval --raw --impure --expr 'builtins.currentSystem')

# Only consider git-tracked files: the flake is evaluated from a git+file://
# copy that filters out untracked paths, so untracked packages (or ones only
# `git add --intent-to-add`'d) would otherwise fail `nix eval` below.
mapfile -t attrs < <(
  {
    git ls-files -- 'pkgs/by-name/*' | cut -d/ -f3 | sort -u
    git ls-files -- 'pkgs/python-modules/*' | sed -E 's#^pkgs/python-modules/([^/]+).*#python3Packages.\1#' | sort -u
    git ls-files -- 'pkgs/tcl-modules/*' | sed -E 's#^pkgs/tcl-modules/([^/]+).*#tcl9Packages.\1#' | sort -u
  } | sort
)

failed=()

for attr in "${attrs[@]}"; do
  err=$(mktemp)
  info=$(
    nix eval --json ".#legacyPackages.${system}.${attr}" --apply '
      p:
      if (p.updateScript or null) != null then
        {
          hasScript = true;
          command = if builtins.isList p.updateScript then p.updateScript else p.updateScript.command;
          name = p.name or "";
          pname = p.pname or "";
          version = p.version or "";
        }
      else
        { hasScript = false; }
    ' 2>"$err"
  ) || {
    echo "!! eval failed: $attr" >&2
    cat "$err" >&2
    rm -f "$err"
    failed+=("$attr")
    continue
  }
  rm -f "$err"

  [[ "$(jq -r '.hasScript' <<<"$info")" == "true" ]] || continue

  mapfile -t cmd < <(jq -r '.command[]' <<<"$info")

  echo "== $attr =="
  UPDATE_NIX_NAME=$(jq -r '.name' <<<"$info") \
    UPDATE_NIX_PNAME=$(jq -r '.pname' <<<"$info") \
    UPDATE_NIX_OLD_VERSION=$(jq -r '.version' <<<"$info") \
    UPDATE_NIX_ATTR_PATH="$attr" \
    "${cmd[@]}" || failed+=("$attr")
done

if ((${#failed[@]})); then
  echo >&2
  echo "Failed: ${failed[*]}" >&2
  exit 1
fi
