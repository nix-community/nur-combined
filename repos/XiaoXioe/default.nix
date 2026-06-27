{
  pkgs ? import <nixpkgs> { },
}:

let
  lib = pkgs.lib;
  pkgsPath = ./pkgs;

  # Membaca direktori secara dinamis persis seperti di flake.nix kamu
  packageDirs = lib.filterAttrs (name: type: type == "directory") (builtins.readDir pkgsPath);
  packageNames = builtins.attrNames packageDirs;
in
(lib.genAttrs packageNames (name: pkgs.callPackage (pkgsPath + "/${name}/default.nix") { }))
// {
  overlays.default =
    final: prev:
    let
      packageDirs = final.lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./pkgs);
      packageNames = final.lib.attrNames packageDirs;
    in
    final.lib.genAttrs packageNames (name: final.callPackage (./pkgs + "/${name}/default.nix") { });

  modules = {
    freqtrade-setup = import ./modules/freqtrade-setup.nix;
  };
  homeModules = {
    freqtrade-setup = import ./modules/freqtrade-setup.nix;
  };
}
