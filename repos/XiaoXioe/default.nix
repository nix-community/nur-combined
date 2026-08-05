{
  pkgs ? import <nixpkgs> { },
}:

let
  lib = pkgs.lib;
  packageFiles = import ./pkgs/by-name.nix {
    inherit lib;
    baseDirectory = ./pkgs/by-name;
  };
in
(lib.mapAttrs (name: path: pkgs.callPackage path { }) packageFiles)
// {
  overlays.default =
    final: prev:
    let
      packageFiles = import ./pkgs/by-name.nix {
        inherit (final) lib;
        baseDirectory = ./pkgs/by-name;
      };
    in
    lib.mapAttrs (name: path: final.callPackage path { }) packageFiles;

  modules = {
    freqtrade-setup = import ./modules/freqtrade-setup.nix;
  };
  homeModules = {
    freqtrade-setup = import ./modules/freqtrade-setup.nix;
  };
}
