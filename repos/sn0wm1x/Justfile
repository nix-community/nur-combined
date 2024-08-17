# show available recipes.
list:
  @just --list

# build package.
build package:
  nix build .#{{package}}

# build broken package.
build-broken package:
  NIXPKGS_ALLOW_BROKEN=1 nix build .#{{package}} --impure

# run package.
run package:
  nix run .#{{package}}

# update flake lock.
up:
  nix flake update
