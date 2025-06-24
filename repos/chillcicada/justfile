# list all available recipes
default:
  @just --list

# build a target package
build TARGET:
  nix-build -A {{TARGET}} |& nom

alias b := build

# format nix files
fmt:
  nixfmt .

# clean
clean:
  rm -rf result
