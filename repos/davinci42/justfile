set positional-arguments

default:
    @just --list

update package version="":
    python3 tools/maintain.py update "$1" ${2:+--version="$2"}

update-reviewed package version:
    python3 tools/maintain.py update "$1" --version "$2" --accept-contract

update-spotx:
    NIXPKGS_ALLOW_UNFREE=1 python3 tools/maintain.py update spotify-spotx

build package:
    nix build -f . "$1" --no-link

check package:
    python3 tools/maintain.py check "$1"

check-all:
    python3 tools/maintain.py check-all

check-updates *args:
    python3 tools/check_updates.py "$@"

contract package="fluxdown-server":
    python3 "pkgs/$1/update-settings.py" --check

lint:
    python3 tools/maintain.py lint
