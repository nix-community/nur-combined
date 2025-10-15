{
  pkgs ? import <nixpkgs> { },
}:
let
  sources = pkgs.callPackage ./_sources/generated.nix { };
  flake-compat = import sources.flake-compat.extract."default.nix";
  inputs =
    (flake-compat {
      src = ./.;
      copySourceTreeToStore = false;
      useBuiltinsFetchTree = true;
    }).inputs;
in
import ./packages.nix { inherit pkgs inputs; }
