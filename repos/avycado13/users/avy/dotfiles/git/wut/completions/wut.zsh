#compdef wut

_wut() {
    local -a branches
    local curcontext="$curcontext" state line
    typeset -A opt_args

    # Get worktree branches
    if git rev-parse --git-dir &>/dev/null; then
        branches=(${(f)"$(git worktree list --porcelain 2>/dev/null | awk '/^branch / { b = substr($0, 8); gsub(/^refs\/heads\//, "", b); print b }')"})
    fi

    _arguments -C \
        '1: :->command' \
        '*: :->args' \
        '--help[Show help]' \
        '-h[Show help]' \
        '--version[Show version]' \
        '-V[Show version]' \
        && return 0

    case $state in
        command)
            local -a commands
            commands=(
                'init:Print shell integration'
                'new:Create a new worktree'
                'list:List all worktrees'
                'go:Go to worktree'
                'path:Print path to worktree'
                'rm:Remove worktree and delete branch'
            )
            _describe 'command' commands
            ;;
        args)
            case ${words[2]} in
                new)
                    _arguments \
                        '1:branch name:' \
                        '--from[Create from ref]:ref:__git_refs'
                    ;;
                go|path)
                    if [[ ${#branches[@]} -gt 0 ]]; then
                        _describe 'branch' branches
                    else
                        _message 'branch name'
                    fi
                    ;;
                rm)
                    _arguments \
                        '1:branch:((${(j: :)${(@q)branches}}))' \
                        '--force[Force removal]'
                    if [[ ${#branches[@]} -gt 0 ]]; then
                        _describe 'branch' branches
                    fi
                    ;;
            esac
            ;;
    esac

    return 0
}

_wut "$@"
