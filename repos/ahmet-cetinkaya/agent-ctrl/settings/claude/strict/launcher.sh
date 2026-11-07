#!/usr/bin/env bash
# Start Claude Code with the Bash sandbox on, on top of auto mode.
# settings.json in this directory holds the sandbox policy and is passed with --settings,
# which outranks the user settings. This launcher adds what depends on the working
# directory: the worktrees of the repository, git access, the directories .NET tools need
# to exist, and write denies that keep a session from widening the next one.
set -u

readonly SETTINGS_FILE="${BASH_SOURCE[0]%/*}/settings.json"
readonly WRITE_DENY_PATH='["sandbox","filesystem","denyWrite"]'
readonly WRITE_ALLOW_PATH='["sandbox","filesystem","allowWrite"]'

# Apply a jq filter to settings_json; extra arguments are passed as jq options.
# Without the check a jq failure would pass an empty --settings and silently drop the denies.
update_settings() {
  local merged
  if ! merged=$(jq -c "$@" <<<"$settings_json") || [[ -z "$merged" ]]; then
    printf '%s\n' 'claude-strict: settings merge failed; refusing to start' >&2
    exit 1
  fi
  settings_json=$merged
}

# Append values to the array at a JSON path in settings_json, keeping it unique.
append_setting() {
  local json_path=$1
  shift
  update_settings --argjson path "$json_path" \
    'setpath($path; ((getpath($path) // []) + $ARGS.positional | unique))' --args "$@"
}

if ! settings_json=$(jq -c . "$SETTINGS_FILE") || [[ -z "$settings_json" ]]; then
  printf '%s\n' "claude-strict: cannot read $SETTINGS_FILE; refusing to start" >&2
  exit 1
fi

if [[ "$PWD" == "$HOME" ]]; then
  printf '%s\n' 'claude-strict: launching from $HOME may freeze (the sandbox scans the whole home dir). cd into a project first.' >&2
  if [[ ! -t 0 ]]; then
    exit 1
  fi
  read -r -n 1 -p 'Continue anyway? [y/N] ' answer
  printf '\n'
  [[ "$answer" == [yY] ]] || exit 1
fi

# Give Claude a stable per-user sandbox temp root, then point Bun's native-addon
# extraction there. This fixes Bun-packaged tools (for example Tailwind/lightningcss)
# without widening the filesystem boundary. The sandbox only lets commands write the
# per-user subdirectory Claude Code creates under the temp root, not the root itself.
sandbox_tmp=${CLAUDE_CODE_TMPDIR:-$HOME/.cache/claude-code/tmp}
user_tmp="$sandbox_tmp/claude-$(id -u)"
mkdir -p "$user_tmp"
chmod 700 "$sandbox_tmp" "$user_tmp"
export CLAUDE_CODE_TMPDIR="$sandbox_tmp"
export BUN_TMPDIR="${BUN_TMPDIR:-$user_tmp}"

# .NET and Aspire write these: `dotnet run file.cs` keeps its virtual project in runfile,
# named mutexes use /tmp/.dotnet/shm or $XDG_RUNTIME_DIR/.dotnet/shm, a cold restore
# writes the package caches, and Aspire keeps its logs and state in ~/.aspire. The sandbox
# cannot create a missing directory it may write, so they are created first.
dotnet_state_dirs=("$HOME/.local/share/dotnet/runfile" "$HOME/.nuget/packages" \
  "$HOME/.local/share/NuGet" "$HOME/.dotnet" "$HOME/.aspire" "/tmp/.dotnet/shm")
[[ -n "${XDG_RUNTIME_DIR:-}" ]] && dotnet_state_dirs+=("$XDG_RUNTIME_DIR/.dotnet")
mkdir -p "${dotnet_state_dirs[@]}"
append_setting "$WRITE_ALLOW_PATH" "${dotnet_state_dirs[@]}"

