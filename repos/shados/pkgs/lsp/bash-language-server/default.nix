{ pkgs ? import <nixpkgs> {
    inherit system;
  }
, system ? builtins.currentSystem
}:
let
  nodePackages = import ./package.nix {
    inherit pkgs system;
  };
in nodePackages."bash-language-server"
