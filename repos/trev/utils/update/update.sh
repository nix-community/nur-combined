#!/usr/bin/env bash

export NIX_PATH="nixpkgs=flake:nixpkgs"

system=$(nix eval --impure --raw --expr 'builtins.currentSystem')
echo "Updating packages for ${system}"

json=$(nix eval --file "$(dirname "${BASH_SOURCE[0]}")/packages.nix" --json packages)
readarray -t packages < <(echo "${json}" | jq -r -S '. | keys[]')
readarray -t commands < <(echo "${json}" | jq -r -S '. | values[]')

for index in "${!packages[@]}"; do
    package="${packages[${index}]}"
    command="${commands[${index}]}"
    echo "::group::Updating ${package}"

    git checkout -B "update/${system}/${package}"

    if ! ${command}; then
        echo "Failed to update ${package}"
        echo "::endgroup::"
        continue
    fi

    commits=$(git log 'main..HEAD')
    if [[ -z "${commits}" ]]; then
        echo "No update needed for ${package}"
        echo "::endgroup::"
        continue
    fi

    git push --force origin "update/${system}/${package}"
    git checkout main

    echo "::endgroup::"
done