# MSBuild imports every file in this user directory into each project. The file turns the
# build parallelism off only where SANDBOX_RUNTIME is set, which is inside the sandbox.
# The directory stays outside the sandbox write list, so a sandboxed command cannot
# change the file.
msbuild_import_dir="$HOME/.local/share/Microsoft/MSBuild/Current/Imports/Microsoft.Common.props/ImportBefore"
msbuild_import_source="${BASH_SOURCE[0]%/*}/sandbox-no-sockets.props"
mkdir -p "$msbuild_import_dir"
cmp -s "$msbuild_import_source" "$msbuild_import_dir/sandbox-no-sockets.props" ||
  cp -f "$msbuild_import_source" "$msbuild_import_dir/"

# ~/.aspire/bin comes first on PATH, so a file planted there would run instead of git or
# sudo. The deny sits next to the grant so the two can never ship apart.
append_setting "$WRITE_DENY_PATH" "$HOME/.aspire/bin"

worktree_root=$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || true)
common_git_dir=$(git -C "$PWD" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
main_worktree=
repo_worktrees=()

if [[ -n "$worktree_root" && -n "$common_git_dir" && "${common_git_dir##*/}" == .git ]]; then
  main_worktree=${common_git_dir%/.git}

  # A session often works across the checkouts of one repository, for example a test in a
  # sibling worktree. Every worktree of the repository is writable. Its .git file points
  # git at the shared hooks and config, and unsandboxed git commands follow it, so it
  # stays write-denied.
  while IFS= read -r worktree_path; do
    [[ -d "$worktree_path" && ! -L "$worktree_path" ]] && repo_worktrees+=("$worktree_path")
  done < <(git -C "$worktree_root" worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p')
  if (( ${#repo_worktrees[@]} )); then
    append_setting "$WRITE_ALLOW_PATH" "${repo_worktrees[@]}"
    linked_git_files=()
    for worktree_path in "${repo_worktrees[@]}"; do
      [[ -f "$worktree_path/.git" ]] && linked_git_files+=("$worktree_path/.git")
    done
    (( ${#linked_git_files[@]} )) && append_setting "$WRITE_DENY_PATH" "${linked_git_files[@]}"
  fi

  # Commits write the common git dir, which lies outside the working directory in
  # linked worktrees and when the session starts in a subdirectory. Hooks and config
  # run later outside the sandbox (git commit and git push are excluded), so they stay
  # write-denied, and so does a hooks directory moved into the tree with core.hooksPath.
  append_setting "$WRITE_ALLOW_PATH" "$common_git_dir"
  append_setting "$WRITE_DENY_PATH" "$common_git_dir/hooks" "$common_git_dir/config"
  hooks_path=$(git -C "$worktree_root" config --get core.hooksPath 2>/dev/null || true)
  if [[ -n "$hooks_path" ]]; then
    [[ "$hooks_path" == /* ]] || hooks_path="$worktree_root/$hooks_path"
    append_setting "$WRITE_DENY_PATH" "$hooks_path"
  fi
fi

# Claude Code loads settings, hooks, and skills from .claude, and hooks run outside the
# sandbox, so no session may write the .claude of its start directory or of any worktree
# of the repository. A deny on a path that does not exist may not be enforced, so the
# directory is created first; an empty directory does not show in git. A symlinked
# .claude is distrusted, so it is denied but never followed.
claude_dirs=("$PWD/.claude")
[[ -n "$worktree_root" ]] && claude_dirs+=("$worktree_root/.claude")
[[ -n "$main_worktree" ]] && claude_dirs+=("$main_worktree/.claude")
for worktree_path in "${repo_worktrees[@]}"; do
  claude_dirs+=("$worktree_path/.claude")
done
for claude_dir in "${claude_dirs[@]}"; do
  [[ -L "$claude_dir" ]] || mkdir -p "$claude_dir"
done
append_setting "$WRITE_DENY_PATH" "${claude_dirs[@]}"

if [[ ${CLAUDE_LAUNCHER_PRINT_SETTINGS:-0} == 1 ]]; then
  printf '%s\n' "$settings_json"
  exit 0
fi

# The sandbox stays on in bypass mode, so bypass mode is selectable with Shift+Tab.
exec claude --allow-dangerously-skip-permissions --settings "$settings_json" "$@"
