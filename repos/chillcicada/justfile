CACHIX_USERNAME := "chillcicada"

CURRENT_DIR := `pwd`

# list all available recipes
default:
  @just --list

# build a target package
build TARGET:
  nix-build -A {{TARGET}} |& nom

alias b := build

# build a target package and push it to cachix
push TARGET:
  nix-build -A {{TARGET}} | cachix push {{CACHIX_USERNAME}}

alias p := push

# format nix files
fmt:
  nixfmt .

# clean
clean:
  rm -rf result
