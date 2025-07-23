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

if [ -d ".git" ]; then
    branch=$(git rev-parse --abbrev-ref HEAD)
    remote=$(git config --get branch."${branch}".remote)
    url=$(git config --get remote."${remote}".url)

    regex="git@(.*):(.*)"
    if [[ $url =~ $regex ]]; then
        printinfo " https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    else
        printinfo " ${url}"
    fi

    # check for remote updates
    git fetch --quiet "${remote}" "${branch}"
    if ! git diff --quiet HEAD "${remote}"/"${branch}"; then
        printwarn " there are remote changes"
        git status --short
    else
        printinfo " no remote changes"
    fi

    # show flake info
    if [ -f "flake.nix" ]; then
        printinfo " $(nix flake metadata --json | jq ".description")"

        lastModified=$(nix flake metadata --json | jq ".lastModified")
        timeSince=$(( $(date +%s) - lastModified ))
        daysSince=$(( timeSince / 86400 ))
        printinfo " last modified ${daysSince} day(s) ago"

        # add pre-push hook
        if [ ! -f ".git/hooks/pre-push" ]; then
            printgood " creating git pre-push hook"
            echo "nix flake check --accept-flake-config" > .git/hooks/pre-push
            chmod +x .git/hooks/pre-push
        fi
    fi
fi

echo
printgood "loaded direnv"