{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellScriptBin "pkg" ''
set -euf -o pipefail

COMMAND=$1;shift

case "$COMMAND" in
    install)
        nix-env -iA "$1" -f '<nixpkgs>'
    ;;
    list)
        nix-env --query
    ;;
    update)
        pushd ~/.dotfiles
            nix flake update --update-input nixpkgs
        popd
    ;;
    update-inputs)
        pushd ~/.dotfiles
            for input in "$@"
            do
                nix flake update --update-input $input
            done
        popd
    ;;
    uninstall)
        nix-env --uninstall $*
    ;;
esac
''
