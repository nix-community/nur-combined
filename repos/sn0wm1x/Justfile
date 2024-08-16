# show available recipes.
list:
  @just --list

# build package.
build package:
  nix build .#{{package}}

# build broken package.
build-broken package:
  NIXPKGS_ALLOW_BROKEN=1 nix build .#{{package}} --impure

# build unfree package.
build-unfree package:
  NIXPKGS_ALLOW_UNFREE=1 nix build .#{{package}} --impure
