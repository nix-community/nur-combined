# shellcheck shell=bash

use_pkgs() {
    if ! has nix; then
        # shellcheck disable=2016
        log_error 'use_pkgs: `nix` is not in PATH'
        return 1
    fi

    # Use user-provided default value, or fallback to nixpkgs
    local DEFAULT_FLAKE="${DIRENV_DEFAULT_FLAKE:-nixpkgs}"
    # Additional args that should be forwarded to `nix`
    local args=()

    # Allow changing the default flake through a command line switch
    while true; do
        case "$1" in
            -b|--broken)
                args+=(--impure)
                export NIXPKGS_ALLOW_BROKEN=1
                shift
                ;;
            -f|--flake)
                DEFAULT_FLAKE="$2"
                shift 2
                ;;
            -i|--impure)
                args+=(--impure)
                shift
                ;;
            -s|--insecure)
                args+=(--impure)
                export NIXPKGS_ALLOW_INSECURE=1
                shift
                ;;
            -u|--unfree)
                args+=(--impure)
                export NIXPKGS_ALLOW_UNFREE=1
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done


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
    direnv_load nix shell "${args[@]}" "${packages[@]}" --command "$direnv" dump

    # Clean-up after ourselves (assumes the user does not set them before us)
    unset NIXPKGS_ALLOW_BROKEN
    unset NIXPKGS_ALLOW_INSECURE
    unset NIXPKGS_ALLOW_UNFREE
}
