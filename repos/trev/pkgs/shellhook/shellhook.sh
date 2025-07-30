function fromhex {
    hex=${1#"#"}
    r=$(printf '0x%0.2s' "$hex")
    g=$(printf '0x%0.2s' "${hex#??}")
    b=$(printf '0x%0.2s' "${hex#????}")
    printf '%3d' "$(( (r<75?0:(r-35)/40)*6*6 + 
                       (g<75?0:(g-35)/40)*6   +
                       (b<75?0:(b-35)/40)     + 16 ))"
}

function printgood {
    printf "%s$1\n" "$(tput setaf "$(fromhex 89dceb)")"
}

function printwarn {
    printf "%s$1\n" "$(tput setaf "$(fromhex f9e2af)")"
}

function printinfo {
    printf "%s$1\n" "$(tput setaf "$(fromhex cdd6f4)")"
}

function gitconfig {
    if [ ! -d ".git" ]; then
        printwarn " not a git repository"
        return 1
    fi

    branch=$(git rev-parse --abbrev-ref HEAD)

    remote=$(git config --get branch."${branch}".remote)
    if [ -z "${remote}" ]; then
        printwarn " branch ${branch} does not have a remote set"
        return 1
    fi

    url=$(git config --get remote."${remote}".url)
    if [ -z "${url}" ]; then
        printwarn " remote ${remote} does not have a URL set"
        return 1
    fi

    regex="git@(.*):(.*)"
    if [[ $url =~ $regex ]]; then
        printinfo " https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    else
        printinfo " ${url}"
    fi

    # get remote updates
    git fetch --quiet "${remote}" "${branch}"

    # check current git status
    local_hash=$(git rev-parse "${branch}")
    remote_hash=$(git rev-parse "${remote}"/"${branch}")
    base_hash=$(git merge-base "${branch}" "${remote}"/"${branch}")
    if [ "${local_hash}" = "${remote_hash}" ]; then
        printinfo " up-to-date"
    elif [ "${local_hash}" = "${base_hash}" ]; then
        printwarn " there are remote changes"
    elif [ "${remote_hash}" = "${base_hash}" ]; then
        printwarn " there are local changes"
    else
        printwarn " diverged"
    fi

    return 0
}

function nixconfig {
    if [ ! -f "flake.nix" ]; then
        printwarn " not a flake"
        return 1
    fi

    printinfo " $(nix flake metadata --json | jq ".description")"

    lastModified=$(nix flake metadata --json | jq ".lastModified")
    timeSince=$(( $(date +%s) - lastModified ))
    daysSince=$(( timeSince / 86400 ))
    printinfo " last modified ${daysSince} day(s) ago"

    return 0
}

gitconfig
gitconfig_status=$?

nixconfig
nixconfig_status=$?

if [ $gitconfig_status -eq 0 ] && [ $nixconfig_status -eq 0 ]; then
    if [ ! -f ".git/hooks/pre-push" ]; then
        printgood " creating git pre-push hook"
        echo "nix flake check --accept-flake-config" > .git/hooks/pre-push
        chmod +x .git/hooks/pre-push
    fi
fi

echo
printgood "loaded direnv"