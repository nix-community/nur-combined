{
  pkgs ? import <nixpkgs> { },
}:

let
  byName = builtins.readDir ./pkgs/by-name;
  pkgsByName = builtins.mapAttrs (name: _: pkgs.callPackage (./pkgs/by-name + "/${name}") { }) byName;
in

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ark-pixel-font = pkgs.callPackage ./pkgs/ark-pixel-font { };
  fusion-pixel-font = pkgs.callPackage ./pkgs/fusion-pixel-font { };

  typship = throw "nurpkgs 'typship' has been dropped in favor of nixpkgs instead."; # Added 2025-06-29
}
// pkgsByName
