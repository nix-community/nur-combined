{
  pkgs ? import <nixpkgs> { },
}:
let
  files = builtins.attrNames (builtins.readDir ./pkgs);
in
{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
}
// pkgs.lib.listToAttrs (
  map (file: {
    name = file;
    value = pkgs.callPackage ./pkgs/${file} { };
  }) files
)
