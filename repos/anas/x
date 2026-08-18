#!/usr/bin/env bash

set -euo pipefail

REPO_NAME='nur'
declare -A GIT_REMOTES=(
    [github]="git@github.com:0x61nas/${REPO_NAME}.git"
    [gitlab]="git@gitlab.com:anelgarhy/${REPO_NAME}.git"
    [codeberg]="ssh://git@codeberg.org/0x61nas/${REPO_NAME}.git"
    [disroot]="ssh://git@git.disroot.org/anas/${REPO_NAME}.git"
    [tangled]="git@tangled.org:anas.tngl.sh/${REPO_NAME}"
    [gitgud]="git@ssh.gitgud.io:anelgarhy/${REPO_NAME}.git"
    [codefloe]="ssh://git@codefloe.com/anas/${REPO_NAME}.git"
)

ok()   { echo -e "DONE: $1"; }
fail() { echo -e "FAIL: $1"; }
info() { echo -e "INFO: $1"; }
warn() { echo -e "WARN: $1"; }

usage() {
    cat <<EOF
Usage: x <command> [args]

Commands:
  push [flags] [branch]     Push branch to all remotes (default: -u aurora)
  push-tags                 Push tags to all remotes
  clean                     Remove untracked files and directories
  setup-remotes             Register all git remotes
  print-remotes             Display configured git remotes
  help                      Show this help message
EOF
    exit 0
}

error() {
    local arg="${1-}"
    echo -e "Error: unknown command '${arg}'" >&2
    echo "Run 'x help' for usage" >&2
    exit 1
}

print-remotes() {
    for remote in "${!GIT_REMOTES[@]}"; do
        echo "  $remote -> ${GIT_REMOTES[$remote]}"
    done
}

setup-remotes() {
    for remote in "${!GIT_REMOTES[@]}"; do
        if git remote add "$remote" "${GIT_REMOTES[$remote]}" 2>/dev/null; then
            ok "added remote $remote"
        else
            warn "remote $remote already exists"
        fi
    done
}

push() {
    local flags=()
    local branch="aurora"

    for arg in "$@"; do
        if [[ "$arg" == -* ]]; then
            flags+=("$arg")
        else
            branch="$arg"
        fi
    done

    [[ ${#flags[@]} -eq 0 ]] && flags=("-u")

    local flag_str="${flags[*]}"
    echo -e "Pushing to all remotes"
    echo -e "  Branch: $branch  Flags: ${flag_str:-(none)}"
    echo

    local ok=true
    for remote in "${!GIT_REMOTES[@]}"; do
        info "pushing to $remote..."
        if git push "${flags[@]}" "$remote" "$branch"; then
            ok "pushed to $remote"
        else
            fail "failed to push to $remote"
            ok=false
        fi
    done
    echo
    if $ok; then
        ok "all pushes succeeded"
    else
        fail "some pushes failed"
        return 1
    fi
}

push-tags() {
    push "$@"
    echo
    echo -e "Pushing tags to all remotes"
    echo
    local ok=true
    for remote in "${!GIT_REMOTES[@]}"; do
        info "pushing tags to $remote..."
        if git push --tags "$remote"; then
            ok "tags pushed to $remote"
        else
            fail "failed to push tags to $remote"
            ok=false
        fi
    done
    echo
    if $ok; then
        ok "all tag pushes succeeded"
    else
        fail "some tag pushes failed"
        return 1
    fi
}

clean() {
    echo -e "Cleaning untracked files"
    git clean -ffdx
    ok "clean complete"
}

arg="${1-}"
[[ -z "$arg" ]] && usage
shift

case $arg in
    help|h|--help|-h) usage ;;
    print-remotes|pr) print-remotes ;;
    setup-remotes|sr) setup-remotes ;;
    push|p) push "$@" ;;
    push-tags|pusht|pt) push-tags "$@" ;;
    clean|c) clean ;;
    *) error "$arg" ;;
esac
