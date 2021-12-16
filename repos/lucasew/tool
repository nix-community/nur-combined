#!/usr/bin/env bash
# vim:ft=sh

set -euf -o pipefail

cd "$(dirname $(realpath "$0"))"

export DEFAULT_USER=lucasew

function bold {
    printf "$(tput bold)$*$(tput sgr0)"
}

function red {
    printf "$(tput setaf 1)$*$(tput sgr0)"
}

function green {
    printf "$(tput setaf 2)$*$(tput sgr0)"
}

function yellow {
    printf "$(tput setaf 3)$*$(tput sgr0)"
}

function error {
    echo "$(red "error"): $*"
    exit 1
}

function warning {
    echo "$(yellow "warn"): $*"
}

function info {
    echo "$(green "info"): $*"
}

function now {
    date -u -Iseconds
}

function now_unix {
    date -u +%s
}

function timestamped {
    while read line; do
        echo "$(now) $line"
    done
}

function random_id {
    head -c 128 /dev/urandom | md5sum | tr -d ' -'
}

function mustBinary {
    binary=$1;shift
    which "$binary" > /dev/null 2> /dev/null || {
        echo "command '$binary' not found"
        exit 1
    }
}

function buildNixOS {
    config=$1;shift
    nix-build default.nix -A nixosConfigurations.$config.config.system.build.toplevel "$@"
}

function buildHM {
    config=$1;shift
    nix-build default.nix -A homeConfigurations.$config.activatePackage "$@"
}

function enumeratePrebuildPaths {
    nix-build --dry-run build.nix 2> /dev/stdout | grep '\.drv$' | sed -e 's/^[ \t]*//'
}

function generateRequiredPaths {
    rm .required-paths.txt || true
    for p in $(enumeratePrebuildPaths); do
        echo "$p" >> .required-paths.txt
    done
}

function buildRequiredPaths {
    enumeratePrebuildPaths # to generate the drvs
    if [[ ! -f .required-paths.txt ]]; then
        error ".required-paths.txt does not exists so i cant build them"
    fi
    for p in `cat .required-paths.txt`; do
        nix-store --realize $p "$@" || true
    done
}

function nop {
    true
}

"$@"
