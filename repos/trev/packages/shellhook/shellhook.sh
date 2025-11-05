#!/usr/bin/env bash

# don't run in CI
if [[ -n "${CI-}" ]]; then
    exit 0
fi

reset_color=""
info_color=""
warn_color=""
success_color=""

# nf-fa-git_alt
git_icon="\uefa0"
# nf-dev-nixos
nix_icon="\ue843"
# nf-fa-npm
npm_icon="\ued0e"
# nf-dev-goland
go_icon="\ue7ef"

if colors=$(tput colors 2> /dev/null); then
    if [[ "$colors" -ge 256 ]]; then
        reset_color=$(tput sgr0)
        info_color=$(tput setaf 189)
        warn_color=$(tput setaf 216)
        success_color=$(tput setaf 117)

        git_color=$(tput setaf 202)
        git_icon=$(printf "%s%b%s" "$git_color" "$git_icon" "$reset_color")

        nix_color=$(tput setaf 68)
        nix_icon=$(printf "%s%b%s" "$nix_color" "$nix_icon" "$reset_color")

        npm_color=$(tput setaf 160)
        npm_icon=$(printf "%s%b%s" "$npm_color" "$npm_icon" "$reset_color")

        go_color=$(tput setaf 80)
        go_icon=$(printf "%s%b%s" "$go_color" "$go_icon" "$reset_color")
    fi
fi

function info {
    if [[ -n "${2-}" ]]; then # icon
        printf "%s %s%s%s\n" "$1" "${info_color}" "$2" "$reset_color"
    else
        printf "%s%s%s\n" "${info_color}" "$1" "$reset_color"
    fi
}

function warn {
    if [[ -n "${2-}" ]]; then # icon
        printf "%s %s%s%s\n" "$1" "${warn_color}" "$2" "$reset_color"
    else
        printf "%s%s%s\n" "${warn_color}" "$1" "$reset_color"
    fi
}

function success {
    if [[ -n "${2-}" ]]; then # icon
        printf "%s %s%s%s\n" "$1" "${success_color}" "$2" "$reset_color"
    else
        printf "%s%s%s\n" "${success_color}" "$1" "$reset_color"
    fi
}

function git_info {
    if [[ ! -d ".git" ]]; then
        warn "$git_icon" "not a git repository"
        return 1
    fi

    if ! command -v git &> /dev/null; then
        warn "$git_icon" "git is not in PATH"
        return 1
    fi

    if ! branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
        warn "$git_icon" "not on a branch"
        return 1
    fi

    if ! remote=$(git config --get branch."${branch}".remote 2> /dev/null); then
        warn "$git_icon" "branch ${branch} does not have a remote set"
        return 1
    fi

    if ! url=$(git config --get remote."${remote}".url 2> /dev/null); then
        warn "$git_icon" "remote ${remote} does not have a URL set"
        return 1
    fi

    regex="git@(.*):(.*)"
    if [[ $url =~ $regex ]]; then
        info "$git_icon" "https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    else
        info "$git_icon" "${url}"
    fi

    # get latest version from tag
    if version=$(git describe --tags --abbrev=0 2> /dev/null); then
        version=${version#v}
        info "$git_icon" "version ${version}"
    fi

    # get remote updates
    if ! git fetch --quiet "${remote}" "${branch}"; then
        warn "$git_icon" "failed to fetch remote updates"
        return 1
    fi

    # check current git status
    local_hash=$(git rev-parse "${branch}")
    remote_hash=$(git rev-parse "${remote}"/"${branch}")
    base_hash=$(git merge-base "${branch}" "${remote}"/"${branch}")
    if [[ "${local_hash}" = "${remote_hash}" ]]; then
        info "$git_icon" "up-to-date"
    elif [[ "${local_hash}" = "${base_hash}" ]]; then
        warn "$git_icon" "there are remote changes"
    elif [[ "${remote_hash}" = "${base_hash}" ]]; then
        warn "$git_icon" "there are local changes"
    else
        warn "$git_icon" "diverged"
    fi

    return 0
}

function nix_info {
    if [[ ! -f "flake.nix" ]]; then
        return 1
    fi

    if ! command -v nix &> /dev/null; then
        warn "$nix_icon" "nix is not in PATH"
        return 1
    fi

    if ! metadata=$(nix flake metadata --json 2> /dev/null); then
        warn "$nix_icon" "failed to run nix flake metadata"
        return 1
    fi

    deps_count=$(echo "$metadata" | jq ".locks.nodes.root.inputs | length")
    info "$nix_icon" "$deps_count dependencies"

    lastModified=$(echo "$metadata" | jq ".lastModified")
    timeSince=$(( $(date +%s) - lastModified ))
    daysSince=$(( timeSince / 86400 ))
    if [[ "$daysSince" -eq 0 ]]; then
        info "$nix_icon" "last modified today"
    elif [[ "$daysSince" -eq 1 ]]; then
        info "$nix_icon" "last modified 1 day ago"
    else
        info "$nix_icon" "last modified ${daysSince} days ago"
    fi

    return 0
}

function npm_info {
    if [[ ! -f "package.json" ]]; then
        return 1
    fi

    if ! command -v npm &> /dev/null; then
        warn "$npm_icon" "npm is not in PATH"
        return 1
    fi

    if deps=$(npm ls --json 2> /dev/null); then
        deps_count=$(echo "$deps" | jq ".dependencies | length")
        info "$npm_icon" "$deps_count dependencies"
    else
        warn "$npm_icon" "node_modules is outdated (run npm install)"
    fi

    if outdated=$(npm outdated --json 2> /dev/null); then
        info "$npm_icon" "up-to-date"
    else
        outdated_count=$(echo "$outdated" | jq "length")
        warn "$npm_icon" "$outdated_count outdated dependencies"
    fi

    return 0
}

function go_info {
    if [[ ! -f "go.mod" ]]; then
        return 1
    fi

    if ! command -v go &> /dev/null; then
        warn "$go_icon" "go is not in PATH"
        return 1
    fi

    if ! modules=$(go list -u -m -json -mod=readonly all 2> /dev/null); then
        warn "$go_icon" "failed to run go list"
        return 1
    fi

    if version=$(echo "$modules" | jq 'select(has("Main"))' | jq -r ".GoVersion"); then
        info "$go_icon" "version ${version}"
    fi

    deps=$(echo "$modules" | jq 'select(has("Indirect") | not)')
    deps_count=$(echo "$deps" | jq -s "length")
    info "$go_icon" "$deps_count dependencies"

    outdated_count=$(echo "$deps" | jq 'select(has("Update"))' | jq -s "length")
    if [[ "$outdated_count" -eq 0 ]]; then
        info "$go_icon" "up-to-date"
    else
        warn "$go_icon" "$outdated_count outdated"
    fi

    return 0
}

declare -A pids

git_info &
pids["git"]=$!

nix_info &
pids["nix"]=$!

npm_info &
pids["npm"]=$!

go_info &
pids["go"]=$!

for key in "${!pids[@]}"; do
    value="${pids[$key]}"
    wait "$value" || true
    pids["${key}"]=$?
done

# add pre-push hook
if [[ "${pids["git"]}" -eq 0 ]] && [[ "${pids["nix"]}" -eq 0 ]] && [[ -d ".git" ]] && [[ ! -f ".git/hooks/pre-push" ]]; then
    info "$git_icon" "creating git pre-push hook"
    {
        echo "if git branch --show-current | grep -q 'main'; then"
        echo "nix flake check --accept-flake-config"
        echo "fi"
    } >> .git/hooks/pre-push
    chmod +x .git/hooks/pre-push
fi
