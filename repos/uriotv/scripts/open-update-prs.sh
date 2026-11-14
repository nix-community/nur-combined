#!/usr/bin/env bash
# Opens one pull request per updated package.
#
# A package update must never depend on another package's update: each PR carries
# exactly one package (plus its README row), so build.yml builds it, test-gate gates
# its merge, and a failing or broken update simply stays behind instead of blocking
# the rest. Publication then publishes exactly what built.
#
# Run after scripts/update-packages.sh and scripts/revert-broken-updates.sh (which
# already dropped updates that do not build).
set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required to open update pull requests}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

# actions/checkout keeps no credentials (persist-credentials: false), so authenticate
# the pushes with GH_TOKEN through environment-only git config: nothing is written to
# the repository or printed, and the token never appears in a command line.
git_auth="AUTHORIZATION: basic $(printf 'x-access-token:%s' "$GH_TOKEN" | base64 | tr -d '\n')"
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0='http.https://github.com/.extraheader'
export GIT_CONFIG_VALUE_0="$git_auth"

base=${UPDATE_PR_BASE:-main}
BUILD_LOG_URL=${BUILD_LOG_URL:-}
bot_name=${GIT_BOT_NAME:-github-actions[bot]}
bot_email=${GIT_BOT_EMAIL:-41898282+github-actions[bot]@users.noreply.github.com}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

base_sha=$(git rev-parse HEAD)
git checkout --quiet --detach "$base_sha"

# Package directories the updaters changed: tracked edits plus new files.
packages=()
while IFS= read -r name; do
  if [[ -n $name && -f "pkgs/$name/default.nix" ]]; then packages+=("$name"); fi
done < <(
  {
    git diff --name-only HEAD -- pkgs
    git ls-files --others --exclude-standard -- pkgs
  } | cut -d/ -f2 | sort -u
)

if (( ${#packages[@]} == 0 )); then
  echo 'No package changes; nothing to open.'
  if [[ -n ${GITHUB_OUTPUT:-} ]]; then printf 'pull_requests=0\n' >> "$GITHUB_OUTPUT"; fi
  exit 0
fi

# Snapshot every package's changes (edits and new files) before touching the tree.
for name in "${packages[@]}"; do
  git add -N -- "pkgs/$name"
  git diff HEAD -- "pkgs/$name" > "$work/$name.patch"
done

# Builds one PR for one package. Returns 0 when a PR was opened or refreshed,
# 2 when the package has no change against the base, 1 on any failure.
open_package_pr() {
  local name=$1 branch=$2 version pr

  # Every PR starts from the untouched base commit and carries only this package.
  git checkout --quiet --detach "$base_sha" || return 1
  git reset --quiet --hard "$base_sha" || return 1
  git clean -fdq -- pkgs README.md || return 1
  git apply --index "$work/$name.patch" || return 1
  python3 -B scripts/readme-versions.py --write || return 1
  version=$(nix eval --raw --no-write-lock-file \
    ".#packages.x86_64-linux.\"${name}\".version" 2>/dev/null || true)
  git add -A -- "pkgs/$name" README.md || return 1
  if git diff --cached --quiet; then
    echo "$name has no change against ${base}; skipping"
    return 2
  fi

  git -c user.name="$bot_name" -c user.email="$bot_email" \
    commit --quiet -m "chore(${name}): update to ${version:-upstream}" \
    -m "Automatic update of \`${name}\` only, so unrelated packages cannot block it." ||
    return 1
  git show --stat --oneline HEAD | sed 's/^/  /'
  git push --force --quiet origin "HEAD:refs/heads/${branch}" || return 1

  {
    echo "Automatic update of \`${name}\` to \`${version:-upstream}\`."
    echo
    echo "This pull request contains only this package (and its README row), so an"
    echo "update of another package can neither block it nor be blocked by it. The"
    echo "update built on the runner before this PR was opened; only what built is"
    echo "published to the cache after the merge."
    if [[ -n $BUILD_LOG_URL ]]; then
      echo
      echo "Update run: $BUILD_LOG_URL"
    fi
  } > "$work/body.md"

  pr=$(gh pr list --head "$branch" --state open --json number --jq '.[0].number // empty') ||
    return 1
  if [[ -n $pr ]]; then
    gh pr edit "$pr" --title "chore(${name}): update to ${version:-upstream}" \
      --body-file "$work/body.md" || return 1
  else
    gh pr create --base "$base" --head "$branch" \
      --title "chore(${name}): update to ${version:-upstream}" \
      --body-file "$work/body.md" || return 1
  fi
  gh pr merge "$branch" --squash --auto --delete-branch || return 1
  return 0
}

opened=()
failed=()

for name in "${packages[@]}"; do
  echo "::group::Open update PR for $name"
  status=0
  open_package_pr "$name" "auto-update/$name" || status=$?
  case $status in
    0) opened+=("$name") ;;
    2) ;;
    *)
      echo "::error::$name: could not open an update pull request"
      failed+=("$name")
      ;;
  esac
  echo '::endgroup::'
done

git checkout --quiet --detach "$base_sha"
git reset --quiet --hard "$base_sha"
git clean -fdq -- pkgs README.md

if [[ -n ${GITHUB_OUTPUT:-} ]]; then
  printf 'pull_requests=%s\npull_request_packages=%s\n' \
    "${#opened[@]}" "${opened[*]:-}" >> "$GITHUB_OUTPUT"
fi

if (( ${#failed[@]} )); then
  echo "::error::Could not open an update PR for: ${failed[*]}"
  exit 1
fi
if (( ${#opened[@]} == 0 )); then
  echo 'Every change was already on the base commit; nothing to open.'
  exit 0
fi
echo "::notice::Opened ${#opened[@]} update pull request(s): ${opened[*]}."
