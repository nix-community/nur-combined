# shellcheck shell=bash
# Shared selection and change-detection helpers for the package update apps.
# The Nix wrapper prepends this file to each script, so it defines no top-level commands.

declare -A forced=()
declare -A handled=()

# Optional package names restrict the run to those packages and force them.
parse_forced() {
  local arg
  for arg in "$@"; do
    forced[$arg]=1
  done
}

forcing() {
  [[ ${#forced[@]} -gt 0 ]]
}

is_forced() {
  [[ -n "${forced[$1]:-}" ]]
}

mark_handled() {
  handled[$1]=1
}

# $1 explains what a package would have needed to qualify.
warn_unhandled() {
  local reason=$1 arg
  for arg in "${!forced[@]}"; do
    if [[ -z "${handled[$arg]:-}" ]]; then
      echo "WARNING: forced package $arg was not $reason" >&2
    fi
  done
}

# Compare an nvfetcher source with HEAD. Source updates are generated in the
# working tree, so the pre-push revision is not needed here.
source_changed() {
  local name=$1
  local old_entry new_entry
  old_entry=$(git show HEAD:_sources/generated.json 2>/dev/null | jq --compact-output --arg name "$name" '.[$name]' || true)
  new_entry=$(jq --compact-output --arg name "$name" '.[$name]' _sources/generated.json)
  [[ "$old_entry" != "$new_entry" ]]
}

# The nvfetcher entry for a package, or the string "null" when it is untracked.
source_entry() {
  jq --compact-output --arg name "$1" '.[$name]' _sources/generated.json
}
