# list all available recipes
default:
  @just --list --unsorted

# build a target package
build TARGET:
  nix build .#{{TARGET}} --impure |& nom

alias b := build

# format nix files
fmt:
  nixfmt .

# clean
clean:
  rm -rf result
