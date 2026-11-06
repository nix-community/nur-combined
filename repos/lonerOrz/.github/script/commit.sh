#!/usr/bin/env bash
# Auto-commit packages under pkgs/ that have changed.
#
# Version detection uses the real evaluated .version on each relevant platform
# (flake systems ∩ meta.platforms). File layout of the version is irrelevant.
#
# Message rules:
#   - New package:                pkg: init at <version>
#   - Same change on all platforms: pkg: old -> new
#   - Different changes per platform: pkg(sys): old -> new; ...
#   - Fallback (hash/rev only):   pkg: update rev <short> -> <short>
#                                 pkg: update source hash
#                                 pkg: internal changes
set -euo pipefail
[ "${DEBUG:-}" = "1" ] && set -x

git reset HEAD >/dev/null 2>&1 || true
REPO_ROOT="$(git rev-parse --show-toplevel)"
DEFAULT_NIX="$REPO_ROOT/default.nix"
FLAKE_NIX="$REPO_ROOT/flake.nix"

get_flake_systems() {
  local s
  s=$(awk '
    /^[[:space:]]*systems[[:space:]]*=[[:space:]]*\[/ { inb = 1; next }
    inb && /\]/ { exit }
    inb {
      gsub(/^[[:space:]]*|[[:space:]]*$/, "")
      gsub(/"/, "")
      if ($0 != "") print $0
    }
  ' "$FLAKE_NIX")
  if [ -z "$s" ]; then
    echo "x86_64-linux"
    echo "aarch64-linux"
  else
    echo "$s"
  fi
}

# Eval .version on the given system; empty on failure.
eval_version() {
  local pkg="$1" sys="$2" root="$3"
  nix eval --raw --impure --system "$sys" -f "$root/default.nix" "${pkg}.version" 2>/dev/null || true
}

# Package meta.platforms (one per line); empty on failure / unset.
eval_pkg_platforms() {
  nix eval --json --impure --system x86_64-linux -f "$DEFAULT_NIX" "${1}.meta.platforms" 2>/dev/null |
    jq -r '.[]? // empty' 2>/dev/null || true
}

# Intersection of stdin set with the set in file $1.
intersection() {
  local f="$1"
  while IFS= read -r a; do
    [ -z "$a" ] && continue
    grep -qxF "$a" "$f" 2>/dev/null && echo "$a"
  done || true
}

short() {
  local s="$1"
  [ -n "$s" ] && echo "${s:0:9}" || echo "-"
}

# Prefer JSON .rev/.tag, else Nix literal; empty if none found.
rev_of() {
  jq -r '.rev // .tag // empty' "$1" 2>/dev/null ||
    awk '/^[[:space:]]*(rev|tag)[[:space:]]*=[[:space:]]*"/ {
      v = $0; sub(/.*[=][[:space:]]*"/, "", v); sub(/".*/, "", v); print v; exit
    }' "$1" 2>/dev/null
}

changed_pkgs=$(
  {
    git diff --name-only --relative pkgs/ 2>/dev/null
    git ls-files --others --exclude-standard -- pkgs/ 2>/dev/null
  } |
    awk -F/ 'NF >= 2 { print $2 }' |
    sort -u || true
)

if [ -z "$changed_pkgs" ]; then
  echo "没有检测到 pkgs 下的改动"
  exit 0
fi

FLAKE_SYS_FILE="$(mktemp)"
get_flake_systems >"$FLAKE_SYS_FILE"

# Single worktree pointing at HEAD; reused for all packages.
WT="$(mktemp -d)"
if ! git worktree add -q "$WT" HEAD 2>/dev/null; then
  WT=""
fi

cleanup() {
  [ -n "$WT" ] && git worktree remove --force "$WT" >/dev/null 2>&1 || true
  rm -f "$FLAKE_SYS_FILE" "$PKG_SYS_FILE" "$REAL_SYS_FILE" "${OLD_F:-}"
}
trap cleanup EXIT

for pkg in $changed_pkgs; do
  dir="pkgs/$pkg"
  [ -d "$dir" ] || continue
  echo "处理包: $pkg"

  PKG_SYS_FILE="$(mktemp)"
  eval_pkg_platforms "$pkg" >"$PKG_SYS_FILE" || true
  [ ! -s "$PKG_SYS_FILE" ] && cp "$FLAKE_SYS_FILE" "$PKG_SYS_FILE"

  REAL_SYS_FILE="$(mktemp)"
  intersection "$FLAKE_SYS_FILE" <"$PKG_SYS_FILE" >"$REAL_SYS_FILE"
  [ ! -s "$REAL_SYS_FILE" ] && cp "$FLAKE_SYS_FILE" "$REAL_SYS_FILE"

  unset AFTER
  declare -A AFTER
  while IFS= read -r sys; do
    [ -z "$sys" ] && continue
    AFTER["$sys"]="$(eval_version "$pkg" "$sys" "$REPO_ROOT")"
  done <"$REAL_SYS_FILE"

  unset BEFORE
  declare -A BEFORE
  if [ -n "$WT" ]; then
    while IFS= read -r sys; do
      [ -z "$sys" ] && continue
      BEFORE["$sys"]="$(eval_version "$pkg" "$sys" "$WT")"
    done <"$REAL_SYS_FILE"
  fi

  # Collect version transitions that actually differ.
  ver_changed=0
  items=()
  declare -A transition_count
  while IFS= read -r sys; do
    [ -z "$sys" ] && continue
    b="${BEFORE[$sys]:-}"
    n="${AFTER[$sys]:-}"
    if [ -n "$n" ] && [ "$b" != "$n" ]; then
      ver_changed=1
      if [ -z "$b" ]; then
        items+=("${pkg}(${sys}): init at ${n}")
        key="init:${n}"
      else
        items+=("${pkg}(${sys}): ${b} -> ${n}")
        key="${b}->${n}"
      fi
      transition_count["$key"]=$((${transition_count[$key]:-0} + 1))
    fi
  done <"$REAL_SYS_FILE"

  msg=""
  if [ "$ver_changed" -eq 1 ]; then
    # All changed platforms share the exact same transition → collapse.
    if [ "${#transition_count[@]}" -eq 1 ]; then
      # Extract the single key.
      for k in "${!transition_count[@]}"; do
        if [[ "$k" == init:* ]]; then
          msg="${pkg}: init at ${k#init:}"
        else
          old="${k%%->*}"
          new="${k#*->}"
          msg="${pkg}: ${old} -> ${new}"
        fi
      done
    else
      # Divergent transitions: keep the detailed list.
      if [ "${#items[@]}" -eq 1 ]; then
        msg="${items[0]}"
      else
        joined=""
        for it in "${items[@]}"; do
          [ -z "$joined" ] && joined="$it" || joined="$joined; $it"
        done
        msg="$joined"
      fi
    fi
  else
    # Version unchanged → fall back to file-level rev/tag/hash detection.
    newf="$(git diff --name-only HEAD -- "$dir" 2>/dev/null | head -1)"
    [ -z "$newf" ] && newf="$(git ls-files --others --exclude-standard -- "$dir" 2>/dev/null | head -1)"

    if [ -n "$newf" ]; then
      OLD_F="$(mktemp)"
      git show "HEAD:$newf" >"$OLD_F" 2>/dev/null || true
      if [ ! -s "$OLD_F" ]; then
        # Brand-new package with no evaluable version (rare).
        msg="$pkg: new package"
      else
        or="$(rev_of "$OLD_F")"
        nr="$(rev_of "$newf")"
        if [ -n "$or" ] && [ -n "$nr" ] && [ "$or" != "$nr" ]; then
          msg="$pkg: update rev $(short "$or") -> $(short "$nr")"
        else
          msg="$pkg: update source hash"
        fi
      fi
      rm -f "$OLD_F"
      OLD_F=""
    else
      msg="$pkg: internal changes"
    fi
  fi

  echo "$msg"
  git add "$dir"
  git diff --cached --quiet || git commit -m "$msg"

  rm -f "$PKG_SYS_FILE" "$REAL_SYS_FILE"
  PKG_SYS_FILE=""
  REAL_SYS_FILE=""
done
