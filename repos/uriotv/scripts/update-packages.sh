#!/usr/bin/env bash
set -euo pipefail

# markdown_escape FILE: render log as ONE physical line safe for a
# Markdown table cell: escape backslash/pipe/backtick/angle brackets
# (so raw logs can never break table structure or inject HTML), then
# join lines with <br> (GitHub ignores raw newlines inside cells)
markdown_escape() {
  awk '
    BEGIN { ORS = "" }
    NR > 1 { print "<br>" }
    {
      gsub(/\\/, "\\\\")
      gsub(/\|/, "\\|")
      gsub(/`/, "\\`")
      gsub(/</, "\\<")
      gsub(/>/, "\\>")
      gsub(/\r/, "")
      print
    }
  ' "$1"
  echo
}

# truncate FILE MAX_LINES: keep first MAX_LINES lines and add
# an explicit "truncated" marker; also cap total characters as a
# second guard
truncate_log() {
  local file=$1
  local max_lines=$2
  local max_chars=4000
  local lines
  lines=$(wc -l < "$file")
  if [ "$lines" -gt "$max_lines" ]; then
    head -n "$max_lines" "$file" > "$file.tmp"
    echo "... (truncated, $((lines - max_lines)) more lines; see full log in the Build Log)" >> "$file.tmp"
    mv "$file.tmp" "$file"
  fi
  if [ "$(wc -c < "$file")" -gt $max_chars ]; then
    head -c $max_chars "$file" > "$file.tmp"
    echo "" >> "$file.tmp"
    echo "... (truncated at ${max_chars} chars; see full log in the Build Log)" >> "$file.tmp"
    mv "$file.tmp" "$file"
  fi
}

summary="## Package Update Status"
summary+=$'\n'"| Package | Status | Details |"
summary+=$'\n'"| --- | --- | --- |"

FAILED=0
SUCCEEDED=0
UPDATE_PACKAGE=${UPDATE_PACKAGE:-}
UPDATE_TIMEOUT_SECONDS=${UPDATE_TIMEOUT_SECONDS:-900}
[[ "$UPDATE_TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ ]] || {
  echo '::error::UPDATE_TIMEOUT_SECONDS must be a positive integer'; exit 1;
}
PR_BODY_PATH=${PR_BODY_PATH:-/tmp/pr-body.md}
: "${GITHUB_STEP_SUMMARY:?GITHUB_STEP_SUMMARY must be set}"
: "${BUILD_LOG_URL:?BUILD_LOG_URL must be set}"

# Each updater owns its package directory. Preserve the complete directory,
# including untracked files and modes, before an updater can partially edit it.
backup_root=$(mktemp -d)
trap 'rm -rf "$backup_root"' EXIT

run_update() {
  local script=$1
  local pkg_dir
  local pkg_name
  pkg_dir=$(dirname "$script")
  pkg_name=$(basename "$pkg_dir")

  echo "::group::Updating $pkg_name"

  local backup="$backup_root/$pkg_name"
  cp -a "$pkg_dir" "$backup"

  local log_file="$backup_root/last_output.txt"
  local output
  if output=$(timeout --kill-after=30s "${UPDATE_TIMEOUT_SECONDS}s" ./"$script" 2>&1); then
    SUCCEEDED=$((SUCCEEDED + 1))
    echo "$output" > "$log_file"
    echo "✅ Success"
    truncate_log "$log_file" 15
    local escaped
    escaped=$(markdown_escape "$log_file")
    summary+=$'\n'"| $pkg_name | ✅ Success | $escaped |"
  else
    echo "$output" > "$log_file"
    # Do not publish a changed version with an old hash or generated leftovers.
    rm -rf -- "$pkg_dir"
    cp -a "$backup" "$pkg_dir"
    echo "::warning file=$script::Update failed for $pkg_name; package changes restored"
    echo "❌ Failed"
    truncate_log "$log_file" 50
    local escaped
    escaped=$(markdown_escape "$log_file")
    summary+=$'\n'"| $pkg_name | ❌ Failed | $escaped |"
    FAILED=$((FAILED + 1))
  fi

  echo "$output"
  echo "::endgroup::"
}

# If specific package requested, update only that
if [ -n "$UPDATE_PACKAGE" ]; then
  if [[ ! "$UPDATE_PACKAGE" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    echo "::error::Invalid package name: $UPDATE_PACKAGE"
    exit 1
  fi

  script="pkgs/$UPDATE_PACKAGE/update.sh"
  if [ ! -f "pkgs/$UPDATE_PACKAGE/default.nix" ] || [ ! -x "$script" ]; then
    echo "::error::No package with an executable update script found at $script"
    exit 1
  fi

  run_update "$script"
else
  # Same convention as pkgs/default.nix: immediate directories with default.nix.
  # Preflight the entire registry: never silently ignore a new package whose
  # updater was forgotten or whose executable bit was lost.
  scripts=()
  for directory in pkgs/*/; do
    [[ ! -L "${directory%/}" && -f "${directory}default.nix" ]] || continue
    script="${directory}update.sh"
    [[ -x "$script" ]] || { echo "::error::Missing executable updater: $script"; exit 1; }
    scripts+=("$script")
  done
  [[ ${#scripts[@]} -gt 0 ]] || { echo '::error::No packages discovered'; exit 1; }
  for script in "${scripts[@]}"; do
    run_update "$script"
  done
fi

# Write summary to the job step summary and the full PR body to a
# file. Using body-path (not a workflow output) avoids heredoc
# breakage when a log line is literally "EOF" and YAML/markdown
# mangling of very long lines.
{
  echo "$summary"
} >> "$GITHUB_STEP_SUMMARY"
{
  echo "This PR was automatically created by the update workflow."
  echo ""
  echo "See the [Build Log](${BUILD_LOG_URL}) for details."
  echo ""
  echo "<details><summary>Package Update Status</summary>"
  echo ""
  echo "$summary"
  echo ""
  echo "</details>"
} > "$PR_BODY_PATH"

# The workflow opens a PR for successful changes first, then marks an incomplete
# update check as failed. Offline/local callers do not need GITHUB_OUTPUT.
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  printf 'update_failures=%s\nsuccessful_updates=%s\n' "$FAILED" "$SUCCEEDED" >> "$GITHUB_OUTPUT"
fi

if [ "$FAILED" -ne 0 ]; then
  echo "::warning::$FAILED package update(s) failed; continuing with successful updates"
fi

