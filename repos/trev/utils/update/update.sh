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

    echo
    echo "::group::Updating ${package}"
    git checkout -B "update/${system}/${package}"
    eval "${command}"
    status=$?
    echo "::endgroup::"

    if [[ "$status" -ne 0 ]]; then
        echo "Failed to update ${package}!"
        continue
    fi

    commits=$(git log 'main..HEAD')
    if [[ -z "${commits}" ]]; then
        continue
    fi

    git push --quiet --force origin "update/${system}/${package}"
    git checkout --quiet main
done
