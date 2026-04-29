# List available commands
default:
    @just --list --unsorted

# Format all Nix files (runs deadnix, statix, and nixfmt)
fmt:
    nix fmt

# Check flake outputs and formatting
check:
    nix flake check

# Build a package
build package:
    nix build ".#{{package}}"

# Update one package by directory name under pkgs/
update package:
    ./pkgs/{{package}}/update.py

# Update Go versions and hashes
update-go:
    @just update go-bin

# Update inbox package
update-inbox:
    @just update inbox

# Update zigdoc package
update-zigdoc:
    @just update zigdoc

# Update ziglint package
update-ziglint:
    @just update ziglint

# Update Zed package (stable + preview)
update-zed:
    @just update zed

# Update all packages
update-all:
    @just update go-bin
    @just update inbox
    @just update zigdoc
    @just update ziglint
    @just update zed
