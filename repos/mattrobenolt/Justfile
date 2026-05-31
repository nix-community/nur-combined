[private]
default:
    @just --list --unsorted

[doc("Format all Nix files with the flake formatter")]
[group("checks")]
fmt:
    nix fmt

[doc("Check flake outputs and formatting")]
[group("checks")]
check:
    nix flake check

[arg("package", pattern="^[A-Za-z0-9._+-]+$")]
[doc("Build a flake package")]
[group("packages")]
build package:
    nix build ".#{{ package }}"

[arg("package", pattern="^[A-Za-z0-9._+-]+$")]
[doc("Update one package by directory name under pkgs/")]
[group("updates")]
update package:
    ./pkgs/{{ package }}/update.py

[doc("Update Go versions and hashes")]
[group("updates")]
update-go:
    @just update go-bin

[doc("Update hunk package")]
[group("updates")]
update-hunk:
    @just update hunk

[doc("Update inbox package")]
[group("updates")]
update-inbox:
    @just update inbox

[doc("Update prismacat package")]
[group("updates")]
update-prismacat:
    @just update prismacat

[doc("Update txtar package")]
[group("updates")]
update-txtar:
    @just update txtar

[doc("Update zigdoc package")]
[group("updates")]
update-zigdoc:
    @just update zigdoc

[doc("Update ziglint package")]
[group("updates")]
update-ziglint:
    @just update ziglint

[doc("Update Zed package (stable + preview)")]
[group("updates")]
update-zed:
    @just update zed

[doc("Update all packages")]
[group("updates")]
update-all: update-go update-hunk update-inbox update-prismacat update-txtar update-zigdoc update-ziglint update-zed
