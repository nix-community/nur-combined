{ nixpkgs ? <nixpkgs> }:

let
  pkgs.x86_64-linux  = import nixpkgs { system = "x86_64-linux"; };
  pkgs.x86_64-darwin = import nixpkgs { system = "x86_64-darwin"; };

in {
  pkgs-linux  = (import ./ci.nix { pkgs = pkgs.x86_64-linux; }).buildPkgs;
  pkgs-darwin = (import ./ci.nix { pkgs = pkgs.x86_64-darwin; }).buildPkgs;
}
