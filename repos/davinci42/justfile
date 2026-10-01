set positional-arguments

default:
    @just --list

update package version="stable":
    python3 tools/maintain.py update "$1" --version "$2"

update-reviewed package version:
    python3 tools/maintain.py update "$1" --version "$2" --accept-contract

build package:
    nix build -f . "$1" --no-link

check package:
    python3 tools/maintain.py check "$1"

check-all:
    python3 tools/maintain.py check-all

check-updates *args:
    python3 tools/check_updates.py "$@"

contract package:
    python3 tools/maintain.py contract "$1"

lint:
    python3 tools/maintain.py lint
