{ pkgs, system, nodejs-14_x, makeWrapper }:
let
  nodePackages = import ./composition.nix {
    inherit pkgs system;
    nodejs = nodejs-14_x;
  };
in
(
  nodePackages
)
