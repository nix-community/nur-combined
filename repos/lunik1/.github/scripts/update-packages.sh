#!/usr/bin/env bash

set -Eeuo pipefail

base_branch="master"
pr_branch="automated/update-packages"

# Excluded from targets:
#   amazing-marvin    AppImage on S3, no version listing -> cannot detect
#   asap-condensed    google/fonts releases are unrelated to the releases of individual fonts
#   krig-bilateral    undetectable gist
#   ssim-downscaler   undetectable gist
#   ssim-super-res    undetectable gist

targets=(
  "bach|"
  "doukutsu-rs|"
  "efficient-compression-tool|"
  "fsrcnnx-x2-8-0-4-1|"
  "fsrcnnx-x2-16-0-4-1|"
  "myosevka.mono|"
  "scanverdict|"
  "thelounge-theme-zenburn|"
  "trash-d|"

  "ls-colors|--version=branch"
  "xcompose|--version=branch"
)

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git switch -C "${pr_branch}"

failed=()
for entry in "${targets[@]}"; do
  attr="${entry%%|*}"
  args="${entry#*|}"

  extra=()
  if [ -n "${args}" ]; then
    read -r -a extra <<<"${args}"
  fi

  echo "::group::nix-update ${attr} ${args}"
  if nix run nixpkgs#nix-update -- --flake "${extra[@]}" --build --commit "${attr}"; then
    :
  else
    echo "::warning::nix-update failed for ${attr}; skipping"
    failed+=("${attr}")
    git checkout -- .
    git clean -fdq
  fi
  echo "::endgroup::"
done

{
  echo "### nix-update"
  if ((${#failed[@]})); then
    echo "Skipped (could not update or build): ${failed[*]}"
  else
    echo "All target packages processed."
  fi
} >>"${GITHUB_STEP_SUMMARY:-/dev/stdout}"

updated="$(git log "origin/${base_branch}..HEAD" --pretty=format:'- %s')"
if [ -z "${updated}" ]; then
  echo "No package updates; nothing to do."
  exit 0
fi

body="Automated package bumps via nix-update (https://github.com/Mic92/nix-update). Each package is build-verified before being committed; packages that failed to update or build are skipped.

Updated packages:
${updated}"

git push -f -u origin "${pr_branch}"

if gh pr view "${pr_branch}" >/dev/null 2>&1; then
  gh pr edit "${pr_branch}" --body "${body}"
  echo "Existing pull request updated."
else
  gh pr create \
    --base "${base_branch}" \
    --head "${pr_branch}" \
    --title "flake: automated package updates" \
    --body "${body}"
fi
