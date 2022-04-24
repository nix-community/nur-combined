{ pkgs ? import <nixpkgs> { } }:

let

  inherit (pkgs) lib;
  inherit (lib) optionalAttrs versionOlder;

  pkgsVersion = lib.versions.majorMinor lib.version;

in {
  lib = import ./lib { inherit (pkgs) lib; };
  modules = import ./modules; # NixOS modules.
  overlays = import ./overlays; # Nixpkgs overlays.
  hmModules = import ./hm-modules; # Home Manager modules.
  ndModules = import ./nd-modules; # nix-darwin modules.

  firefox-addons =
    pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });

  firefox-addons-generator = let
    hpkgs = pkgs.haskellPackages;
    haskellPackages = if hpkgs ? relude_1_0_0_1 then
      hpkgs.override {
        overrides = self: super: { relude = self.relude_1_0_0_1; };
      }
    else
      hpkgs;
  in haskellPackages.callPackage ./pkgs/firefox-addons-generator { };

  materia-theme = pkgs.callPackage ./pkgs/materia-theme { };

  nix-stray-roots = pkgs.callPackage ./pkgs/nix-stray-roots { };

  dbus-codegen-rust = pkgs.callPackage ./pkgs/dbus-codegen-rust { };
}
