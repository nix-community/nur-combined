with import nix/sources.nix;

let
  pkgs = import nixpkgs {};
in import ./. { inherit pkgs; }
