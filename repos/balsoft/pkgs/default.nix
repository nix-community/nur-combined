{ pkgs ? import <nixpkgs> { } }:
with import ./lib.nix;
let sources = import ../nix/sources.nix;
in {
  termNote = callPackageDouble pkgs "termNote";
  lambda-launcher = callPackageDouble pkgs.haskellPackages "lambda-launcher";
  lambda-launcher-fixed =
    (import "${sources.lambda-launcher}/default.nix" { }).lambda-launcher;
  roboto-mono-nerd = pkgs.callPackage ./roboto-mono-nerd.nix { };
  nix-patch = pkgs.callPackage ./nix-patch.nix { inherit (sources) nix-patch; };
}
