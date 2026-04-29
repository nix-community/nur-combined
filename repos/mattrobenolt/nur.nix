# NUR compatibility.
{ pkgs }:

let
  packageSet = import ./lib/packages.nix { inherit (pkgs) lib; };
  pkgs' = pkgs.extend packageSet.overlay;
in
packageSet.packagesFor pkgs'
// {
  modules = [ ];
  overlays = { };
}
