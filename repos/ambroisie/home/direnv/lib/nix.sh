#shellcheck shell=bash

use_pkgs() {
    if ! has nix; then
        # shellcheck disable=2016
        log_error 'use_pkgs: `nix` is not in PATH'
        return 1
    fi

    # Use user-provided default value, or fallback to nixpkgs
    local DEFAULT_FLAKE="${DIRENV_DEFAULT_FLAKE:-nixpkgs}"

    # Allow changing the default flake through a command line switch
    if [ "$1" = "-f" ] || [ "$1" = "--flake" ]; then
        DEFAULT_FLAKE="$2"
        shift 2
    fi


    # Allow specifying a full installable, or just a package name and use the default flake
    local packages=()
    for pkg; do
        if [[ $pkg =~ .*#.* ]]; then
            packages+=("$pkg")
        else
            packages+=("$DEFAULT_FLAKE#$pkg")
        fi
    done

    # shellcheck disable=2154
    direnv_load nix shell "${packages[@]}" --command "$direnv" dump
}
