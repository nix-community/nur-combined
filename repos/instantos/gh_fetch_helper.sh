#!/usr/bin/env bash
# nix-env -i nix-prefetch-github
# nix-env -i xclip

main() {
    owner="${1:?Owner name must be first argument}"
    project="${2:?Project name must be second argument}"
    branch="${3:-master}"

    commit="$(
      curl "https://api.github.com/repos/$owner/$project/branches/$branch" 2>/dev/null | 
        jq -r '.commit.sha'
    )"

    if ! grep -qPi "^[a-f0-9]{20,}$" <<< "$commit"; then
        echo "Error: No valid git commit $commit" 1>&2
        exit 1
    fi
    echo "$commit"

    entry="$(
        nix-prefetch-github --nix --rev "$commit" "$owner" "$project" | 
          grep -v fetchSubmodules
    )"
    echo "$entry"
    echo "$entry" | 
      xclip -i -selection clipboard
}

if [ "$0" = "$BASH_SOURCE" ]; then
    main "$@"
fi

