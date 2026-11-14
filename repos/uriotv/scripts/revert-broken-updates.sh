#!/usr/bin/env bash
# Rolls back package updates that do not build, so the remaining updates still
# build, merge and publish to the cache. A reverted package keeps the version that
# main already has; the next update run retries it.
#
# Run after scripts/update-packages.sh and before the README refresh/PR step.
# Verdicts use the same rules as CI (scripts/build-ci.sh): a plan that bootstraps a
# toolchain from source counts as a failed update, and packages built out of band
# (meta.ciBuild = false, e.g. the kernel) are never touched here.
set -euo pipefail

PR_BODY_PATH=${PR_BODY_PATH:-/tmp/pr-body.md}
BUILD_TIMEOUT_SECONDS=${UPDATE_BUILD_TIMEOUT_SECONDS:-1800}
[[ "$BUILD_TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ ]] || {
  echo '::error::UPDATE_BUILD_TIMEOUT_SECONDS must be a positive integer'
  exit 1
}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# Package directories the updaters changed: tracked edits plus new files.
changed=$(
  {
    git diff --name-only HEAD -- pkgs
    git ls-files --others --exclude-standard -- pkgs
  } | cut -d/ -f2 | sort -u | while IFS= read -r name; do
    if [[ -n $name && -f "pkgs/$name/default.nix" ]]; then printf '%s\n' "$name"; fi
  done
)

packages=()
while IFS= read -r name; do
  if [[ -n $name ]]; then packages+=("$name"); fi
done <<< "$changed"

reverted=()

for name in "${packages[@]}"; do
  echo "::group::Verify $name"

  # Out-of-band or knowingly broken packages are not judged by a plain build.
  if ! nix eval --raw --no-write-lock-file \
    --apply 'p: if (p.meta.ciBuild or true) && !(p.meta.broken or false) then "yes" else "no"' \
    ".#packages.x86_64-linux.\"${name}\"" > "$work/buildable" 2> "$work/eval.log"; then
    echo "::warning::$name metadata could not be evaluated; letting the build decide"
    echo yes > "$work/buildable"
  fi
  if [[ "$(cat "$work/buildable")" != yes ]]; then
    echo "$name is built out of band (meta.ciBuild = false) or marked broken; leaving it alone"
    echo '::endgroup::'
    continue
  fi

  verdict=passed
  if [[ "${CI_ALLOW_HEAVY_BUILDS:-false}" != true ]] &&
    nix build --dry-run --no-link --no-write-lock-file \
      ".#packages.x86_64-linux.\"${name}\"^*" > /dev/null 2> "$work/plan"; then
    plan_status=0
    python3 "$(dirname "${BASH_SOURCE[0]}")/check-build-plan.py" < "$work/plan" > "$work/heavy" ||
      plan_status=$?
    if (( plan_status != 0 )); then
      verdict=failed
      {
        echo 'the update would compile a toolchain from source:'
        cat "$work/heavy"
      } > "$work/log"
    fi
  fi

  if [[ $verdict == passed ]] &&
    ! timeout --kill-after=30s "${BUILD_TIMEOUT_SECONDS}s" \
      nix build --print-build-logs --no-link --no-write-lock-file \
      ".#packages.x86_64-linux.\"${name}\"^*" > "$work/log" 2>&1; then
    verdict=failed
  fi

  if [[ $verdict == passed ]]; then
    echo "$name builds; keeping the update"
  else
    git checkout -- "pkgs/$name" 2>/dev/null || true
    git clean -fdq -- "pkgs/$name" 2>/dev/null || true
    reverted+=("$name")
    echo "::warning::$name update reverted: it does not build"
    tail -n 15 "$work/log"
  fi
  echo '::endgroup::'
done

[[ -n ${GITHUB_OUTPUT:-} ]] &&
  printf 'reverted_count=%s\nreverted_packages=%s\n' \
    "${#reverted[@]}" "${reverted[*]:-}" >> "$GITHUB_OUTPUT"

if (( ${#reverted[@]} == 0 )); then
  echo 'All updated packages build; nothing rolled back.'
  exit 0
fi

{
  echo
  echo "### Rolled back updates"
  echo
  echo "These updates did not build and were reverted to the version on \`main\`."
  echo "The rest of this PR is unaffected; the next update run retries them."
  if [[ -n ${BUILD_LOG_URL:-} ]]; then echo; echo "Full log: $BUILD_LOG_URL"; fi
  echo
  for name in "${reverted[@]}"; do echo "- \`$name\`"; done
} > "$work/section.md"

cat "$work/section.md" >> "${GITHUB_STEP_SUMMARY:-/dev/null}"
if [[ -f $PR_BODY_PATH ]]; then cat "$work/section.md" >> "$PR_BODY_PATH"; fi

echo "::notice::Rolled back ${#reverted[@]} of ${#packages[@]} updated package(s): ${reverted[*]}. The remaining updates continue."
