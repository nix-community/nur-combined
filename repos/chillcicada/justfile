CACHIX_USERNAME := "chillcicada"

default:
  @just --list

build TARGET:
  nix-build -A {{TARGET}}

alias b := build

push TARGET:
  nix-build -A {{TARGET}} | cachix push {{CACHIX_USERNAME}}

alias p := push

fmt:
  nixpkgs-fmt .
